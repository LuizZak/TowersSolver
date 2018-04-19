import Geometry

/// A grid for a loopy game.
/// Consists of a collection of vertices laid in 
public struct LoopyGrid {
    private var _faces: [Face]
    
    /// The list of vertices on this grid.
    /// Each vertex is always connected to two or more edges, and always belongs
    /// to one or more faces.
    public var vertices: [Vertex]
    
    /// Array of faces for this grid, made up of three or more vertices, referenced
    /// by index.
    public var faces: [Face.Id] {
        return _faces.map { $0.id }
    }
    
    public init() {
        vertices = []
        _faces = []
    }
    
    public mutating func clear() {
        vertices = []
        _faces = []
    }
    
    public mutating func addVertex(_ vertex: Vertex) {
        vertices.append(vertex)
    }
    
    @discardableResult
    public mutating func createFace(withVertexIndices indices: [Int], hint: Int?) -> Face.Id {
        let id = faces.count + 1
        let face = Face(id: id, indices: indices, hint: hint)
        _faces.append(face)
        
        return id
    }
    
    /// Returns an array of vertices that make up a specified polygon face
    public func polygonFor(faceId: Face.Id) -> [Vertex] {
        return faceWith(id: faceId)?.indices.map { vertices[$0] } ?? []
    }
    
    public func hintFor(faceId: Int) -> Int? {
        return faceWith(id: faceId)?.hint
    }
    
    private func faceWith(id: Face.Id) -> Face? {
        return _faces.first(where: { $0.id == id })
    }
    
    /// Returns an array of faces within this grid that share the given vertex.
    public func facesSharing(vertexIndex: Int) -> [Face.Id] {
        return _faces.filter { $0.indices.contains(vertexIndex) }.map { $0.id }
    }
}
