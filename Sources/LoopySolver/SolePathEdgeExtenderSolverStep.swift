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
            
            let marked = edges.count { field.edgeState(forEdge: $0) == .marked }
            
            guard marked == 1 else {
                continue
            }
            
            let enabled = edges.filter { field.edgeState(forEdge: $0) == .normal }
            
            if enabled.count == 1 {
                controller.setEdges(state: .marked, forEdges: enabled)
            }
        }
    }
}
