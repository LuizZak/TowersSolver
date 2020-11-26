class SolverInvocation {
    var steps: [NetSolverStep] = []
    var grid: Grid
    var metadata: GridMetadata
    var isValid = false
    
    init(grid: Grid) {
        self.grid = grid
        self.metadata = GridMetadata(forGrid: grid)
    }
    
    /// Apply all currently enqueued solver steps
    func apply() -> SolverInvocationResult {
        while !steps.isEmpty && isValid {
            let step = steps.removeFirst()
            
            grid = step.apply(on: grid, delegate: self)
        }
        
        let state: ResultState
        
        if isValid {
            state = NetGridController(grid: grid).isSolved ? .solved : .unsolved
        } else {
            state = .invalid
        }
        
        return SolverInvocationResult(state: state, grid: grid)
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
    func markIsInvalid() {
        isValid = false
    }
    
    func enqueue(_ step: NetSolverStep) {
        steps.append(step)
    }
}
