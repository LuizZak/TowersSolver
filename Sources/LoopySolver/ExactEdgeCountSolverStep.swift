/// A simple solver step that marks edges of faces which have exactly the same
/// number of non-disabled edges as their hint as being part of the solution.
///
/// This step also marks remaining edges of faces that are already solved as disabled.
public class ExactEdgeCountSolverStep: SolverStep {
    public func apply(to field: LoopyField) -> LoopyField {
        let controller = LoopyFieldController(field: field)
        
        for face in field.faceIds {
            let edges = field.edges(forFace: face)
            
            if field.isFaceSolved(face) && !edges.contains(where: { field.edgeState(forEdge: $0) == .normal }) {
                continue
            }
            
            let enabledEdges = edges.filter { field.edgeState(forEdge: $0).isEnabled }
            
            if enabledEdges.count == field.hintForFace(face) {
                controller.setEdges(state: .marked, forEdges: enabledEdges)
                continue
            }
            
            let markedEdges = edges.filter { field.edgeState(forEdge: $0) == .marked }
            let normalEdges = edges.filter { field.edgeState(forEdge: $0) == .normal }
            
            if markedEdges.count == field.hintForFace(face) {
                controller.setEdges(state: .disabled, forEdges: normalEdges)
            }
        }
        
        return controller.field
    }
}
