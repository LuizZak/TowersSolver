/// Solver for a Net game
public final class Solver {
    private(set) public var grid: Grid
    
    public init(grid: Grid) {
        self.grid = grid
    }
    
    /// Attempts to solve the grid for this solver, returning a boolean value
    /// indicating whether the solve attempt succeeded.
    public func solve() -> Bool {
        return false
    }
}

extension Solver {
    
}

private class SolverInvocation: NetSolverDelegate {
    var steps: [NetSolverStep] = []
    
    /// Apply all currently enqueued solver steps
    func apply(on grid: Grid) -> SolverInvocationResult {
        var grid = grid
        
        while !steps.isEmpty {
            let step = steps.removeFirst()
            
            grid = step.apply(on: grid, delegate: self)
        }
        
        return SolverInvocationResult(state: .unsolved, grid: grid)
    }
    
    func enqueue(_ step: NetSolverStep) {
        steps.append(step)
    }
    
    struct SolverInvocationResult {
        var state: ResultState
        var grid: Grid
    }
    
    enum ResultState {
        case solved
        case unsolved
        case invalid
    }
}
