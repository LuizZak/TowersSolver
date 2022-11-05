import Commons

public class PatternSolver: GameSolverType {
    private var _pending: PendingCheckList

    private(set) public var state: SolverState
    private(set) public var grid: PatternGrid

    public init(grid: PatternGrid) {
        self.grid = grid
        state = .unsolved

        _pending = PendingCheckList(grid: grid)
    }

    @discardableResult
    public func solve() -> SolverState {
        _pending.markGridPending()

        while state == .unsolved && _pending.hasPendingChecks {
            grid = PatternSolver.analyzeGrid(grid: grid, entries: _pending)
        }

        updateState()

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

    private static func analyzeGrid(
        grid: PatternGrid,
        entries: PendingCheckList
    ) -> PatternGrid {

        let result = runStepAcrossLines(grid, entries: entries) { (hint, tiles, setState) in
            // Ignore completed tile lists, whether they are correctly solved
            // or not
            guard tiles.hasUndecidedTile() else {
                return
            }

            let tileFitter = TileFitter(hint: hint, tiles: tiles)

            // Mark leading/trailing tiles that are guaranteed to be light
            if let earliestDarkTile = tileFitter.earliestDarkTile(), earliestDarkTile > 0 {
                for index in 0..<earliestDarkTile {
                    setState(index, .light)
                }
            }
            if let latestDarkTile = tileFitter.latestDarkTile(), latestDarkTile < tiles.count - 1 {
                for index in (latestDarkTile + 1)..<tiles.count {
                    setState(index, .light)
                }
            }

            // Mark tiles from overlapping ranges as dark
            let overlaps = tileFitter.overlappingIntervals()
            for case let (i, overlap?) in overlaps.enumerated() {
                for index in overlap {
                    setState(index, .dark)
                }

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

            if hint.requiredDarkTiles == tiles.darkTileCount() {
                // If the dark tile count match the required hints, mark remaining
                // tiles as light
                for index in 0..<tiles.count {
                    if tiles[index].state != .dark {
                        setState(index, .light)
                    }
                }
            } else if hint.requiredDarkTiles == tiles.darkTileCount() + tiles.undecidedTileCount() {
                // Conversely, if the required dark tile space matches the available
                // undecided space, fill the undecided tiles as dark
                for index in 0..<tiles.count {
                    if tiles[index].state == .undecided {
                        setState(index, .dark)
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

                    for lightIndex in latestCurrent.upperBound..<earliestNext.lowerBound {
                        setState(lightIndex, .light)
                    }
                }
            }

            // For every dark tile, query for guaranteed dark tiles in the
            // surroundings.
            for darkTileRun in tiles.darkTileRuns() {
                let guaranteed = tileFitter.guaranteedDarkTilesSurrounding(
                    tileAtIndex: darkTileRun.lowerBound
                )

                for index in guaranteed {
                    setState(index, .dark)
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
        _ step: (
            _ hint: PatternGrid.RunsHint,
            _ tiles: [PatternTile],
            _ setState: (_ index: Int, _ state: PatternTile.State) -> Void
        ) throws -> Void
    ) rethrows -> PatternGrid {

        var grid = grid

        try entries.forEachPendingColumn { column in
            entries.satisfyColumn(column)

            let hint = grid.hintForColumn(column)

            try step(hint, grid.tilesInColumn(column), { (index, state) in
                let coordinate = PatternGrid.CoordinateType(column: column, row: index)

                guard grid[coordinate].state != state else {
                    return
                }

                grid[coordinate].state = state
                entries.markTilePending(coordinate)
            })
        }

        try entries.forEachPendingRow { row in
            entries.satisfyRow(row)

            let hint = grid.hintForRow(row)

            try step(hint, grid.tilesInRow(row), { (index, state) in
                let coordinate = PatternGrid.CoordinateType(column: index, row: row)

                guard grid[coordinate].state != state else {
                    return
                }

                grid[coordinate].state = state
                entries.markTilePending(coordinate)
            })
        }

        return grid
    }

    /// Marks columns/rows of a grid as pending checks.
    private class PendingCheckList {
        private var columns: [Bool]
        private var rows: [Bool]

        /// Returns `true` if all columns and rows on this check list are satisfied.
        var hasPendingChecks: Bool {
            columns.contains { $0 } || rows.contains { $0 }
        }

        init(columnCount: Int, rowCount: Int) {
            columns = .init(repeating: false, count: columnCount)
            rows = .init(repeating: false, count: rowCount)
        }

        convenience init(grid: PatternGrid) {
            self.init(columnCount: grid.columns, rowCount: grid.rows)
        }

        func forEachPendingColumn(_ closure: (_ column: Int) throws -> Void) rethrows {
            for (i, column) in columns.enumerated() where column {
                try closure(i)
            }
        }

        func forEachPendingRow(_ closure: (_ row: Int) throws -> Void) rethrows {
            for (i, row) in rows.enumerated() where row {
                try closure(i)
            }
        }

        /// Marks all rows/columns as satisfied.
        func satisfyAll() {
            columns = columns.map { _ in false }
            rows = rows.map { _ in false }
        }

        /// Marks a given column index as satisfied
        func satisfyColumn(_ column: Int) {
            columns[column] = false
        }

        /// Marks a given row index as satisfied
        func satisfyRow(_ row: Int) {
            rows[row] = false
        }

        /// Marks a tile as pending a check.
        func markTilePending(column: Int, row: Int) {
            columns[column] = true
            rows[row] = true
        }

        /// Marks a tile as pending a check.
        func markTilePending(_ coordinate: PatternGrid.CoordinateType) {
            markTilePending(column: coordinate.column, row: coordinate.row)
        }

        /// Marks the whole set of columns and rows as pending.
        func markGridPending() {
            columns = columns.map { _ in true }
            rows = rows.map { _ in true }
        }
    }
}
