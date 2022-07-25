/// A solver for a Signpost game
public class Solver {
    private(set) public var grid: Grid

    private let connectionsGridGraph: GridGraph
    private var solutionGridGraph: GridGraph

    /// Returns `true` if the for this solver is in a valid state and solved.
    ///
    /// For a Signpost grid, the grid is valid and solved when all conditions
    /// apply:
    ///
    /// - 1- All tiles are numbered, from 1 to `grid.tileCount`, with each number
    /// showing up exactly once.
    /// - 2- Each numbered tile N, except for the hightest tile number, must have
    /// its subsequent tile numbered N+1 in the direction of its arrow in the
    /// grid.
    public var isSolved: Bool {
        _isSolved()
    }

    public init(grid: Grid) {
        self.grid = grid

        connectionsGridGraph = .fromGrid(grid)
        solutionGridGraph = .fromGrid(grid, connectNodes: false)
    }

    public func solve() {
        
    }

    private func _isSolved() -> Bool {
        // Check that each tile is pointing to its successor
        outerLoop:
        for tileCoord in grid.tileCoordinates {
            let tile = grid[tileCoord]
            if tile.isEndTile {
                if tile.solution != grid.tileCount {
                    return false
                }

                continue
            }
            if tile.isStartTile && tile.solution != 1 {
                return false
            }

            guard let solution = tile.solution else {
                return false
            }

            let nextCoords = grid.tileCoordsPointedBy(column: tileCoord.column, row: tileCoord.row)
            
            for next in nextCoords {
                let nextTile = grid[next]

                if nextTile.solution == solution + 1 {
                    continue outerLoop
                }
            }

            // No successor found!
            return false
        }

        return true
    }
}
