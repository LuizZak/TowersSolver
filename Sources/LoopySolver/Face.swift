import Commons

/// Represents a loopy game's geometric face, which is just a list of reference
/// to vertices on the game map, joined in a loop. The face also features an
/// optional number specifying how many of its edges belong to the solution.
///
/// A vertex may be shared by one or more faces, and an edge may be shared between
/// one or two faces.
///
/// Vertice of faces are always concave and never intersect, neither with other
/// faces nor with themselves.
public struct Face: Equatable {
    public typealias Id = Key<Face, Int>
    
    /// Indices of vertices that make up this face
    public var indices: [Int]
    
    /// Maps local edges from 0 to n edges to global edge index on the field this
    /// face is located in.
    ///
    /// Each index on this array represents the 0th to edge-count edge within
    /// this face, and the value within the index, the global edge index.
    public var localToGlobalEdges: [Edge.Id]
    
    /// The hint that describes the number of edges on this face that are part
    /// of the solution of the field.
    public var hint: Int?
    
    /// Returns the number of edges that form this face
    public var edgesCount: Int {
        return localToGlobalEdges.count
    }
    
    /// Returns `true` if this face contains a given edge id
    public func containsEdge(id: Edge.Id) -> Bool {
        return localToGlobalEdges.contains(id)
    }
    
    /// Returns an array of local edge indices for this face based on a given list
    /// of global edge indices.
    public func toLocalEdges(_ edges: [Edge.Id]) -> [Int] {
        return edges.compactMap { edge in
            localToGlobalEdges.enumerated().first {
                $0.element == edge
            }.map {
                $0.offset
            }
        }
    }
}

public extension Sequence where Element == Edge.Id {
    /// Returns an array of local edge indices for a given face based on this
    /// sequence of global edge indices.
    public func toLocalEdges(inFace face: Face) -> [Int] {
        return face.toLocalEdges(self.map { $0 })
    }
}
