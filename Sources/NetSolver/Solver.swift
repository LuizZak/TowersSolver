/// Solver for a Net game
public final class Solver {
    private(set) public var grid: Grid
    public var maxGuesses: Int = 5
    
    public init(grid: Grid) {
        self.grid = grid
    }
    
    /// Attempts to solve the grid for this solver, returning a boolean value
    /// indicating whether the solve attempt succeeded.
    public func solve() -> Bool {
        let invocation = SolverInvocation(grid: grid)
        invocation.maxGuesses = maxGuesses
        
        enqueueInitialSteps(on: invocation)
        
        let result = invocation.apply()
        grid = result.grid
        
        return result.state == .solved
    }
    
    func enqueueInitialSteps(on delegate: NetSolverDelegate) {
        for row in 0..<grid.rows {
            for column in 0..<grid.columns {
                // Enqueue barrier checks for tiles bordering barriers
                if !grid.barriersForTile(atColumn: column, row: row).isEmpty {
                    delegate.enqueue(AwayFromBarriersSolverStep(column: column, row: row))
                }
                
                // Enqueue end-point checks
                if grid[row: row, column: column].kind == .endPoint {
                    delegate.enqueue(EndPointNeighborsSolverStep(column: column, row: row))
                }
            }
        }
    }
}
