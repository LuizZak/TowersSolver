@_exported import Geometry

/// A field for a loopy game.
/// Consists of a collection of vertices laid on a field, connected with edges
/// forming faces.
public struct LoopyField: Equatable {
    /// The list of vertices on this field.
    /// Each vertex is always connected to two or more edges, and always belongs
    /// to one or more faces.
    private(set) public var vertices: [Vertex]
    
    /// List of edges that connect vertices
    private(set) public var edges: [Edge]
    
    /// List of edge IDs in this field.
    ///
    /// Every edge in `edges` has a matching edge ID within this array, and vice-versa.
    public var edgeIds: [Edge.Id] {
        return edges.enumerated().map {
            Edge.Id($0.offset)
        }
    }
    
    /// List of faces in this field.
    ///
    /// Faces are compositions of vertex indices, with an optional hint associated.
    private(set) public var faces: [Face]
    
    /// List of face IDs in this field.
    ///
    /// Every face in `faces` has a matching face ID within this array, and vice-versa.
    public var faceIds: [Face.Id] {
        return faces.enumerated().map {
            Face.Id($0.offset)
        }
    }
    
    public init() {
        vertices = []
        edges = []
        faces = []
    }
    
    public mutating func clear() {
        vertices = []
        edges = []
        faces = []
    }
    
    /// With a given face reference, apply a set of changes to the matching face.
    /// Changes block is not called, in case face is not found within this field.
    public mutating func withFace(_ face: FaceReferenceConvertible, changes: (inout Face) -> Void) {
        changes(&faces[face.id.value])
    }
    
    /// With a given edge reference, apply a set of changes to the matching edge.
    /// Changes block is not called, in case edge is not found within this field.
    public mutating func withEdge(_ edge: EdgeReferenceConvertible, changes: (inout Edge) -> Void) {
        guard let index = edge.edgeIndex(in: edges) else {
            return
        }
        
        changes(&edges[index])
    }
    
    /// Returns the face that matches a specific face ID in this field.
    ///
    /// precondition: `id.value > 0 && id.value < faces.count`
    public func faceWithId(_ id: Face.Id) -> Face {
        return faces[id.value]
    }
    
    /// Returns the edge that matches a specific edge ID in this field.
    ///
    /// precondition: `id.value > 0 && id.value < edges.count`
    public func edgeWithId(_ id: Edge.Id) -> Edge {
        return edges[id.value]
    }
    
    public mutating func addVertex(_ vertex: Vertex) {
        vertices.append(vertex)
    }
    
    /// Creates an edge between the given two vertices.
    ///
    /// Returns the identifier for the edge.
    ///
    /// If an existing edge already exists between the two vertices, that edge's
    /// identifier is returned, instead.
    @discardableResult
    public mutating func createEdge(from start: Int, to end: Int) -> Edge.Id {
        if let id = edgeIndex(vertex1: start, vertex2: end) {
            return id
        }
        
        let edge = Edge(start: start, end: end)
        
        edges.append(edge)
        
        return Edge.Id(edges.count - 1)
    }
    
    /// Creates a face with a given set of vertex indices on this field, with an
    /// optional accompanying initial hint.
    ///
    /// - precondition: `indices` features no repeated vertex indices.
    @discardableResult
    public mutating func createFace(withVertexIndices indices: [Int], hint: Int?) -> Face.Id {
        precondition(Set(indices).sorted() == indices.sorted(),
                     "indices list contains repeated vertex indices! \(indices)")
        
        var face = Face(id: Face.Id(faces.count), indices: indices,
                        localToGlobalEdges: [], hint: hint)
        
        // Make edges, connecting all vertices from the first to the last, and
        // the last connecting back to the first vertex
        for (i, start) in indices.enumerated() {
            let end = indices[(i + 1) % indices.count]
            
            let edgeId = createEdge(from: start, to: end)
            face.localToGlobalEdges.append(edgeId)
        }
        
        faces.append(face)
        
        return .init(faces.count - 1)
    }
    
    /// Returns a matching Edge Id for a given edge.
    /// Returns `nil`, in case the edge is not found within this graph.
    ///
    /// This method uses only the edge's start and end indices and ignores any
    /// other metadata associated with the edge.
    public func edgeId(forEdge edge: EdgeReferenceConvertible) -> Edge.Id? {
        let edge = edge.edge(in: self)
        
        return filterEdgeIndices { $0.start == edge.start && $0.end == edge.end }.first
    }
    
    /// Returns a matching Face Id for a given face.
    /// Returns `nil`, in case the face is not found within this graph.
    ///
    /// This method uses only the face's vertex array to figure out equality.
    public func faceId(forFace face: FaceReferenceConvertible) -> Face.Id {
        return face.id
    }
    
    private func filterFaceIndices(where predicate: (Face) -> Bool) -> [Face.Id] {
        return withoutActuallyEscaping(predicate) { predicate in
            return faces
                .enumerated()
                .lazy
                .filter { predicate($1) }
                .map { pair in pair.offset }
                .map { Face.Id.init($0) }
        }
    }
    
    private func filterEdgeIndices(where predicate: (Edge) -> Bool) -> [Edge.Id] {
        return withoutActuallyEscaping(predicate) { predicate in
            return edges
                .enumerated()
                .lazy
                .filter { predicate($1) }
                .map { pair in pair.offset }
                .map { Edge.Id.init($0) }
        }
    }
}

// MARK: - Vertex querying methods
public extension LoopyField {
    /// Returns the shared vertices between two faces.
    public func sharedVertices(between first: FaceReferenceConvertible, _ second: FaceReferenceConvertible) -> [Int] {
        let first = first.face(in: self)
        let second = second.face(in: self)
        
        return Array(Set(first.indices).intersection(second.indices))
    }
}

// MARK: - Edge segment querying
public extension LoopyField {
    /// Returns `true` iff each edge on a given list is directly connected to the
    /// next, forming a singular chain.
    public func isUniqueSegment(_ edges: [Edge.Id]) -> Bool {
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
    public func isLoop(_ edges: [Edge.Id]) -> Bool {
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
        var current: Edge.Id { return collected[collected.count - 1] }
        
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

// MARK: - Edge querying methods
public extension LoopyField {
    /// Returns the state of a given edge reference
    public func edgeState(forEdge edge: EdgeReferenceConvertible) -> Edge.State {
        return edge.edge(in: self).state
    }
    
    /// Returns `true` if a given edge starts or ends at a given vertex.
    public func edgeSharesVertex(_ edge: EdgeReferenceConvertible, vertex: Int) -> Bool {
        return edge.edge(in: self).sharesVertex(vertex)
    }
    
    /// Returns `true` if two edges match vertices-wise (ignoring edge state).
    /// Comparison ignores order of vertices between edges.
    public func edgesMatchVertices(_ first: EdgeReferenceConvertible, _ second: EdgeReferenceConvertible) -> Bool {
        return first.edge(in: self).matchesEdgeVertices(second.edge(in: self))
    }
    
    /// Returns `true` if two edges have a vertex index in common.
    public func edgesShareVertex(_ first: Edge.Id, _ second: Edge.Id) -> Bool {
        let v = vertices(forEdge: second)
        
        return edgeSharesVertex(first, vertex: v.start) || edgeSharesVertex(first, vertex: v.end)
    }
    
    /// Returns the two vertex indices for the start/end of a given edge.
    public func vertices(forEdge edge: EdgeReferenceConvertible) -> (start: Int, end: Int) {
        let edge = edge.edge(in: self)
        
        return (edge.start, edge.end)
    }
    
    /// Returns the index for the edge of the given vertices.
    /// Detects both direction of edges.
    /// Returns `nil`, if no edge is present between the two edges.
    public func edgeIndex(vertex1: Int, vertex2: Int) -> Edge.Id? {
        return edges.enumerated().first { (i, edge) in
            (edge.start == vertex1 && edge.end == vertex2)
                || (edge.start == vertex2 && edge.end == vertex1)
            }.map { Edge.Id($0.offset) }
    }
    
    /// Returns an array of all edges within this field sharing a given common
    /// vertex index.
    public func edgesSharing(vertexIndex: Int) -> [Edge.Id] {
        return filterEdgeIndices { edge in
            edge.sharesVertex(vertexIndex)
        }
    }
    
    /// Returns an array of all edges that are connected to a given edge.
    public func edgesConnected(to edge: EdgeReferenceConvertible) -> [Edge.Id] {
        let edge = edge.edge(in: self)
        return filterEdgeIndices(where: edge.sharesVertex)
    }
    
    /// Returns an array of all edges that enclose a face with a given id.
    public func edges(forFace face: FaceReferenceConvertible) -> [Edge.Id] {
        let face = face.face(in: self)
        return face.localToGlobalEdges
    }
    
    /// Returns the edge ID of the shared edge between two faces.
    /// If the two faces do not share an edge, nil is returned, instead.
    public func sharedEdge(between first: FaceReferenceConvertible, _ second: FaceReferenceConvertible) -> Edge.Id? {
        let face1 = first.face(in: self)
        let face2 = second.face(in: self)
        
        return Set(face1.localToGlobalEdges).intersection(face2.localToGlobalEdges).first
    }
}

// MARK: - Face querying methods
public extension LoopyField {
    /// Gets the hint for a particular face in this loopy field
    public func hintForFace(_ face: FaceReferenceConvertible) -> Int? {
        return face.face(in: self).hint
    }
    
    /// Returns a value specifying whether a given face is semi-complete within
    /// the field.
    ///
    /// Semi complete fields have a required edge count equal to their total edge
    /// count - 1, i.e. all but one of its edges are part of the solution.
    public func isFaceSemicomplete(_ face: FaceReferenceConvertible) -> Bool {
        return face.face(in: self).isSemiComplete
    }
    
    /// Returns the edge count for a given face
    public func edgeCount(forFace face: FaceReferenceConvertible) -> Int {
        return face.face(in: self).edgesCount
    }
    
    /// Returns `true` if a given face is considered solved on this field.
    ///
    /// Faces are solved if they are surrounded by exactly as many marked edges
    /// as their hint points.
    ///
    /// Non-hinted faces are always considered to be 'solved'.
    public func isFaceSolved(_ face: FaceReferenceConvertible) -> Bool {
        let face = face.face(in: self)
        
        guard let hint = face.hint else {
            return true
        }
        
        let edges = self.edges(forFace: face)
        return edges.count { edgeState(forEdge: $0) == .marked } == hint
    }
    
    /// Returns an array of vertices that make up a specified polygon face
    public func polygonFor(face: FaceReferenceConvertible) -> [Vertex] {
        let face = face.face(in: self)
        return face.indices.map { vertices[$0] }
    }
    
    /// Returns an array of faces within this field that share a given vertex index.
    public func facesSharing(vertexIndex: Int) -> [Face.Id] {
        return filterFaceIndices { face in
            face.indices.contains(vertexIndex)
        }
    }
    
    /// Returns an array of faces within this field that share a common edge.
    /// Either one or two faces share a common edge at all times.
    public func facesSharing(edge: EdgeReferenceConvertible) -> [Face.Id] {
        let edge = edge.edge(in: self)
        
        return filterFaceIndices { face in
            face.indices.contains(edge.start) && face.indices.contains(edge.end)
        }
    }
    
    /// Returns `true` if a given edge forms the side of a given face.
    public func faceContainsEdge(face: FaceReferenceConvertible, edge: EdgeReferenceConvertible) -> Bool {
        let face = face.face(in: self)
        let edge = edge.edge(in: self)
        
        guard let id = edgeId(forEdge: edge) else {
            return false
        }
        return face.containsEdge(id: id)
    }
    
    /// Returns `true` if two given faces share a common edge.
    public func facesShareEdge(_ face1: FaceReferenceConvertible, _ face2: FaceReferenceConvertible) -> Bool {
        let face1 = face1.face(in: self)
        let face2 = face2.face(in: self)
        
        return !Set(face1.localToGlobalEdges).isDisjoint(with: face2.localToGlobalEdges)
    }
}
