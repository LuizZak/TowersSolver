import Foundation
import Commons
import Geometry

public class LightUpSolver: GameSolverType {
    private(set) public var state: SolverState
    private(set) public var grid: LightUpGrid {
        get {
            internalState.grid
        }
        set {
            internalState.grid = newValue
        }
    }

    /// The maximum number of guesses this solver takes before giving up on
    /// ambiguous states.
    var maxGuesses: Int = 10

    var internalState: InternalState

    public init(grid: LightUpGrid) {
        self.internalState = InternalState(grid: grid)
        state = .unsolved
    }

    private init(internalState: InternalState) {
        self.internalState = internalState
        state = .unsolved
    }

    private func makeSubSolver() -> LightUpSolver {
        return .init(internalState: internalState.stateForSubSolver())
    }

    @discardableResult
    public func solve() -> SolverState {
        whileModifyingState { changeState in
            if state == .invalid {
                return
            }
            if state == .solved {
                return
            }

            applyMoves(moves_applyHintMarkers())
            applyMoves(moves_satisfyCompleteHints())
            applyMoves(moves_soleLightTiles())
            applyMoves(moves_preventUnlitMarkers())

            updateState()

            // Guess only when state is unchanged from simple solver steps
            guard !changeState.hasChanged() else {
                return
            }

            applyGuesses()
        }

        return state
    }

    func updateState() {
        if grid.isSolved() {
            state = .solved
        } else if !grid.isValid() {
            state = .invalid
        } else {
            state = .unsolved
        }
    }

    // MARK: Move management

    private func applyMoves(_ moves: [LightUpMove]) {
        for move in moves {
            applyMove(move)
        }
    }

    private func applyMove(_ move: LightUpMove) {
        grid = move.applied(to: grid)

        switch move {
        case .markAsLight(let tiles):
            // Mark tiles in path of lights as guaranteed non-lights
            for tile in tiles.coordinates where grid[tile].isLight {
                for direction in LightUpGrid.Direction.allCases {
                    guard let neighbors = grid.spaces(from: tile, direction: direction) else {
                        continue
                    }

                    for coord in neighbors.coordinates {
                        grid[coord].state = .space(.marker)
                    }
                }
            }

        default:
            break
        }
    }

    private func applyGuesses() {
        // Only root solver can apply guesses
        guard !internalState.isSubSolver else {
            return
        }

        var guesses = generateGuesses()

        while !guesses.isEmpty && internalState.guessesTaken <= maxGuesses {
            defer { internalState.guessesTaken += 1 }

            let guess = guesses.removeFirst()

            // Use sub-solver to inspect guess move
            let subSolver = makeSubSolver()
            subSolver.applyMove(guess.asLightUpMove(on: subSolver.grid))

            switch subSolver.solve() {
            case .invalid:
                // Invert move and apply change
                if let inverted = guess.inverted {
                    applyMove(inverted.asLightUpMove(on: grid))
                    return
                }

            case .solved:
                // Adopt sub-solver state
                grid = subSolver.grid
                state = subSolver.state
                return

            case .unsolvable, .unsolved:
                break
            }
        }
    }

    // MARK: Solver stages

    /// Applies markers around hints on the grid such that no light can be placed
    /// in a spot that instantly invalidades the solution.
    private func moves_applyHintMarkers() -> [LightUpMove] {
        var result: [LightUpMove] = []

        for coords in grid.tileCoordinates {
            switch grid[coords].state {
            case .wall(0):
                // 0 hint: orthogonal tiles cannot be lights
                result.append(.markAsMarker(grid.tilesOrthogonallyAdjacentTo(coords)))
            
            case .wall(1):
                let lightCount = grid.lightsSurrounding(coords)?.count ?? 0
                if lightCount == 1 {
                    break
                }

                // 1 hint: If only two available tiles exist and they share an
                // adjacent tile, then that adjacent tile cannot be a light as
                // it would invalidate the hint.
                guard let available = grid.availableSpacesSurrounding(coords)?.coordinates else {
                    break
                }

                if
                    available.count == 2,
                    let diagonal = grid.orthogonalTileTo(
                        diagonal1: available[0],
                        diagonal2: available[1],
                        ignoring: coords
                    )
                {
                    // The diagonal tile is the one that has the column of one of
                    // the tiles and the row of the other. One of the two possible
                    // combinations is the 1-hint wall itself
                    result.append(.markAsMarker(grid.viewForTile(diagonal)))
                }
            
            case .wall(2):
                let orthogonal = grid.tilesOrthogonallyAdjacentTo(coords)

                // 2 hint: If the cell is at the edge of the grid, none of its
                // available diagonals can be lights
                if orthogonal.count < 4 {
                    result.append(
                        .markAsMarker(
                            grid.tilesDiagonallyAdjacentTo(coords)
                        )
                    )

                    break
                }

                // 2 hint extended: If exactly one orthogonally adjacent tile is
                // a wall or is lit from another tile, the diagonals that are
                // adjacent to two free spaces cannot be lights
                let walls = orthogonal.coordinates.filter { grid[$0].isWall || (grid.isLit($0) && !grid[$0].isLight) }
                if walls.count == 1 {
                    let wall = walls[0]
                    let diagonals = grid.tilesDiagonallyAdjacentTo(coords).coordinates.filter {
                        !grid.areOrthogonallyAdjacent($0, wall)
                    }

                    guard !diagonals.isEmpty else {
                        break
                    }

                    result.append(
                        .markAsMarker(
                            grid.viewForCoordinates(coordinateList: diagonals)
                        )
                    )
                }

            case .wall(3), .wall(4):
                // 3/4 hint: diagonal tiles cannot be lights
                result.append(.markAsMarker(grid.tilesDiagonallyAdjacentTo(coords)))

            default:
                break
            }
        }

        return result
    }

    /// Apply markers to neighbors of marker tiles to prevent a light placement
    /// from ruling out ways to light the marker itself.
    /// 
    /// Considering the following example:
    /// ```
    /// | x |   |
    /// |   |   |
    /// ```
    /// 
    /// Placement of a light on the bottom-right tile would prevent the marker
    /// tile from being lit by either of its adjacent tiles, so it must not be
    /// a light:
    /// 
    /// ```
    /// | x |   |
    /// |   | x |
    /// ```
    private func moves_preventUnlitMarkers() -> [LightUpMove] {
        var result: [LightUpMove] = []

        for coords in grid.tileCoordinates where grid[coords].isMarker && !grid.isLit(coords) {
            let available = grid
                .tilesOrthogonallyAdjacentTo(coords)
                .coordinates.filter({ !grid.isLit($0) && grid[$0].isEmpty })

            // Must have exactly two empty adjacent spaces
            guard available.count == 2 else {
                continue
            }

            // Set of tiles that can light the marker must be equal to the adjacent
            // tiles themselves
            guard let visible = grid.allSpacesVisible(from: coords) else {
                continue
            }
            guard Set(visible.coordinates.filter(grid.canPlaceLight(on:))) == Set(available) else {
                continue
            }

            // Tiles must be diagonal to each other
            guard let shared = grid.orthogonalTileTo(diagonal1: available[0], diagonal2: available[1], ignoring: coords) else {
                continue
            }

            if grid[shared].isEmpty {
                result.append(.markAsMarker(grid.viewForTile(shared)))
            }
        }

        return result
    }

    /// Places lights around hints that have are constrained to have the same
    /// number of adjacent free spaces as the hints themselves.
    private func moves_satisfyCompleteHints() -> [LightUpMove] {
        var result: [LightUpMove] = []

        for coords in grid.tileCoordinates {
            switch grid[coords].state {
            case .wall(let hint?) where hint > 0:
                let adjacent = grid.tilesOrthogonallyAdjacentTo(coords)
                let lights = adjacent.count(where: \.isLight)

                // Mark surrounding spaces of solved hints with markers
                if lights == hint {
                    result.append(.markAsMarker(adjacent))
                } else {
                    guard adjacent.emptySpaces() == hint - lights else {
                        break
                    }

                    result.append(.markAsLight(adjacent))
                }

            default:
                break
            }
        }

        return result
    }

    /// Analyzes unlit grid tiles placing lights in places where the only way
    /// to light a tile is known and free.
    private func moves_soleLightTiles() -> [LightUpMove] {
        var result: [LightUpMove] = []

        for coords in grid.tileCoordinates where !grid[coords].isWall {
            guard !grid.isLit(coords) else {
                continue
            }

            // Case 1: Tile is sole tile in a separate region
            guard let spaces = grid.allSpacesVisible(from: coords) else {
                result.append(.markAsLight(grid.viewForTile(coords)))
                continue
            }

            // Case 2: Unlit tile is not marked, but all surrounding tiles are,
            // in which case it must be a light.
            if grid[coords].isEmpty && spaces.allSatisfy(\.isMarker) {
                result.append(.markAsLight(grid.viewForTile(coords)))
            }

            // Case 3: Tile is marked and unlit, and only one visible tile is
            // unmarked, in which case it must be the light.
            if grid[coords].isMarker, let unlit = spaces.coordinates.only(where: { grid[$0].isEmpty }) {
                result.append(.markAsLight(grid.viewForTile(unlit)))
            }
        }

        return result
    }

    /// Generates an array of all potential guess move from the current grid state.
    /// 
    /// Returns an empty array if no move can be made from the current grid state.
    private func generateGuesses() -> [Guess] {
        var guesses: [Guess] = []

        for coord in grid.tileCoordinates {
            switch grid[coord].state {
            case .wall(let hint?):
                guard (grid.lightsSurrounding(coord)?.count ?? 0) < hint else {
                    continue
                }
                guard let available = grid.availableSpacesSurrounding(coord) else {
                    continue
                }
                
                // Guesses for hinted tiles take priority over empty space guesses
                for coord in available.coordinates {
                    guesses.insert(.markAsLight(coord), at: 0)
                }
            
            case .space(.empty):
                guesses.append(
                    .markAsLight(coord)
                )

            default:
                continue
            }
        }

        return guesses
    }

    private func whileModifyingState(_ block: (ChangeWatcher) -> Void) {
        while true {
            let changed = ChangeWatcher(solver: self)

            block(changed)

            if !changed.hasChanged() {
                break
            }
        }
    }

    struct InternalState {
        var grid: LightUpGrid
        var guessesTaken: Int = 0
        var isSubSolver: Bool = false

        func changed(from other: InternalState) -> Bool {
            return other.grid != grid
        }

        func stateForSubSolver() -> InternalState {
            .init(grid: grid, guessesTaken: guessesTaken, isSubSolver: true)
        }
    }

    private class ChangeWatcher {
        var initialState: InternalState
        var solver: LightUpSolver

        init(solver: LightUpSolver) {
            self.initialState = solver.internalState
            self.solver = solver
        }

        func hasChanged() -> Bool {
            solver.internalState.changed(from: initialState)
        }
    }

    private enum Guess {
        case markAsLight(Coordinates)
        case markAsMarker(Coordinates)

        /// Returns a logical inversion of this guess.
        /// For `Guess.markAsMarker(coords)`, returns `.Guess(coords)`,
        /// and for `Guess.markAsLight(coords)`, returns `.Guess(coords)`.
        var inverted: Self? {
            switch self {
            case .markAsMarker(let coords):
                return .markAsLight(coords)
            case .markAsLight(let coords):
                return .markAsMarker(coords)
            }
        }

        func asLightUpMove(on grid: LightUpGrid) -> LightUpMove {
            switch self {
            case .markAsLight(let coords):
                return .markAsLight(grid.viewForTile(coords))
            case .markAsMarker(let coords):
                return .markAsMarker(grid.viewForTile(coords))
            }
        }
    }
}

extension LightUpGrid {
    /// Returns the tile that two diagonally adjacent tiles share their edge with,
    /// ignoring one of the potential tile coordinates.
    /// Returns `nil` if the tiles are not diagonally adjacent.
    func orthogonalTileTo(diagonal1: Coordinates, diagonal2: Coordinates, ignoring ignore: Coordinates) -> Coordinates? {
        guard areDiagonallyAdjacent(diagonal1, diagonal2) else {
            return nil
        }

        let adjacent1 = makeCoordinates(column: diagonal1.column, row: diagonal2.row)
        let adjacent2 = makeCoordinates(column: diagonal2.column, row: diagonal1.row)
        
        return adjacent1 == ignore ? adjacent2 : adjacent1
    }
}
