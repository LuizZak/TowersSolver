class SolverInvocation {
    var steps: [NetSolverStep] = []
    var grid: Grid
    
    init(grid: Grid) {
        self.grid = grid
    }
    
    /// Apply all currently enqueued solver steps
    func apply() -> SolverInvocationResult {
        while !steps.isEmpty {
            let step = steps.removeFirst()
            
            grid = step.apply(on: grid, delegate: self)
        }
        
        return SolverInvocationResult(state: .unsolved, grid: grid)
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

extension SolverInvocation: NetSolverDelegate {
    func enqueue(_ step: NetSolverStep) {
        steps.append(step)
    }
}
