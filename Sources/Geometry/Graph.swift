import Commons

public protocol EdgeProtocol {
    var start: Int { get }
    var end: Int { get }
}

/// Describes an abstract Graph type with vertices, edges, and faces.
public protocol Graph {
    associatedtype VertexType: VectorType
    associatedtype EdgeType: EdgeProtocol

    associatedtype EdgeId: Hashable
    associatedtype FaceId: Hashable

    /// Gets the list of vertices in this Graph
    var vertices: [Vertex] { get }

    /// Returns the index for the edge of the given vertices.
    /// Detects both direction of edges.
    /// Returns `nil`, if no edge is present between the two edges.
    @inlinable
    func edgeBetween(vertex1: Int, vertex2: Int) -> EdgeId?

    /// Returns an array of all edges that share a given vertex
    @inlinable
    func edgesSharing(vertexIndex index: Int) -> [EdgeId]

    /// Returns an array of all edges that enclose a face with a given id.
    @inlinable
    func edges(forFace face: FaceId) -> [EdgeId]

    /// Returns `true` if two edges have a vertex index in common.
    @inlinable
    func edgesShareVertex(_ first: EdgeId, _ second: EdgeId) -> Bool

    /// Returns `true` if a given edge forms the side of a given face (i.e. both
    /// vertices that form the edge are vertices that form one of the sides of the
    /// face.)
    @inlinable
    func faceContainsEdge(face: FaceId, edge: EdgeId) -> Bool

    /// Returns the index of an index that matches a given vertex object.
    ///
    /// Returns nil, in case a matching vertex is not found.
    @inlinable
    func vertexIndex(_ vertex: Vertex) -> Int?

    /// Returns the index of the vertex with the given coordinates.
    ///
    /// Returns nil, in case the coordinate does not match any vertex.
    @inlinable
    func vertexIndex(x: Vertex.Coordinate, y: Vertex.Coordinate) -> Int?

    /// Returns the two vertex indices for the start/end of a given edge.
    @inlinable
    func vertices(forEdge edge: EdgeId) -> (start: Int, end: Int)

    /// From a starting edge in this graph, extract all connected edges that share
    /// a vertex in such a way that the connected vertex has only two edges connected.
    ///
    /// This essentially returns a single unambiguous path from the starting
    /// edge until it reaches a vertex that has more than a single obvious path
    /// to go through.
    ///
    /// - Parameters:
    ///   - edge: The starting edge.
    ///   - includeTest: A custom test to perform when considering edges to form
    /// the path.
    /// - Returns: A list of all single-path edges connected to the starting edge,
    /// including the starting edge itself.
    /// If the starting edge is not connected to any edges uniquely, an array with
    /// just the starting edge is returned.
    @inlinable
    func singlePathEdges(fromEdge edge: EdgeId, includeTest: (EdgeId) -> Bool) -> Set<EdgeId>

    /// Returns an array of array of path edges that form when organizing the
    /// edges of a given face into linear graphs.
    ///
    /// The array of edges returned link edges that are connected by degree 2
    /// vertices (vertices that connect only two edges).
    ///
    /// This may span across other faces, as linear paths traverse through the
    /// grid.
    @inlinable
    func linearPathGraphEdges(around face: FaceId) -> [Set<EdgeId>]

    /// Returns `true` iff each edge on a given list is directly connected to the
    /// next, forming a singular chain.
    @inlinable
    func isUniqueSegment<C: Collection>(_ edges: C) -> Bool where C.Element == EdgeId

    /// Returns `true` iff all edges in a given list are connected, and they form
    /// a loop (i.e. all edges connected start-to-end).
    @inlinable
    func isLoop<C: Collection>(_ edges: C) -> Bool where C.Element == EdgeId
}

// MARK: - Default Implementations
extension Graph {
    @inlinable
    public func vertexIndex(_ vertex: Vertex) -> Int? {
        return vertices.firstIndex(of: vertex)
    }

    @inlinable
    public func vertexIndex(x: Vertex.Coordinate, y: Vertex.Coordinate) -> Int? {
        return vertices.firstIndex { v -> Bool in
            v.x == x && v.y == y
        }
    }
}

extension Graph {
    @inlinable
    public func linearPathGraphEdges(around face: FaceId) -> [Set<EdgeId>] {
        let edges = self.edges(forFace: face)

        var edgesSet: Set<EdgeId> = []
        var edgeRuns: [Set<EdgeId>] = []

        for edge in edges {
            if edgesSet.contains(edge) {
                continue
            }

            let path = singlePathEdges(fromEdge: edge)
            edgeRuns.append(path)
            edgesSet.formUnion(path)
        }

        return edgeRuns
    }

    @inlinable
    public func singlePathEdges(fromEdge edge: EdgeId) -> Set<EdgeId> {
        return singlePathEdges(fromEdge: edge, includeTest: { _ in true })
    }

    @inlinable
    public func singlePathEdges(fromEdge edge: EdgeId, includeTest: (EdgeId) -> Bool) -> Set<EdgeId>
    {
        var stack: [(pivot: EdgeId, previous: EdgeId?)] = []

        stack = [(edge, nil)]

        var result: Set<EdgeId> = []
        var last: EdgeId? = nil

        while let top = stack.popLast() {
            let (pivot, previous) = top

            // Make sure we don't duplicate an edge in case the line forms a closed
            // loop
            if previous == edge && last == pivot {
                continue
            }

            last = pivot
            result.insert(pivot)

            let vertices = self.vertices(forEdge: pivot)

            let sharingStart = edgesSharing(vertexIndex: vertices.start)
            let sharingEnd = edgesSharing(vertexIndex: vertices.end)

            sharingEdgeIf: if sharingStart.contains(where: { $0 == pivot && includeTest($0) }) {
                guard let edges = sharingStart.onlyTwo(where: includeTest) else {
                    break sharingEdgeIf
                }

                let new = edges.first == pivot ? edges.second : edges.first

                if new != previous && !result.contains(new) {
                    stack.append((new, pivot))
                }
            }
            sharingEdgeIf: if sharingEnd.contains(where: { $0 == pivot && includeTest($0) }) {
                guard let edges = sharingEnd.onlyTwo(where: includeTest) else {
                    break sharingEdgeIf
                }

                let new = edges.first == pivot ? edges.second : edges.first

                if new != previous && !result.contains(new) {
                    stack.append((new, pivot))
                }
            }
        }

        return result
    }

    /// Returns `true` iff each edge on a given list is directly connected to the
    /// next, forming a singular chain.
    @inlinable
    public func isUniqueSegment<C: Collection>(_ edges: C) -> Bool where C.Element == EdgeId {
        if edges.count == 0 {
            return false
        }
        if edges.count == 1 {
            return true
        }

        // Take a list of all edges, pop the first edge, and check the remaining
        // list to see if an edge from the sequence is connected to it: if it is,
        // push that edge to the sequence edges and repeat for all edges until
        // either the list is empty or none of the remaining items are connected
        // to any of the edges in the sequence
        var rem = Array(edges.dropFirst())
        var seq = [edges[edges.startIndex]]

        while rem.count > 0 {
            for i in 0..<rem.count {
                let next = rem[i]

                if seq.contains(where: { edgesShareVertex($0, next) }) {
                    seq.append(next)
                    rem.remove(at: i)
                    break
                } else if i == rem.count - 1 {
                    return false
                }
            }
        }

        return true
    }

    /// Returns `true` iff all edges in a given list are connected, and they form
    /// a loop (i.e. all edges connected start-to-end).
    @inlinable
    public func isLoop<C: Collection>(_ edges: C) -> Bool where C.Element == EdgeId {
        // Minimal number of edges connected to form a loop must be 3.
        if edges.count < 3 {
            return false
        }

        // The edge list forms a loop iff every single edge is connected to exactly
        // two other edges from the input list.
        for edge in edges {
            let count = edges.count(where: { $0 != edge && edgesShareVertex($0, edge) })

            if count != 2 {
                return false
            }
        }

        return true
    }
}
