/// Detects and removes deadends of edges that connect to vertices that don't have
/// another valid edge to connect to.
///
/// For example, on the following field, the top-left edge was marked as disabled
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
    public func apply(to field: LoopyField) -> LoopyField {
        let solver = InternalSolver(field: field)
        solver.apply()
        
        return solver.field
    }
}

private class InternalSolver {
    var controller: LoopyFieldController
    
    var field: LoopyField {
        return controller.field
    }
    
    init(field: LoopyField) {
        controller = LoopyFieldController(field: field)
    }
    
    func apply() {
        while true {
            let before = field
            
            applyInternal()
            
            if before == field {
                return
            }
        }
    }
    
    private func applyInternal() {
        for i in 0..<field.vertices.count {
            let edges = field.edgesSharing(vertexIndex: i)
            
            let enabled = edges.filter({ field.edgeState(forEdge: $0).isEnabled })
            
            if enabled.count == 1 {
                controller.setEdges(state: .disabled, forEdges: enabled)
            }
        }
    }
}
