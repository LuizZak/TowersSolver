/// Solver for a Loopy match
public class Solver {
    public var grid: LoopyGrid
    private var steps: [SolverStep] = []
    
    /// Returns `true` if the solution requirements are met on this solver's grid.
    ///
    /// Requirements for the grid to be considered solved:
    ///
    /// 1. A single, non-intersecting loop must be present on the grid by means
    /// marked edges. All marked edges must form a continuous loop.
    ///
    /// 2. All numbered faces must have that number of their edges marked as part
    /// of the solution.
    public var isSolved: Bool {
        let markedEdges = grid.edges.filter { $0.state == .marked }
        if !markedEdges.isLoop {
            return false
        }
        
        for faceId in grid.faceIds {
            guard let hint = grid.faceWithId(faceId).hint else { continue }
            
            let marked = grid.edgeIds(forFace: faceId).edges(in: grid).filter { $0.state == .marked }
            
            if marked.count != hint {
                return false
            }
        }
        
        return true
    }
    
    public init(grid: LoopyGrid) {
        self.grid = grid
    }
    
    private func addSteps() {
        steps.append(ZeroSolverStep())
        steps.append(DeadEndRemovalSolverStep())
        steps.append(CornerSolverStep())
    }
    
    public func solve() -> Result {
        // Keep applying passes until the grid no longer changes between steps
        while true {
            let newGrid = applySteps(to: grid)
            if grid == newGrid {
                break
            }
            
            grid = newGrid
        }
        
        return isSolved ? .solved : .unsolved
    }
    
    private func applySteps(to grid: LoopyGrid) -> LoopyGrid {
        var grid = grid
        for step in steps {
            grid = step.apply(to: grid)
        }
        return grid
    }
    
    public enum Result {
        case solved
        case unsolved
    }
}

public protocol SolverStep {
    func apply(to grid: LoopyGrid) -> LoopyGrid
}
