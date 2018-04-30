import Geometry

/// Provides support for higher-level operations on a loopy field
public class LoopyFieldController {
    public var field: LoopyField
    
    public init(field: LoopyField) {
        self.field = field
    }
    
    public func setAllEdges(state: Edge.State) {
        for i in 0..<field.edges.count {
            field.edges[i].state = state
        }
    }
    
    public func setEdges(state: Edge.State, forFace id: Face.Id) {
        for edge in field.edgeIds(forFace: id) {
            field.edges[edge.value].state = state
        }
    }
    
    public func setEdges(state: Edge.State, forEdges edges: [Edge.Id]) {
        for edge in edges {
            field.edges[edge.value].state = state
        }
    }
    
    public func setEdges(state: Edge.State, forEdges edges: [Edge]) {
        for edge in edges {
            if let id = field.edgeIndex(vertex1: edge.start, vertex2: edge.end) {
                field.edges[id.value].state = state
            }
        }
    }
    
    public func setEdge(state: Edge.State, forFace faceId: Face.Id, edgeIndex: Int) {
        let edgeId = field.faceWithId(faceId).localToGlobalEdges[edgeIndex]
        
        field.edges[edgeId.value].state = state
    }
    
    /// Returns an array of all edges of a face on a field that are not shared with
    /// any other face.
    public func nonSharedEdges(forFace faceId: Face.Id) -> [Edge.Id] {
        return field.edgeIds(forFace: faceId).filter { edge in
            field.facesSharing(edgeId: edge) == [faceId]
        }
    }
}
