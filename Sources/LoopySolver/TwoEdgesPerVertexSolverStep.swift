/// A solver step that looks for vertices which feature two marked edges and marks
/// all remaining edges as not part of the solution (since these would result in
/// an intersecting loopy line at that vertex)
public class TwoEdgesPerVertexSolverStep: SolverStep {
    public func apply(to field: LoopyField) -> LoopyField {
        let controller = LoopyFieldController(field: field)
        
        for vertex in 0..<field.vertices.count {
            let edgeIds = field.edgesSharing(vertexIndex: vertex)
            let edges = edgeIds.edges(in: field)
            let marked = edges.count { $0.state == .marked }
            
            if marked == 2 {
                let toDisable = edges.filter { $0.state != .marked }
                controller.setEdges(state: .disabled, forEdges: toDisable)
            }
        }
        
        return controller.field
    }
}
