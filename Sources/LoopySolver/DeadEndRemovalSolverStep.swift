/// Detects and removes deadends of edges that connect to vertices that don't have
/// another valid edge to connect to.
///
/// For example, on the following grid, the top-left edge was marked as disabled
/// and not part of the solution, and the left-most edge is now a dead end edge
/// (the line ends abruptly at the corner):
///
///     .  .__.
///     !__!__!
///
/// This step would remove the dead-end edges until all edges present point to
/// vertices with at least two valid edges:
///
///     .  .__.
///     .  !__!
///
public class DeadEndRemovalSolverStep: SolverStep {
    public func apply(to grid: LoopyGrid) -> LoopyGrid {
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
            let edgeIds = grid.edgesSharing(vertexIndex: i)
            let edges = edgeIds.edges(in: grid)
            
            let enabled = edges.filter({ $0.isEnabled })
            
            if enabled.count == 1 {
                controller.setEdges(state: .disabled, forEdges: enabled)
            }
        }
    }
}
