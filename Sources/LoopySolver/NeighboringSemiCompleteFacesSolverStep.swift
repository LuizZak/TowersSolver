/// Solver step that deals with cases of semi-complete (`hint == edge_count - 1`)
/// faces that touch either edge-wise or across corners via a common vertex.
public class NeighboringSemiCompleteFacesSolverStep: SolverStep {
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
        // Collect pairs of semi-complete faces to work on
        let pairs = collect()
        
        for pair in pairs {
            apply(to: pair)
        }
    }
    
    private func collect() -> [FacePair] {
        var pairs: [FacePair] = []
        
        let semifaces = controller.semiCompleteFaces()
        
        for i in 0..<semifaces.count - 1 {
            let semi1 = semifaces[i].face(in: field)
            if field.isFaceSolved(semi1) {
                continue
            }
            
            for j in i + 1..<semifaces.count {
                let semi2 = semifaces[j].face(in: field)
                if field.isFaceSolved(semi2) {
                    continue
                }
                
                // Test for a shared edge
                if let edge = field.sharedEdge(between: semi1, semi2) {
                    pairs.append(FacePair(face1: semi1, face2: semi2, sharing: .edge(edge.edge(in: field))))
                    continue
                }
                
                // Test for a shared vertex
                let vertices = field.sharedVertices(between: semi1, semi2)
                if vertices.count == 1 {
                    pairs.append(FacePair(face1: semi1, face2: semi2, sharing: .vertex(vertices[0])))
                }
            }
        }
        
        return pairs
    }
    
    private func apply(to pair: FacePair) {
        
        switch pair.sharing {
        case .edge(let shared):
            controller.setEdge(state: .marked, forEdge: shared)
            
            // Mark all opposing edges from the shared edge on both faces
            for edge in pair.face1.localToGlobalEdges.map(field.edgeWithId) {
                if !edge.sharesVertex(with: shared) {
                    controller.setEdge(state: .marked, forEdge: edge)
                }
            }
            for edge in pair.face2.localToGlobalEdges.map(field.edgeWithId) {
                if !edge.sharesVertex(with: shared) {
                    controller.setEdge(state: .marked, forEdge: edge)
                }
            }
            
            // Now take the shared edge's vertices and disable any other edge that
            // shares those vertices, and is not part of either of the paired faces
            var otherEdges =
                field.edgesSharing(vertexIndex: shared.start)
                    + field.edgesSharing(vertexIndex: shared.end)
            
            otherEdges = otherEdges.filter { edge in
                !pair.face1.containsEdge(id: edge) && !pair.face2.containsEdge(id: edge)
            }
            
            controller.setEdges(state: .disabled, forEdges: otherEdges)
            
        case .vertex(let vertex):
            // Set all oposed edges to the vertex on the two faces as marked
            let edges1 =
                pair.face1.localToGlobalEdges
                    .edges(in: field)
                    .filter { !$0.sharesVertex(vertex) }
            
            let edges2 =
                pair.face2.localToGlobalEdges
                    .edges(in: field)
                    .filter { !$0.sharesVertex(vertex) }
            
            controller.setEdges(state: .marked, forEdges: edges1)
            controller.setEdges(state: .marked, forEdges: edges2)
        }
    }
    
    private struct FacePair {
        var face1: Face
        var face2: Face
        
        var sharing: SharedElement
        
        enum SharedElement {
            case edge(Edge)
            case vertex(Int)
        }
    }
}
