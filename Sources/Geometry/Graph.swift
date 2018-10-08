public protocol EdgeProtocol {
    var start: Int { get }
    var end: Int { get }
}

/// Describes an abstract Graph type
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
    func edgeBetween(vertex1: Int, vertex2: Int) -> EdgeId?
    
    /// Returns an array of all edges that share a given vertex
    func edgesSharing(vertexIndex index: Int) -> [EdgeId]
    
    /// Returns an array of all edges that enclose a face with a given id.
    func edges(forFace face: FaceId) -> [EdgeId]
    
    /// Returns `true` if two edges have a vertex index in common.
    func edgesShareVertex(_ first: EdgeId, _ second: EdgeId) -> Bool
    
    /// Returns `true` if a given edge forms the side of a given face.
    func faceContainsEdge(face: FaceId, edge: EdgeId) -> Bool
    
    /// Returns the index of an index that matches a given vertex object.
    ///
    /// Returns nil, in case a matching vertex is not found.
    func vertexIndex(_ vertex: Vertex) -> Int?
    
    /// Returns the index of the vertex with the given coordinates.
    ///
    /// Returns nil, in case the coordinate does not match any vertex.
    func vertexIndex(x: Vertex.Coordinate, y: Vertex.Coordinate) -> Int?
    
    /// Returns the two vertex indices for the start/end of a given edge.
    func vertices(forEdge edge: EdgeId) -> (start: Int, end: Int)
    
    /// From a starting edge in this graph, extract all connected edges that share
    /// a vertex in such a way that the connected vertex has only two edges connected.
    ///
    /// This essentially returns a single unambiguous path from the starting
    /// edge until it reaches a vertex that has more than a single ovious path
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
    func singlePathEdges(fromEdge edge: EdgeId, includeTest: (EdgeId) -> Bool) -> [EdgeId]
    
    /// Returns an array of array of path edges that form when organizing the
    /// edges of a given face into linear graphs.
    ///
    /// The array of edges returned link edges that are connected by degree 2
    /// vertices (vertices that connect only two edges).
    ///
    /// This may span across other faces, as linear paths traverse through the
    /// grid.
    func linearPathGraphEdges(around face: FaceId) -> [[EdgeId]]
    
    /// Returns `true` iff each edge on a given list is directly connected to the
    /// next, forming a singular chain.
    func isUniqueSegment(_ edges: [EdgeId]) -> Bool
    
    /// Returns `true` iff all edges in a given list are connected, and they form
    /// a loop (i.e. all edges connected start-to-end).
    func isLoop(_ edges: [EdgeId]) -> Bool
}

// MARK: - Default Implementations
public extension Graph {
    public func vertexIndex(_ vertex: Vertex) -> Int? {
        return vertices.index(of: vertex)
    }
    
    public func vertexIndex(x: Vertex.Coordinate, y: Vertex.Coordinate) -> Int? {
        return vertices.index { v -> Bool in
            v.x == x && v.y == y
        }
    }
}

public extension Graph {
    @inlinable
    public func linearPathGraphEdges(around face: FaceId) -> [[EdgeId]] {
        let edges = self.edges(forFace: face)
        
        var edgesSet: Set<EdgeId> = []
        var edgeRuns: [[EdgeId]] = []
        
        for edge in edges {
            if edgesSet.contains(edge) {
                continue
            }
            
            let path = singlePathEdges(fromEdge: edge)
            edgeRuns.append(path)
            path.forEach { edgesSet.insert($0) }
        }
        
        return edgeRuns
    }
    
    @inlinable
    public func singlePathEdges(fromEdge edge: EdgeId) -> [EdgeId] {
        return singlePathEdges(fromEdge: edge, includeTest: { _ in true })
    }
    
    @inlinable
    public func singlePathEdges(fromEdge edge: EdgeId, includeTest: (EdgeId) -> Bool) -> [EdgeId] {
        return withoutActuallyEscaping(includeTest) { includeTest in
            var result: [EdgeId] = []
            var added: Set<EdgeId> = []
            
            // Only include edges not already accounted for in the result array
            let includeFilter: (EdgeId) -> Bool = { edge in
                if added.contains(edge) {
                    return false
                }
                
                return includeTest(edge)
            }
            
            var stack = [edge]
            
            while let next = stack.popLast() {
                result.append(next)
                added.insert(next)
                
                let edgesLeft =
                    edgesSharing(vertexIndex: vertices(forEdge: next).start)
                        .filter(includeFilter)

                let edgesRight =
                    edgesSharing(vertexIndex: vertices(forEdge: next).end)
                        .filter(includeFilter)

                if edgesLeft.count == 1 && !stack.contains(edgesLeft[0]) {
                    stack.append(edgesLeft[0])
                }
                if edgesRight.count == 1 && !stack.contains(edgesRight[0]) {
                    stack.append(edgesRight[0])
                }
            }
            
            return result
        }
    }
    
    /// Returns `true` iff each edge on a given list is directly connected to the
    /// next, forming a singular chain.
    @inlinable
    public func isUniqueSegment(_ edges: [EdgeId]) -> Bool {
        let array = edges
        if array.count == 0 {
            return false
        }
        if array.count == 1 {
            return true
        }
        
        // Take a list of all edges, pop the first edge, and check the remaining
        // list to see if an edge from the sequence is connected to it: if it is,
        // push that edge to the sequence edges and repeat for all edges until
        // either the list is empty or none of the remaining items are connected
        // to any of the edges in the sequence
        var rem = Array(array.dropFirst())
        var seq = [array[0]]
        
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
    public func isLoop(_ edges: [EdgeId]) -> Bool {
        let array = edges
        
        // Minimal number of edges connected to form a loop must be 3.
        if array.count < 3 {
            return false
        }
        
        // Take the list of edges, pick a single vertex, and traverse the edges
        // using a vertex hopper which hops across from edge to edge using the
        // vertices as pivots.
        // At the end, the first edge picked must be the edge the vertex hopper
        // returns to.
        var remaining = Array(array.dropFirst())
        var collected = [array[0]]
        collected.reserveCapacity(remaining.count)
        var current: EdgeId { return collected[collected.count - 1] }
        
        while remaining.count > 0 {
            for (i, edge) in remaining.enumerated() {
                if edgesShareVertex(current, edge) {
                    collected.append(edge)
                    remaining.remove(at: i)
                    break
                } else if i == remaining.count - 1 {
                    return false
                }
            }
        }
        
        return edgesShareVertex(collected[0], collected.last!)
    }
}
