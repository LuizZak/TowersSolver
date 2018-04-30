/// Solver step that looks for any face that has an isolated number of edges that
/// can be inferred as the only solution for the cell.
///
/// E.g. on the following grid:
///
/// ```
/// •───•───•───•
/// │   │ 2 │   │
/// •───•───•───•
/// ║   │ 3 │   ║
/// •   •───•   •
/// ║ 2       2 ║
/// •═══•═══•═══•
/// ```
/// The center cell which requires three edges must have its left, bottom and
/// right edges marked as part of the solution.
public class SinglePathSolverStep: SolverStep {
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
        for face in field.faceIds {
            applyToFace(face)
        }
    }
    
    func applyToFace(_ faceId: Face.Id) {
        let face = field.faceWithId(faceId)
        if field.isFaceSolved(face) {
            return
        }
        
        guard let hint = face.hint else {
            return
        }
        
        // Collect edges
        var edgeRuns: [[Edge.Id]] = []
        
        for edge in face.localToGlobalEdges {
            if edgeRuns.contains(where: { $0.contains(edge) }) {
                continue
            }
            
            let path = GraphUtils.singlePathEdges(in: field, fromEdge: edge)
            edgeRuns.append(path.compactMap(field.edgeId(forEdge:)))
        }
        
        guard !edgeRuns.isEmpty else {
            return
        }
        
        edgeRuns.sort(by: { $0.count > $1.count })
        
        if edgeRuns[0].count == hint && face.edgesCount - edgeRuns[0].count < hint {
            controller.setEdges(state: .marked, forEdges: edgeRuns[0])
        }
    }
}
