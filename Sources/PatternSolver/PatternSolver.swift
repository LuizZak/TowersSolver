import Commons
import Interval

public class PatternSolver: GameSolverType {
    private(set) public var state: SolverState
    private(set) public var grid: PatternGrid

    public init(grid: PatternGrid) {
        self.grid = grid
        state = .unsolved
    }

    public func solve() -> SolverState {
        while state != .unsolvable {
            let newGrid = analyzeGrid(grid: grid)
            if newGrid == grid {
                break
            }

            grid = newGrid
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

    func analyzeGrid(grid: PatternGrid) -> PatternGrid {
        var grid = grid

        runStepAcrossLines(grid) { (hint, tiles, coord) in
            let tileFitter = TileFitter(hint: hint, tiles: tiles)

            // Mark leading/trailing tiles that are guaranteed to be light
            if let earliestDarkTile = tileFitter.earliestDarkTile(), earliestDarkTile > 0 {
                for index in 0..<earliestDarkTile {
                    grid[coord(index)].state = .light
                }
            }
            if let latestDarkTile = tileFitter.latestDarkTile(), latestDarkTile < tiles.count - 1 {
                for index in (latestDarkTile + 1)..<tiles.count {
                    grid[coord(index)].state = .light
                }
            }

            // Mark tiles from overlapping ranges as dark
            let overlaps = tileFitter.overlappingIntervals()
            for case let (i, overlap?) in overlaps.enumerated() {
                for index in overlap.start...overlap.end {
                    grid[coord(index)].state = .dark
                }

                // For overlaps that match the exact hint length, surround dark
                // tiles with light tiles
                let run = hint.runs[i]
                if (overlap.start...overlap.end).count == run {
                    if overlap.start > 0 {
                        grid[coord(overlap.start - 1)].state = .light
                    }
                    if overlap.end < tiles.count - 1 {
                        grid[coord(overlap.end + 1)].state = .light
                    }
                }
            }

            // If the dark tile count match the required hints, mark remaining
            // tiles as light
            if hint.requiredDarkTiles == tiles.darkTileCount() {
                for index in 0..<tiles.count {
                    if tiles[index].state != .dark {
                        grid[coord(index)].state = .light
                    }
                }
            }

            // Conversely, if the required dark tile space matches the available
            // undecided space, fill the undecided tiles as dark
            if hint.requiredDarkTiles == tiles.darkTileCount() + tiles.undecidedTileCount() {
                for index in 0..<tiles.count {
                    if tiles[index].state == .undecided {
                        grid[coord(index)].state = .dark
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
                    guard latestCurrent.end < earliestNext.start else {
                        continue
                    }

                    for lightIndex in (latestCurrent.end + 1)..<earliestNext.start {
                        grid[coord(lightIndex)].state = .light
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
                    grid[coord(index)].state = .dark
                }
            }
        }

        return grid
    }

    /// Runs a given closure for each solution direction (column, row)
    /// passing in the hint and the array of tiles for each direction.
    ///
    /// Also provides a closure that when fed an index, returns a proper
    /// coordinate for the tile at the given index on the column/row that
    /// it belongs.
    private func runStepAcrossLines(
        _ grid: PatternGrid,
        _ step: (
            _ hint: PatternGrid.RunsHint, _ tiles: [PatternTile], _ convertCoord: (_ index: Int) -> PatternGrid.CoordinateType
        ) throws -> Void
    ) rethrows {
        for column in 0..<grid.columns {
            let hint = grid.hintForColumn(column)

            try step(hint, grid[column: column], { PatternGrid.CoordinateType(column: column, row: $0) })
        }

        for row in 0..<grid.rows {
            let hint = grid.hintForRow(row)

            try step(hint, grid.tilesInRow(row), { PatternGrid.CoordinateType(column: $0, row: row) })
        }
    }
}
