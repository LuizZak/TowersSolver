/// Solver for a Net game
public final class Solver {
    private(set) public var grid: Grid
    public var maxGuesses: Int = 0
    
    public init(grid: Grid) {
        self.grid = grid
    }
    
    /// Attempts to solve the grid for this solver, returning a boolean value
    /// indicating whether the solve attempt succeeded.
    public func solve() -> Bool {
        let solverInvocation = SolverInvocation(grid: grid)
        solverInvocation.resetPossibleOrientationsSet()
        solverInvocation.maxGuesses = maxGuesses
        
        enqueueInitialSteps(on: solverInvocation)
        
        return performSolverCycles(solverInvocation)
    }
    
    func performSolverCycles(_ solver: SolverInvocation) -> Bool {
        let result = solver.apply()
        grid = result.grid
        
        switch result.state {
        case .solved:
            return true
        case .unsolved:
            switch solver.performGuessMoves() {
            case .gridSolved(let grid):
                self.grid = grid
                return true
            
            case .gridChanged:
                return performSolverCycles(solver)
                
            case .guessesExhausted:
                return false
            }
        case .invalid:
            return false
        }
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
