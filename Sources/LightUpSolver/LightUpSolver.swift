import Foundation
import Commons
import Geometry

public class LightUpSolver: GameSolverType {
    private(set) public var state: SolverState
    public var grid: LightUpGrid {
        internalState.grid
    }

    var internalState: InternalState

    public init(grid: LightUpGrid) {
        self.internalState = InternalState(grid: grid)
        state = .unsolved
    }

    @discardableResult
    public func solve() -> SolverState {
        whileModifyingState {
            if state == .solved {
                return
            }

            applyMoves(moves_applyHintMarkers())
            applyMoves(moves_satisfyCompleteHints())
            applyMoves(moves_soleLightTiles())

            updateState()
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
        internalState.grid = move.applied(to: grid)

        switch move {
        case .markAsLight(let tiles):
            // Mark tiles in path of lights as guaranteed non-lights
            for tile in tiles.coordinates where grid[tile].isLight {
                for direction in LightUpGrid.Direction.allCases {
                    guard let neighbors = grid.spaces(from: tile, direction: direction) else {
                        continue
                    }

                    for coord in neighbors.coordinates {
                        internalState.grid[coord].state = .space(.marker)
                    }
                }
            }

        default:
            break
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
                let adjacent = grid.tilesOrthogonallyAdjacentTo(coords)
                let lightCount = adjacent.count(where: \.isLight)
                if lightCount == 1 {
                    break
                }

                // 1 hint: If only two available tiles exist and they share an
                // adjacent tile, then that adjacent tile cannot be a light as
                // it would invalidate the hint.
                let available = adjacent.coordinates.filter({ grid[$0].isEmpty && !grid.isLit($0) })

                if available.count == 2 && grid.areDiagonallyAdjacent(available[0], available[1]) {
                    // The diagonal tile is the one that has the column of one of
                    // the tiles and the row of the other. One of the two possible
                    // combinations is the 1-hint wall itself
                    let diagonal1 = grid.makeCoordinates(column: available[0].column, row: available[1].row)
                    let diagonal2 = grid.makeCoordinates(column: available[1].column, row: available[0].row)

                    let diagonal = diagonal1 == coords ? diagonal2 : diagonal1

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
                // a wall, the diagonals that are adjacent to two free spaces
                // cannot be lights
                let walls = orthogonal.coordinates.filter { grid[$0].isWall }
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

    private func whileModifyingState(_ block: () -> Void) {
        while true {
            let start = internalState

            block()

            if !internalState.changed(from: start) {
                break
            }
        }
    }

    struct InternalState {
        var grid: LightUpGrid

        func changed(from other: InternalState) -> Bool {
            return other.grid != grid
        }
    }
}
