import Commons

/// Common protocol to abstract face references between actual face structures and
/// face IDs.
public protocol FaceReferenceConvertible {
    var id: Face.Id { get }
}

/// Represents a loopy game's geometric face, which is just a list of reference
/// to vertices on the game map, joined in a loop. The face also features an
/// optional number specifying how many of its edges belong to the solution.
///
/// A vertex may be shared by one or more faces, and an edge may be shared between
/// one or two faces.
///
/// Vertices of faces are always concave and never intersect, neither with other
/// faces nor with themselves.
public struct Face: Equatable {
    public typealias Id = Key<Face, Int>

    public var id: Face.Id

    /// Indices of vertices that make up this face
    public let indices: [Int]

    /// Maps local edges from 0 to n edges to global edge index on the grid this
    /// face is located in.
    ///
    /// Each index on this array represents the 0th to edge-count edge within
    /// this face, and the value within the index, the global edge index.
    public let localToGlobalEdges: [Edge.Id]

    /// The hint that describes the number of edges on this face that are part
    /// of the solution of the grid.
    public var hint: Int?

    /// Returns the number of edges that form this face
    @inlinable
    public var edgesCount: Int {
        return localToGlobalEdges.count
    }

    /// Returns `true` if this face is semi-complete.
    ///
    /// A semi-complete face has a hint number matching the number of edges of
    /// the face minus one, thus requiring all but one edge of the face to be
    /// marked as part of the solution.
    @inlinable
    public var isSemiComplete: Bool {
        return hint == edgesCount - 1
    }

    /// Returns `true` if this face contains a given edge id
    @inlinable
    public func containsEdge(id: Edge.Id) -> Bool {
        return localToGlobalEdges.contains(id)
    }
}

extension Int: FaceReferenceConvertible {
    @inlinable
    public var id: Face.Id {
        return Face.Id(self)
    }
}

extension Key: FaceReferenceConvertible where T == Face, U == Int {
    @inlinable
    public var id: Face.Id {
        return self
    }
}
