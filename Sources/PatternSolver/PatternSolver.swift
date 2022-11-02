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
        state = .solved

        runStepAcrossLines(grid) { (hint, tiles, coord) in
            let runs = tiles.darkTileRuns()
            let runLengths = runs.map { $0.count }

            // Demote state as certain conditions are met
            if runLengths != hint.runs && state == .solved {
                state = .unsolved
            }
            if tiles.darkTileCount() > hint.requiredDarkTiles {
                state = .invalid
            }
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
            for (i, overlap) in overlaps.enumerated() {
                guard let overlap = overlap else {
                    continue
                }

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
