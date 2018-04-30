/// Solves field cells that are on a corner in two scenarios:
///
/// 1. When the number of required edges shared amongst other cells is smaller
/// than the required solution of the cell.
///
/// This indicates that the cell's outer edges are all part of the solution.
///
/// This only works for cells that have a single sequential number of edges that
/// are outside the graph and not connected to other faces.
///
/// 2. When the number of required edges exceeds edges not shared with another
/// face.
///
/// In this case, the outer edges cannot be part of the solution, since their
/// singular path would exceed the solution of the face.
public class CornerSolverStep: SolverStep {
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
        for id in field.faceIds {
            applyToFace(id)
        }
    }
    
    func applyToFace(_ faceId: Face.Id) {
        let face = field.faceWithId(faceId)
        
        // Requires hint!
        guard let hint = face.hint else {
            return
        }
        
        // Detect sequential edges that exceed the required number for the face
        for edge in face.localToGlobalEdges {
            let edges =
                GraphUtils.singlePathEdges(in: field, fromEdge: edge)
                    .filter { field.faceContainsEdge(face: face, edge: $0) }
            
            if edges.count > hint {
                controller.setEdges(state: .disabled, forEdges: edges)
            }
        }
        
        let nonShared = controller.nonSharedEdges(forFace: faceId)
        
        // Can only solve when the non-shared edges form a single sequential line
        // across the outer side of the face
        if !nonShared.edges(in: field).isUniqueSegment {
            return
        }
        
        // If the number of edges that are shared ammount to less than the required
        // edges for the solution, this means that all outer edges are part of the
        // solution, since at least one of the outer edges will have to be marked
        // to be part of the solution, and if a single outer edge is marked, all
        // outer edges must be marked due to them forming a single continuous line.
        if face.edgesCount - nonShared.count < hint {
            controller.setEdges(state: .marked, forEdges: nonShared)
        }
    }
}
