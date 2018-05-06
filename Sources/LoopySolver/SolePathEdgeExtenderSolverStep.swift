/// A solver step that deals with solution edges that end in vertices with a single
/// possible exit path for the marked edge.
///
/// In the following example, the marked edge ends up in a corner, with some disabled
/// edges around it:
///
///     ........
///     !__.__._ -
///        '
///
/// To satisfy the loop requirement, the line must be extended such that it connects
/// with the only possible next path:
///
///     .__.__._
///     !__.__._ -
///        '
///
public class SolePathEdgeExtenderSolverStep: SolverStep {
    public func apply(to grid: LoopyGrid, _ delegate: SolverStepDelegate) -> LoopyGrid {
        let solver = InternalSolver(grid: grid)
        solver.apply()
        
        return solver.grid
    }
}

private class InternalSolver {
    var controller: LoopyGridController
    
    var grid: LoopyGrid {
        return controller.grid
    }
    
    init(grid: LoopyGrid) {
        controller = LoopyGridController(grid: grid)
    }
    
    func apply() {
        while true {
            let before = grid
            
            applyInternal()
            
            if before == grid {
                return
            }
        }
    }
    
    private func applyInternal() {
        for i in 0..<grid.vertices.count {
            let edges = grid.edgesSharing(vertexIndex: i)
            
            let marked = edges.count { grid.edgeState(forEdge: $0) == .marked }
            
            guard marked == 1 else {
                continue
            }
            
            let enabled = edges.filter { grid.edgeState(forEdge: $0) == .normal }
            
            if enabled.count == 1 {
                controller.setEdges(state: .marked, forEdges: enabled)
            }
        }
    }
}
