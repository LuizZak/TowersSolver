import Commons

public class PatternSolver: GameSolverType {
    private var _pending: Set<PendingCheckEntry> = []

    private(set) public var state: SolverState
    private(set) public var grid: PatternGrid

    public init(grid: PatternGrid) {
        self.grid = grid
        state = .unsolved

        _pending = PendingCheckEntry.forGrid(grid)
    }

    @discardableResult
    public func solve() -> SolverState {
        while state == .unsolved && !_pending.isEmpty {
            (grid, _pending) = PatternSolver.analyzeGrid(grid: grid, entries: _pending)
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
        entries: Set<PendingCheckEntry>
    ) -> (PatternGrid, Set<PendingCheckEntry>) {

        let result = runStepAcrossLines(grid, entries: entries) { (hint, tiles, setState) in
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
        entries: Set<PendingCheckEntry>,
        _ step: (
            _ hint: PatternGrid.RunsHint,
            _ tiles: [PatternTile],
            _ setState: (_ index: Int, _ state: PatternTile.State) -> Void
        ) throws -> Void
    ) rethrows -> (PatternGrid, Set<PendingCheckEntry>) {

        var grid = grid
        var newChecks: Set<PendingCheckEntry> = []

        for entry in entries {
            switch entry {
            case .row(let row):
                let hint = grid.hintForRow(row)

                try step(hint, grid.tilesInRow(row), { (index, state) in
                    let coordinate = PatternGrid.CoordinateType(column: index, row: row)

                    guard grid[coordinate].state != state else {
                        return
                    }

                    grid[coordinate].state = state
                    newChecks.formUnion(PendingCheckEntry.forCoordinate(coordinate, grid: grid))
                })

            case .column(let column):
                let hint = grid.hintForColumn(column)

                try step(hint, grid.tilesInColumn(column), { (index, state) in
                    let coordinate = PatternGrid.CoordinateType(column: column, row: index)

                    guard grid[coordinate].state != state else {
                        return
                    }

                    grid[coordinate].state = state
                    newChecks.formUnion(PendingCheckEntry.forCoordinate(coordinate, grid: grid))
                })
            }
        }

        return (grid, newChecks)
    }

    /// Specifies a row or column to check next after it has been modified.
    private enum PendingCheckEntry: Hashable {
        case row(Int)
        case column(Int)

        static func forGrid(_ grid: PatternGrid) -> Set<Self> {
            if grid.rows == 0 || grid.columns == 0 {
                return []
            }

            return Self
                .forWholeColumn(0, grid: grid)
                .union(Self.forWholeRow(0, grid: grid))
        }

        static func forWholeColumn(_ column: Int, grid: PatternGrid) -> Set<Self> {
            var result: Set<Self> = []

            for row in 0..<grid.rows {
                result.insert(.row(row))
            }

            return result
        }

        static func forWholeRow(_ row: Int, grid: PatternGrid) -> Set<Self> {
            var result: Set<Self> = []

            for column in 0..<grid.columns {
                result.insert(.column(column))
            }

            return result
        }

        static func forTile(column: Int, row: Int, grid: PatternGrid) -> Set<Self> {
            var result: Set<Self> = []

            if grid.columnContainsState(column, state: .undecided) {
                result.insert(.column(column))
            }
            if grid.rowContainsState(row, state: .undecided) {
                result.insert(.row(row))
            }

            return result
        }

        static func forCoordinate(_ coordinate: PatternGrid.CoordinateType, grid: PatternGrid) -> Set<Self> {
            forTile(column: coordinate.column, row: coordinate.row, grid: grid)
        }
    }
}
