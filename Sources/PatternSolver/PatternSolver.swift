import Foundation
import Commons
import Geometry

public class PatternSolver: GameSolverType {
    private var _pending: PendingCheckList
    private var _performedGuesses: Int = 0

    private(set) public var state: SolverState
    private(set) public var grid: PatternGrid

    /// Maximum number of guesses to apply before giving up on the resolution of
    /// ambiguous grids.
    public var maxGuesses: Int = 10

    public init(grid: PatternGrid) {
        self.grid = grid
        state = .unsolved

        _pending = PendingCheckList(grid: grid)
    }

    @discardableResult
    public func solve() -> SolverState {
        _pending.markGridPending()

        repeat {
            // Run a round of regular grid resolution
            while _pending.hasPendingChecks {
                grid = PatternSolver.analyzeGrid(grid: grid, entries: _pending)
            }

            updateState()

            guard grid.isValid() else {
                break
            }

            // Apply a guess
            guard _performedGuesses < maxGuesses else {
                break
            }
            defer { _performedGuesses += 1 }

            let guesser = PatternGuesser(grid: grid)
            guard let guess = guesser.generateNextGuess(index: _performedGuesses) else {
                break
            }
            let guessGrid = guess.applied(to: grid)

            let subSolver = makeSubSolver(grid: guessGrid)

            let result = subSolver.solve()
            switch result {
            case .solved:
                self.grid = subSolver.grid
                self.state = subSolver.state
            
            case .unsolvable, .invalid:
                grid = PatternSolver.applyMoves(guess.invalidatingMoves, to: grid, entries: _pending)

            case .unsolved:
                break
            }

            updateState()
        } while state != .solved && grid.isValid()

        return state
    }

    func makeSubSolver(grid: PatternGrid, maxGuesses: Int = 0) -> PatternSolver {
        let subSolver = PatternSolver(grid: grid)
        subSolver.maxGuesses = maxGuesses

        return subSolver
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

    private static func applyMove(
        _ move: PatternMove,
        to grid: PatternGrid,
        entries: PendingCheckList
    ) -> PatternGrid {
        
        entries.markTilesPending(move.affectedTileCoordinates)

        return move.applied(to: grid)
    }

    private static func applyMoves(
        _ moves: [PatternMove],
        to grid: PatternGrid,
        entries: PendingCheckList
    ) -> PatternGrid {
        
        entries.markTilesPending(moves.reduce([], { $0 + $1.affectedTileCoordinates }))

        return moves.applied(to: grid)
    }

    private static func analyzeGrid(
        grid: PatternGrid,
        entries: PendingCheckList
    ) -> PatternGrid {

        let result = runStepAcrossLines(grid, entries: entries) { (hint, tiles, setState) in
            func stateAt(_ index: Int) -> PatternTile.State? {
                if index < 0 || index >= tiles.count {
                    return nil
                }

                return tiles[index].state
            }
            func setStates<S: Sequence<Int>>(_ indices: S, _ state: PatternTile.State) {
                for index in indices {
                    setState(index, state)
                }
            }

            // Ignore completed tile lists, whether they are correctly solved
            // or not
            guard tiles.hasUndecidedTile() else {
                return
            }

            if hint.requiredDarkTiles == tiles.darkTileCount() {
                // If the dark tile count match the required hints, mark remaining
                // tiles as light
                for index in 0..<tiles.count {
                    if tiles[index].state != .dark {
                        setState(index, .light)
                    }
                }

                return
            } else if hint.requiredDarkTiles == tiles.darkTileCount() + tiles.undecidedTileCount() {
                // Conversely, if the required dark tile space matches the available
                // undecided space, fill the undecided tiles as dark
                for index in 0..<tiles.count {
                    if tiles[index].state == .undecided {
                        setState(index, .dark)
                    }
                }

                return
            }

            // Run tile fitter
            let tileFitter = TileFitter(hint: hint, tiles: Array(tiles))

            // Mark leading/trailing tiles that are guaranteed to be light
            if let earliestDarkTile = tileFitter.earliestDarkTile(), earliestDarkTile > 0 {
                setStates(0..<earliestDarkTile, .light)
            }
            if let latestDarkTile = tileFitter.latestDarkTile(), latestDarkTile < tiles.count - 1 {
                setStates((latestDarkTile + 1)..<tiles.count, .light)
            }

            // Clear spaces that are too small to fit any run that may overlap
            // those spaces
            for availableSpace in tiles.availableSpaceRuns() where !tiles[availableSpace].hasDarkTile() {
                guard let minRunLength = tileFitter.potentialRunLengths(forTileAt: availableSpace.startIndex)?.min() else {
                    continue
                }

                if availableSpace.count < minRunLength {
                    setStates(availableSpace, .light)
                }
            }

            // Mark tiles from overlapping ranges as dark
            let overlaps = tileFitter.overlappingIntervals()
            for case let (i, overlap?) in overlaps.enumerated() {
                setStates(overlap, .dark)

                // For overlaps that match the exact hint length, surround dark
                // tiles with light tiles
                let run = hint.runs[i]
                if overlap.count == run {
                    if overlap.lowerBound > 0 {
                        setState(overlap.lowerBound - 1, .light)
                    }
                    if overlap.upperBound < tiles.count {
                        setState(overlap.upperBound, .light)
                    }
                }
            }

            // Inspect gaps in possible dark tile runs that are definitely light.
            if
                let earliest = tileFitter.earliestAlignedRuns(),
                let latest = tileFitter.latestAlignedRuns()
            {

                assert(earliest.count == latest.count)

                for index in 0..<(earliest.count - 1) {
                    let latestCurrent = latest[index]
                    let earliestNext = earliest[index + 1]

                    // If the latest possible allocation for this run index does
                    // not overlap the earliest possible allocation for the next
                    // one, it indicates that all tiles in between are light.
                    guard latestCurrent.upperBound < earliestNext.lowerBound else {
                        continue
                    }

                    setStates(latestCurrent.upperBound..<earliestNext.lowerBound, .light)
                }
            }

            // For every dark tile, query for guaranteed dark tiles in the
            // surroundings.
            for darkTileRun in tiles.darkTileRuns() {
                let guaranteed = tileFitter.guaranteedDarkTilesSurrounding(
                    tileAtIndex: darkTileRun.lowerBound
                )

                setStates(guaranteed, .dark)

                // Also inspect the potential run lengths on top of a tile,
                // surrounding that tile with light tiles if the length happen
                // to be the only possible run length at that point.
                if stateAt(darkTileRun.lowerBound - 1) == .undecided || stateAt(darkTileRun.upperBound) == .undecided {
                    if let runLengths = tileFitter.potentialRunLengths(forTileAt: darkTileRun.lowerBound) {
                        guard runLengths.count == 1, let runLength = runLengths.first else {
                            continue
                        }

                        guard runLength == darkTileRun.count else {
                            continue
                        }

                        if darkTileRun.lowerBound > 0 {
                            setState(darkTileRun.lowerBound - 1, .light)
                        }
                        if darkTileRun.upperBound < tiles.count {
                            setState(darkTileRun.upperBound, .light)
                        }
                    }
                }
            }
        }

        return result
    }

    /// Runs a given closure for each solution direction (column, row) in the
    /// `entries` list, passing in the hint and the array of tiles for each
    /// direction.
    ///
    /// Also provides a closure that when fed an index and a state, changes the
    /// state for the tile at the given index on the appropriate column/row that
    /// it belongs.
    ///
    /// Returns a new grid that the closure has modified, along with a set of
    /// columns/rows that where affected in the process.
    private static func runStepAcrossLines(
        _ grid: PatternGrid,
        entries: PendingCheckList,
        _ step: @escaping (
            _ hint: PatternGrid.RunsHint,
            _ tiles: GridTileView<PatternGrid>,
            _ setState: (_ index: Int, _ state: PatternTile.State) -> Void
        ) -> Void
    ) -> PatternGrid {

        @ConcurrentValue
        var moves: [PatternMove] = []

        func addMove(_ coordinate: PatternGrid.CoordinateType, setState state: PatternTile.State) {
            _moves.modifyingValue { moves in
                // Ignore redundant moves to avoid spurious grid invalidation
                guard grid[coordinate].state != state else {
                    return
                }
                
                switch state {
                case .dark:
                    moves.append(.markAsDark(grid.viewForTile(coordinate)))
                case .light:
                    moves.append(.markAsLight(grid.viewForTile(coordinate)))
                case .undecided:
                    moves.append(.markAsUndecided(grid.viewForTile(coordinate)))
                }
            }
        }

        let parallel = ParallelQueue()

        // Examine each row/column and collect potential moves
        entries.forEachPendingColumn { column in
            let hint = grid.hintForColumn(column)
            let tiles = grid.tilesInColumn(column)

            parallel.addBlock {
                step(hint, tiles, { (index, state) in
                    let coordinate = PatternGrid.CoordinateType(column: column, row: index)

                    addMove(coordinate, setState: state)
                })
            }
        }

        entries.forEachPendingRow { row in
            let hint = grid.hintForRow(row)
            let tiles = grid.tilesInRow(row)

            parallel.addBlock {
                step(hint, tiles, { (index, state) in
                    let coordinate = PatternGrid.CoordinateType(column: index, row: row)

                    addMove(coordinate, setState: state)
                })
            }
        }

        parallel.waitForCompletion()

        // Satisfy before applying moves
        entries.satisfyAll()

        // Apply moves and return
        return applyMoves(moves, to: grid, entries: entries)
    }
    
    /// Marks columns/rows of a grid as pending checks.
    private class PendingCheckList {
        private var columnCount: Int
        private var rowCount: Int

        private var _columns: Bitmask64
        private var _rows: Bitmask64

        /// Returns `true` if any column or row on this check list are marked as
        /// pending.
        var hasPendingChecks: Bool {
            _columns.isNonZero || _rows.isNonZero
        }

        init(columnCount: Int, rowCount: Int) {
            self.columnCount = columnCount
            self.rowCount = rowCount

            _columns = 0
            _rows = 0

            // Ensure we have enough bits for each dimension
            _columns.ensureCapacity(columnCount)
            _rows.ensureCapacity(rowCount)
        }

        convenience init(grid: PatternGrid) {
            self.init(columnCount: grid.columns, rowCount: grid.rows)
        }

        func forEachPendingColumn(_ closure: (_ column: Int) throws -> Void) rethrows {
            try _columns.forEachOnBitIndex { column in
                try closure(column)
            }
        }

        func forEachPendingRow(_ closure: (_ row: Int) throws -> Void) rethrows {
            try _rows.forEachOnBitIndex { row in
                try closure(row)
            }
        }

        /// Marks all rows/columns as satisfied.
        func satisfyAll() {
            _columns.setAllBits(state: false)
            _rows.setAllBits(state: false)
        }

        /// Marks a given column index as satisfied.
        func satisfyColumn(_ column: Int) {
            assert(column < columnCount)

            _columns.setBitOff(column)
        }

        /// Marks a given row index as satisfied.
        func satisfyRow(_ row: Int) {
            assert(row < rowCount)

            _rows.setBitOff(row)
        }

        /// Marks a tile as pending a check.
        func markTilePending(column: Int, row: Int) {
            assert(column < columnCount)
            assert(row < rowCount)

            _columns.setBitOn(column)
            _rows.setBitOn(row)
        }

        /// Marks a tile as pending a check.
        func markTilePending(_ coordinate: PatternGrid.CoordinateType) {
            markTilePending(column: coordinate.column, row: coordinate.row)
        }

        /// Marks a list of tiles as pending a check.
        func markTilesPending<S: Sequence<PatternGrid.CoordinateType>>(_ coordinates: S) {
            for coord in coordinates {
                markTilePending(coord)
            }
        }

        /// Marks the whole set of columns and rows as pending.
        func markGridPending() {
            _columns.setBitRange(offset: 0, count: columnCount, state: true)
            _rows.setBitRange(offset: 0, count: rowCount, state: true)
        }
    }
}

private class ParallelQueue {
    let queue: OperationQueue = OperationQueue()
    var blocks: [() -> Void] = []

    func addBlock(_ block: @escaping () -> Void) {
        blocks.append(block)
    }

    func waitForCompletion(sequential: Bool = false) {
        defer { blocks.removeAll() }

        if sequential {
            for block in blocks {
                block()
            }
        } else {
            blocks.forEach(queue.addOperation(_:))
            queue.waitUntilAllOperationsAreFinished()
        }
    }
}
