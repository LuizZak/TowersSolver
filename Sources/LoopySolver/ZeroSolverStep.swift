/// Trivial solver step that unmarks the edges of every zero-hinted cell.
public class ZeroSolverStep: SolverStep {
    public func apply(to field: LoopyField) -> LoopyField {
        let controller = LoopyFieldController(field: field)
        
        for faceId in field.faceIds where field.hintForFace(faceId) == 0 {
            controller.setEdges(state: .disabled, forFace: faceId)
        }
        
        return controller.field
    }
}
