import Commons

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
    @inlinable
    public func vertexIndex(_ vertex: Vertex) -> Int? {
        return vertices.index(of: vertex)
    }
    
    @inlinable
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
            edgesSet.formUnion(path)
        }
        
        return edgeRuns
    }
    
    @inlinable
    public func singlePathEdges(fromEdge edge: EdgeId) -> [EdgeId] {
        return singlePathEdges(fromEdge: edge, includeTest: { _ in true })
    }
    
    @inlinable
    public func singlePathEdges(fromEdge edge: EdgeId, includeTest: (EdgeId) -> Bool) -> [EdgeId] {
        var stack: [(pivot: EdgeId, previous: EdgeId?)] = []
        
        stack = [(edge, nil)]
        
        var result: [EdgeId] = []
        
        while let top = stack.popLast() {
            let (pivot, previous) = top
            
            // Make sure we don't duplicate an edge in case the line forms a closed
            // loop
            if previous == edge && result.last == pivot {
                continue
            }
            
            result.append(pivot)
            
            let vertices = self.vertices(forEdge: pivot)
            
            let sharingStart = edgesSharing(vertexIndex: vertices.start)
            let sharingEnd = edgesSharing(vertexIndex: vertices.end)
            
            if sharingStart.contains(where: { $0 == pivot && includeTest($0) }) && sharingStart.count(where: includeTest) == 2 {
                let sharingStartIncluded = sharingStart.filter(includeTest)
                
                let new = sharingStartIncluded[0] == pivot
                    ? sharingStartIncluded[1]
                    : sharingStartIncluded[0]
                
                if new != previous && !result.contains(new) {
                    stack.append((new, pivot))
                }
            }
            if sharingEnd.contains(where: { $0 == pivot && includeTest($0) }) && sharingEnd.count(where: includeTest) == 2 {
                let sharingEndIncluded = sharingEnd.filter(includeTest)
                
                let new = sharingEndIncluded[0] == pivot
                    ? sharingEndIncluded[1]
                    : sharingEndIncluded[0]
                
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
