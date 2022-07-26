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
        solutionGridGraph = .fromGrid(grid, connectionMode: .connectedToProperty)
    }

    public func solve() {
        defer { _postSolve() }

        // Connect tiles that have only one entry/exit edge
        for node in connectionsGridGraph.nodes {
            let from = connectionsGridGraph.edges(from: node)
            let to = connectionsGridGraph.edges(towards: node)

            if from.count == 1 {
                let start = node
                let end = from[0].end

                solutionGridGraph.connect(start: start, end: end)
                grid[start.coordinates].connectedTo = end.coordinates
            }
            if to.count == 1 {
                let start = to[0].start
                let end = node

                solutionGridGraph.connect(start: start, end: end)
                grid[start.coordinates].connectedTo = end.coordinates
            }
        }
    }

    private func _postSolve() {
        for tileCoord in grid.tileCoordinates {
            guard grid[tileCoord].connectedTo == nil else {
                continue
            }
            
            guard let number = grid.effectiveNumberForTile(column: tileCoord.column, row: tileCoord.row) else {
                continue
            }

            let nextCoords = grid.tileCoordsPointedBy(column: tileCoord.column, row: tileCoord.row)

            for next in nextCoords {
                if grid.effectiveNumberForTile(column: next.column, row: next.row) == number + 1 {
                    solutionGridGraph.connect(start: .init(tileCoord), end: .init(next))
                    grid[tileCoord].connectionState = .connectedTo(column: next.column, row: next.row)
                    break
                }
            }
        }
    }

    private func _isSolved() -> Bool {
        let startTileCoord = grid.tileCoordinates.first {
            grid[$0].isStartTile && grid[$0].solution == 1
        }
        let endTileCoord = grid.tileCoordinates.first {
            grid[$0].isEndTile && grid[$0].solution == grid.tileCount
        }

        guard let startTileCoord = startTileCoord, let endTileCoord = endTileCoord else {
            return false
        }

        let resultGraph = GridGraph.fromGrid(grid, connectionMode: .connectedToProperty)

        let paths = resultGraph.allPaths(from: .init(startTileCoord), to: .init(endTileCoord))

        if paths.count != 1 {
            return false
        }

        let path = paths[0]

        var current = 1
        
        for node in path {
            let tile = grid[node.coordinates]

            if let solution = tile.solution, solution != current {
                return false
            }

            current += 1
        }
        
        return true
    }
}
