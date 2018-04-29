import Geometry

/// Provides support for higher-level operations on a loopy grid
public class LoopyGridController {
    public var grid: LoopyGrid
    
    public init(grid: LoopyGrid) {
        self.grid = grid
    }
    
    public func setAllEdges(state: Edge.State) {
        for i in 0..<grid.edges.count {
            grid.edges[i].state = state
        }
    }
    
    public func setEdges(state: Edge.State, forFace id: Face.Id) {
        for edge in grid.edgeIds(forFace: id) {
            grid.edges[edge.value].state = state
        }
    }
    
    public func setEdges(state: Edge.State, forEdges edges: [Edge.Id]) {
        for edge in edges {
            grid.edges[edge.value].state = state
        }
    }
    
    public func setEdges(state: Edge.State, forEdges edges: [Edge]) {
        for edge in edges {
            if let id = grid.edgeIndex(vertex1: edge.start, vertex2: edge.end) {
                grid.edges[id.value].state = state
            }
        }
    }
    
    public func setEdge(state: Edge.State, forFace faceId: Face.Id, edgeIndex: Int) {
        let edgeId = grid.faceWithId(faceId).localToGlobalEdges[edgeIndex]
        
        grid.edges[edgeId.value].state = state
    }
    
    /// Returns an array of all edges of a face on a grid that are not shared with
    /// any other face.
    public func nonSharedEdges(forFace faceId: Face.Id) -> [Edge.Id] {
        return grid.edgeIds(forFace: faceId).filter { edge in
            grid.facesSharing(edgeId: edge) == [faceId]
        }
    }
}
