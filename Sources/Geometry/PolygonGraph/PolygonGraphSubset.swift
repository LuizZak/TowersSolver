/// A subset of faces of a `PolygonGraph`.
public struct PolygonGraphSubset<Graph: PolygonGraph> {
    public typealias EdgeId = Graph.EdgeId
    public typealias FaceId = Graph.FaceId

    /// The graph that this object is a subset of.
    public let graph: Graph

    /// A collection of face IDs from the `PolygonGraph` that this subset was
    /// created from.
    public var faces: Set<FaceId>

    @usableFromInline
    internal init(graph: Graph, faces: Set<FaceId>) {
        self.graph = graph
        self.faces = faces
    }

    /// Returns `true` if the given face ID is contained within this subset.
    @inlinable
    public func containsFace(_ faceId: FaceId) -> Bool {
        faces.contains(faceId)
    }

    /// Returns `true` if the given edge ID belongs to one of the faces of this
    /// subset.
    @inlinable
    public func containsEdge(_ edgeId: EdgeId) -> Bool {
        faces.contains { face in
            graph.faceContainsEdge(face: face, edge: edgeId)
        }
    }

    /// Returns `true` if any of the faces from this subset contain a given vertex
    /// index in the underlying graph.
    @inlinable
    public func containsVertexIndex(_ vertexIndex: Int) -> Bool {
        faces.contains { face in
            graph.faceContainsVertex(face: face, vertex: vertexIndex)
        }
    }

    /// Returns a new polygon graph subset that is the combination of the faces
    /// in `self` and `other`.
    ///
    /// - precondition: `self` and `other` are subsets of the same graph.
    @inlinable
    public func combined(with other: Self) -> Self {
        .init(graph: graph, faces: faces.union(other.faces))
    }

    /// Returns a list of edges that are shared between `self.faces` and
    /// `other.faces`.
    ///
    /// Returns an empty set if no faces from `self` neighbor `other`.
    ///
    /// Return is undefined if the networks share one or more faces.
    ///
    /// - precondition: `self` and `other` are subsets of the same graph.
    @inlinable
    public func neighboringEdges(to other: Self) -> Set<EdgeId> {
        var result: Set<Graph.EdgeId> = []

        for face in faces {
            for otherFace in other.faces {
                if let shared = graph.sharedEdge(between: face, otherFace) {
                    result.insert(shared)
                }
            }
        }

        return result
    }
}

extension PolygonGraphSubset: Equatable {
    /// - note: Assumes that the subsets belong to the same graph object.
    @inlinable
    public static func == (
        lhs: PolygonGraphSubset<Graph>,
        rhs: PolygonGraphSubset<Graph>
    ) -> Bool {
        lhs.faces == rhs.faces
    }
}

extension PolygonGraphSubset: Hashable {
    /// - note: Hashing does not differentiate between subsets of equal face IDs
    /// but of different graphs.
    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(faces)
    }
}
