@_exported import Geometry

/// A field for a loopy game.
/// Consists of a collection of vertices laid on a field, connected with edges
/// forming faces.
public struct LoopyField: Equatable {
    /// The list of vertices on this field.
    /// Each vertex is always connected to two or more edges, and always belongs
    /// to one or more faces.
    public var vertices: [Vertex]
    
    /// List of edges that connect vertices
    public var edges: [Edge]
    
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
    public var faces: [Face]
    
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
        guard let index = face.faceIndex(in: faces) else {
            return
        }
        
        changes(&faces[index])
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
        
        var face = Face(indices: indices, localToGlobalEdges: [], hint: hint)
        
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
    public func faceId(forFace face: FaceReferenceConvertible) -> Face.Id? {
        let face = face.face(in: self)
        
        return filterFaceIndices { $0.indices == face.indices }.first
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
        return edges.count { $0.state == .marked } == hint
    }
    
    /// Returns an array of vertices that make up a specified polygon face
    public func polygonFor(face: FaceReferenceConvertible) -> [Vertex] {
        let face = face.face(in: self)
        return face.indices.map { vertices[$0] }
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
            edge.start == vertexIndex || edge.end == vertexIndex
        }
    }
    
    /// Returns an array of all edges that are connected to a given edge.
    public func edgesConnected(to edge: EdgeReferenceConvertible) -> [Edge.Id] {
        let edge = edge.edge(in: self)
        return filterEdgeIndices(where: edge.sharesVertex)
    }
    
    /// Returns an array of all edge indices that enclose a face with a given id.
    public func edgeIds(forFace face: FaceReferenceConvertible) -> [Edge.Id] {
        let face = face.face(in: self)
        return face.localToGlobalEdges
    }
    
    /// Returns an array of all edges that enclose a face with a given id.
    public func edges(forFace face: FaceReferenceConvertible) -> [Edge] {
        let face = face.face(in: self)
        return face.localToGlobalEdges.map { edges[$0.value] }
    }
    
    /// Returns an array of faces within this field that share a given vertex index.
    public func facesSharing(vertexIndex: Int) -> [Face.Id] {
        return filterFaceIndices { face in
            face.indices.contains(vertexIndex)
        }
    }
    
    /// Returns the edge ID of the shared edge between two faces.
    /// If the two faces do not share an edge, nil is returned, instead.
    public func sharedEdge(between first: FaceReferenceConvertible, _ second: FaceReferenceConvertible) -> Edge.Id? {
        let face1 = first.face(in: self)
        let face2 = second.face(in: self)
        
        return Set(face1.localToGlobalEdges).intersection(face2.localToGlobalEdges).first
    }
    
    /// Returns the shared vertices between two faces.
    public func sharedVertices(between first: FaceReferenceConvertible, _ second: FaceReferenceConvertible) -> [Int] {
        let first = first.face(in: self)
        let second = second.face(in: self)
        
        return Array(Set(first.indices).intersection(second.indices))
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
