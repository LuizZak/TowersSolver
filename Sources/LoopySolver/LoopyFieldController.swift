import Geometry

/// Provides support for higher-level operations on a loopy field
public class LoopyFieldController {
    public var field: LoopyField
    
    public init(field: LoopyField) {
        self.field = field
    }
    
    /// Gets a list of all semi-complete faces on the playfield.
    ///
    /// Semi-complete faces are faces which have the requirement of having
    /// edge_count - 1 edges marked as part of the solution.
    ///
    /// This would be a `2`-hint on a triangle, `3` on a square face, `4` on a
    /// pentagon, etc.
    public func semiCompleteFaces() -> [Face.Id] {
        return field.faceIds.filter { id in
            field.faceWithId(id).isSemiComplete
        }
    }
    
    public func setAllEdges(state: Edge.State) {
        for e in field.edges {
            field.withEdge(e) {
                $0.state = state
            }
        }
    }
    
    public func setEdges(state: Edge.State, forFace face: FaceReferenceConvertible) {
        setEdges(state: state, forEdges: field.edges(forFace: face))
    }
    
    public func setEdges(state: Edge.State, forEdges edges: [EdgeReferenceConvertible]) {
        for edge in edges {
            field.withEdge(edge) {
                $0.state = state
            }
        }
    }
    
    // FIXME: Here since missing runtime conditional conformance checks trap the
    // program when using overload `forEdges edges: [EdgeReferenceConvertible]`
    // with `[Edge.Id]` edges.
    public func setEdges(state: Edge.State, forEdges edges: [Edge.Id]) {
        for edge in edges {
            field.withEdge(edge) {
                $0.state = state
            }
        }
    }
    
    public func setEdges(state: Edge.State, forFace face: FaceReferenceConvertible, edgeIndices: [Int]) {
        for index in edgeIndices {
            setEdge(state: state, forFace: face, edgeIndex: index)
        }
    }
    
    public func setEdge(state: Edge.State, forFace face: FaceReferenceConvertible, edgeIndex: Int) {
        let face = face.face(in: field)
        
        let edgeId = face.localToGlobalEdges[edgeIndex]
        
        field.withEdge(edgeId) {
            $0.state = state
        }
    }
    
    public func setEdge(state: Edge.State, forEdge edge: EdgeReferenceConvertible) {
        field.withEdge(edge) {
            $0.state = state
        }
    }
    
    /// Returns an array of all edges of a face on a field that are not shared with
    /// any other face.
    public func nonSharedEdges(forFace face: FaceReferenceConvertible) -> [Edge.Id] {
        return field.edges(forFace: face).filter { edge in
            field.facesSharing(edge: edge) == [face.id]
        }
    }
}
