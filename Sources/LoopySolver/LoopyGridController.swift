import Geometry

/// Provides support for higher-level operations on a loopy grid
public class LoopyGridController {
    public var grid: LoopyGrid
    
    public init(grid: LoopyGrid) {
        self.grid = grid
    }
    
    /// Gets a list of all semi-complete faces on the playfield.
    ///
    /// Semi-complete faces are faces which have the requirement of having
    /// edge_count - 1 edges marked as part of the solution.
    ///
    /// This would be a `2`-hint on a triangle, `3` on a square face, `4` on a
    /// pentagon, etc.
    public func semiCompleteFaces() -> [Face.Id] {
        return grid.faceIds.filter(grid.isFaceSemicomplete)
    }
    
    public func setAllEdges(state: Edge.State) {
        for e in grid.edgeIds {
            grid.withEdge(e) {
                $0.state = state
            }
        }
    }
    
    public func setEdges(state: Edge.State, forFace face: FaceReferenceConvertible) {
        setEdges(state: state, forEdges: grid.edges(forFace: face.id))
    }
    
    public func setEdges(state: Edge.State, forEdges edges: [Edge.Id]) {
        for edge in edges {
            grid.withEdge(edge) {
                $0.state = state
            }
        }
    }
    
    public func setEdges(state: Edge.State, forFace face: FaceReferenceConvertible, edgeIndices: [Int]) {
        for index in edgeIndices {
            setEdge(state: state, forFace: face.id, edgeIndex: index)
        }
    }
    
    public func setEdge(state: Edge.State, forFace face: FaceReferenceConvertible, edgeIndex: Int) {
        let edgeId = grid.edges(forFace: face.id)[edgeIndex]
        
        grid.withEdge(edgeId) {
            $0.state = state
        }
    }
    
    public func setEdge(state: Edge.State, forEdge edge: Int) {
        setEdge(state: state, forEdge: Edge.Id(edge))
    }
    
    public func setEdge(state: Edge.State, forEdge edge: EdgeReferenceConvertible) {
        grid.withEdge(edge) {
            $0.state = state
        }
    }
    
    /// Returns an array of all edges of a face on a grid that are not shared with
    /// any other face.
    public func nonSharedEdges(forFace face: FaceReferenceConvertible) -> [Edge.Id] {
        return grid.edges(forFace: face.id).filter { edge in
            grid.facesSharing(edge: edge) == [face.id]
        }
    }
}
