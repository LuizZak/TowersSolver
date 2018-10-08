@_exported import Geometry

/// A grid for a loopy game.
/// Consists of a collection of vertices laid on a grid, connected with edges
/// forming faces.
public struct LoopyGrid: Equatable, Graph {
    public typealias VertexType = Vertex
    public typealias EdgeType = Edge
    public typealias FaceId = Face.Id
    public typealias EdgeId = Edge.Id
    
    private var _markedEdgesPerVertex: [Int] = []
    private var _edgesConnectedToEdge: [Edge.Id: [Edge.Id]] = [:]
    private var _edgesPerVertex: [[Edge.Id]] = []
    private var _facesPerVertex: [[Face.Id]] = []
    private var _facesPerEdge: [[Face.Id]] = []
    private var _faceIsSolved: [Bool] = []
    
    private var _ingoringDisabledEdges: Bool = false
    
    /// List of edges that connect vertices
    @usableFromInline
    internal var edges: [Edge]
    
    /// List of faces in this grid.
    ///
    /// Faces are compositions of vertex indices, with an optional hint associated.
    @usableFromInline
    internal var faces: [Face]
    
    /// The list of vertices on this grid.
    /// Each vertex is always connected to two or more edges, and always belongs
    /// to one or more faces.
    private(set) public var vertices: [Vertex]
    
    /// List of edge IDs in this grid.
    ///
    /// Every edge in `edges` has a matching edge ID within this array, and vice-versa.
    private(set) public var edgeIds: [Edge.Id]
    
    /// List of face IDs in this grid.
    ///
    /// Every face in `faces` has a matching face ID within this array, and vice-versa.
    private(set) public var faceIds: [Face.Id]
    
    /// List of states for every edge on this grid.
    /// Has same length as `edgeIds` and `edges` arrays, and is laid down
    /// sequentially the same way.
    @inlinable
    public var edgeStates: [Edge.State] {
        return edges.map { $0.state }
    }
    
    /// Returns a value specifying whether this grid is consistent.
    /// Consistency is based upon a partial or full solution attempt, be that the
    /// actual solution to the playfield or not.
    ///
    /// A grid is consistent when all of the following assertions hold:
    ///
    /// 1. A vertex has either zero, one, or two marked edges associated with it.
    /// 2. A face with a hint has less or exactly as many marked edges around it
    /// as its hint indicates.
    /// 3. A face with a hint has more or exactly as many non-disabled edges
    /// around it as its hint indicates.
    /// 4. If a set of edges form a closed loop, all marked edges in the grid
    /// must be part of the loop.
    public var isConsistent: Bool {
        for i in 0..<vertices.count {
            if _markedEdgesPerVertex[i] > 2 {
                return false
            }
        }
        
        for face in faceIds {
            if isFaceSolved(face) {
                continue
            }
            
            guard let hint = hintForFace(face) else {
                continue
            }
            
            let faceEdges = self.edges(forFace: face)
            
            if faceEdges.count(where: { edges[$0.edgeIndex].state == .marked }) > hint {
                return false
            }
            if faceEdges.count(where: { edges[$0.edgeIndex].state.isEnabled }) < hint {
                return false
            }
        }
        
        // Fetch all marked edges and try to connect them into a single contiguous
        // line.
        let marked = edgeIds.lazy.filter { self.edges[$0.edgeIndex].state == .marked }
        
        var runs: [[Edge.Id]] = []
        var edgesCollected: Set<Edge.Id> = []
        for edge in marked {
            if edgesCollected.contains(edge) {
                continue
            }
            
            let run =
                singlePathEdges(fromEdge: edge,
                                includeTest: { edges[$0.edgeIndex].state == .marked })
            
            edgesCollected.formUnion(run)
            
            runs.append(run)
        }
        
        if runs.count > 1 && runs.contains(where: isLoop) {
            return false
        }
        
        return true
    }
    
    public init() {
        vertices = []
        edges = []
        edgeIds = []
        faces = []
        faceIds = []
    }
    
    /// Returns a copy of this grid with disabled edges ignored when queried over
    /// with `edge-` methods.
    ///
    /// Edge references across both grid are compatible as long as they are not
    /// structurally modified.
    public func ignoringDisabledEdges() -> LoopyGrid {
        var copy = self
        copy._ingoringDisabledEdges = true
        return copy
    }
    
    /// With a given face reference, apply a set of changes to the matching face.
    /// Changes block is not called, in case face is not found within this grid.
    public mutating func withFace(_ face: FaceReferenceConvertible, changes: (inout Face) -> Void) {
        changes(&faces[face.id.value])
        
        _updateFaceResolved(face)
    }
    
    /// With a given edge reference, apply a set of changes to the matching edge.
    /// Changes block is not called, in case edge is not found within this grid.
    public mutating func withEdge(_ edge: EdgeReferenceConvertible, changes: (inout Edge) -> Void) {
        let previous = edges[edge.edgeIndex]
        
        changes(&edges[edge.edgeIndex])
        
        let new = edges[edge.edgeIndex]
        
        switch (previous.state, new.state) {
        case (.marked, .marked):
            break
        case (.marked, _):
            _markedEdgesPerVertex[new.start] -= 1
            _markedEdgesPerVertex[new.end] -= 1
        case (_, .marked):
            _markedEdgesPerVertex[new.start] += 1
            _markedEdgesPerVertex[new.end] += 1
        default:
            break
        }
        
        for f in _facesPerEdge[edge.edgeIndex] {
            _updateFaceResolved(f)
        }
    }
    
    public mutating func addVertex(_ vertex: Vertex) {
        vertices.append(vertex)
        
        _facesPerVertex.append([])
        _edgesPerVertex.append([])
        _markedEdgesPerVertex.append(0)
    }
    
    public mutating func addOrGetVertex(x: Int, y: Int) -> Int {
        return addOrGetVertex(Vertex(x: x, y: y))
    }
    
    public mutating func addOrGetVertex(x: Float, y: Float) -> Int {
        return addOrGetVertex(Vertex(x: x, y: y))
    }
    
    public mutating func addOrGetVertex(_ vertex: Vertex) -> Int {
        if let index = vertices.index(of: vertex) {
            return index
        }
        
        addVertex(vertex)
        return vertices.count - 1
    }
    
    /// Creates an edge between the given two vertices.
    ///
    /// Returns the identifier for the edge.
    ///
    /// If an existing edge already exists between the two vertices, that edge's
    /// identifier is returned, instead.
    @discardableResult
    public mutating func createEdge(from start: Int, to end: Int) -> Edge.Id {
        if let id = edgeBetween(vertex1: start, vertex2: end) {
            return id
        }
        
        let edge = Edge(start: start, end: end)
        let edgeId = Edge.Id(edges.count)
        
        for el in _edgesPerVertex[start] {
            _edgesConnectedToEdge[el, default: []].append(edgeId)
        }
        for el in _edgesPerVertex[end] {
            _edgesConnectedToEdge[el, default: []].append(edgeId)
        }
        
        _edgesConnectedToEdge[edgeId, default: []]
            .append(contentsOf:
                _edgesPerVertex[start]
                    + _edgesPerVertex[end])
        
        _edgesPerVertex[start].append(edgeId)
        _edgesPerVertex[end].append(edgeId)
        
        _facesPerEdge.append([])
        
        edges.append(edge)
        edgeIds.append(edgeId)
        
        return edgeId
    }
    
    /// Creates a face with a given set of vertex indices on this grid, with an
    /// optional accompanying initial hint.
    ///
    /// - precondition: `indices` features no repeated vertex indices.
    @discardableResult
    public mutating func createFace(withVertexIndices indices: [Int], hint: Int? = nil) -> Face.Id {
        precondition(Set(indices).sorted() == indices.sorted(),
                     "indices list contains repeated vertex indices! \(indices)")
        
        let faceId = Face.Id(faces.count)
        
        var localToGlobalEdges: [Edge.Id] = []
        
        // Make edges, connecting all vertices from the first to the last, and
        // the last connecting back to the first vertex
        for (i, start) in indices.enumerated() {
            let end = indices[(i + 1) % indices.count]
            
            let edgeId = createEdge(from: start, to: end)
            localToGlobalEdges.append(edgeId)
            
            _facesPerVertex[start].append(faceId)
            
            _facesPerEdge[edgeId.value].append(faceId)
        }
        
        let face = Face(id: faceId, indices: indices,
                        localToGlobalEdges: localToGlobalEdges, hint: hint)
        
        _faceIsSolved.append(hint == nil)
        faces.append(face)
        faceIds.append(faceId)
        
        return .init(faces.count - 1)
    }
    
    /// Returns a matching Edge Id for a given edge.
    /// Returns `nil`, in case the edge is not found within this graph.
    ///
    /// This method uses only the edge's start and end indices and ignores any
    /// other metadata associated with the edge.
    public func edgeId(forEdge edge: EdgeReferenceConvertible) -> Edge.Id? {
        return Edge.Id(edge.edgeIndex)
    }
    
    /// Returns a matching Face Id for a given face.
    /// Returns `nil`, in case the face is not found within this graph.
    ///
    /// This method uses only the face's vertex array to figure out equality.
    public func faceId(forFace face: FaceReferenceConvertible) -> Face.Id {
        return face.id
    }
    
    /// Gets the edge with a given id on this grid.
    ///
    /// - precondition: id is contained within this loopy grid
    public func edgeWithId(_ id: EdgeId) -> Edge {
        return edges[id.value]
    }
}

// MARK: - Vertex querying methods
public extension LoopyGrid {
    /// Returns the index of the vertex with the given coordinates.
    ///
    /// Returns nil, in case the coordinate does not match any vertex.
    public func vertexIndex(x: Float, y: Float) -> Int? {
        return vertices.index(of: Vertex(x: x, y: y))
    }
    
    /// Returns a list of vertex indices that make up a face.
    public func vertices(forFace face: FaceReferenceConvertible) -> [Int] {
        return faces[face.id.value].indices
    }
    
    /// Returns the shared vertices between two faces.
    public func sharedVertices(between first: FaceReferenceConvertible,
                               _ second: FaceReferenceConvertible) -> [Int] {
        let first = faces[first.id.value]
        let second = faces[second.id.value]
        
        return Array(Set(first.indices).intersection(second.indices))
    }
    
    /// Returns the number of edges marked for a given vertex
    public func markedEdges(forVertex vertex: Int) -> Int {
        return _markedEdgesPerVertex[vertex]
    }
}

// MARK: - Edge querying methods
public extension LoopyGrid {
    @inlinable
    internal func edgeReferenceFrom<E: EdgeReferenceConvertible>(_ edge: E) -> Edge {
        return edges[edge.edgeIndex]
    }
    
    @inlinable
    internal func edgeReferenceFrom(_ edge: EdgeId) -> Edge {
        return edges[edge.edgeIndex]
    }
    
    private func shouldIgnore(_ edge: Edge) -> Bool {
        return _ingoringDisabledEdges ? !edge.state.isEnabled : false
    }
    
    /// Returns the state of a given edge reference
    @inlinable
    public func edgeState<E: EdgeReferenceConvertible>(forEdge edge: E) -> Edge.State {
        let edge = edgeReferenceFrom(edge)
        return edge.state
    }
    
    @inlinable
    public func edgeState(forEdge edge: Edge.Id) -> Edge.State {
        let edge = edgeReferenceFrom(edge)
        return edge.state
    }
    
    /// Returns `true` if a given edge starts or ends at a given vertex.
    @inlinable
    public func edgeSharesVertex<E: EdgeReferenceConvertible>(_ edge: E, vertex: Int) -> Bool {
        let edge = edgeReferenceFrom(edge)
        return edge.sharesVertex(vertex)
    }
    
    /// Returns `true` if two edges match vertices-wise (ignoring edge state).
    /// Comparison ignores order of vertices between edges.
    public func edgesMatchVertices(_ first: EdgeReferenceConvertible,
                                   _ second: EdgeReferenceConvertible) -> Bool {
        let first = first.edgeIndex
        let second = second.edgeIndex
        
        return first == second || edges[first].matchesEdgeVertices(edges[second])
    }
    
    /// Returns `true` if two edges have a vertex index in common.
    public func edgesShareVertex(_ first: Edge.Id, _ second: Edge.Id) -> Bool {
        let v = vertices(forEdge: second)
        
        return edgeSharesVertex(first, vertex: v.start) || edgeSharesVertex(first, vertex: v.end)
    }
    
    /// Returns the two vertex indices for the start/end of a given edge.
    public func vertices(forEdge edge: Edge.Id) -> (start: Int, end: Int) {
        let edge = edgeReferenceFrom(edge)
        
        return (edge.start, edge.end)
    }
    
    /// Returns the index for the edge of the given vertices.
    /// Detects both direction of edges.
    /// Returns `nil`, if no edge is present between the two edges.
    public func edgeBetween(vertex1: Int, vertex2: Int) -> Edge.Id? {
        return edges.enumerated().filter { !shouldIgnore($0.element) }.first { (i, edge) in
            (edge.start == vertex1 && edge.end == vertex2)
                || (edge.start == vertex2 && edge.end == vertex1)
            }.map { Edge.Id($0.offset) }
    }
    
    /// Returns an array of all edges within this grid sharing a given common
    /// vertex index.
    public func edgesSharing(vertexIndex: Int) -> [Edge.Id] {
        let edges = _edgesPerVertex[vertexIndex]
        
        if _ingoringDisabledEdges {
            return edges.filter { !shouldIgnore(edgeReferenceFrom($0)) }
        }
        return edges
    }
    
    /// Returns an array of all edges that are connected to a given edge.
    public func edgesConnected(to edge: EdgeReferenceConvertible) -> [Edge.Id] {
        let index = edge.edgeIndex
        let id = Edge.Id(index)
        
        if _ingoringDisabledEdges {
            return _edgesConnectedToEdge[id, default: []].filter { !shouldIgnore(edgeReferenceFrom($0)) }
        }
        
        return _edgesConnectedToEdge[id, default: []]
    }
    
    /// Returns an array of all edges that enclose a face with a given id.
    public func edges(forFace face: Face.Id) -> [Edge.Id] {
        let face = faces[face.id.value]
        return face.localToGlobalEdges
    }
    
    /// Returns the edge ID of the shared edge between two faces.
    /// If the two faces do not share an edge, nil is returned, instead.
    public func sharedEdge(between first: FaceReferenceConvertible,
                           _ second: FaceReferenceConvertible) -> Edge.Id? {
        
        let face1 = faces[first.id.value]
        let face2 = faces[second.id.value]
        
        return Set(face1.localToGlobalEdges).intersection(face2.localToGlobalEdges).first
    }
}

// MARK: - Face querying methods
public extension LoopyGrid {
    /// Gets the hint for a particular face in this loopy grid
    public func hintForFace(_ face: FaceReferenceConvertible) -> Int? {
        return faces[face.id.value].hint
    }
    
    /// Returns a value specifying whether a given face is semi-complete within
    /// the grid.
    ///
    /// Semi complete faces have a required edge count equal to their total edge
    /// count - 1, i.e. all but one of its edges are part of the solution.
    public func isFaceSemicomplete(_ face: FaceReferenceConvertible) -> Bool {
        return faces[face.id.value].isSemiComplete
    }
    
    /// Returns the edge count for a given face.
    public func edgeCount(forFace face: FaceReferenceConvertible) -> Int {
        return faces[face.id.value].edgesCount
    }
    
    /// Returns the number of edges of a given face that are in a specified state.
    public func edgeCount(withState state: Edge.State, onFace face: FaceReferenceConvertible) -> Int {
        return edges(forFace: face.id).count(where: { edgeState(forEdge: $0) == state })
    }
    
    /// Returns `true` if a given face is considered solved on this grid.
    ///
    /// Faces are solved if they are surrounded by exactly as many marked edges
    /// as their hint points.
    ///
    /// Non-hinted faces are always considered to be 'solved'.
    public func isFaceSolved(_ faceId: FaceReferenceConvertible) -> Bool {
        return _faceIsSolved[faceId.id.value]
    }
    
    /// Returns an array of vertices that make up a specified polygon face
    public func polygonFor(face: FaceReferenceConvertible) -> [Vertex] {
        let face = faces[face.id.value]
        return face.indices.map { vertices[$0] }
    }
    
    /// Returns an array of faces within this grid that share a given vertex index.
    public func facesSharing(vertexIndex: Int) -> [Face.Id] {
        return _facesPerVertex[vertexIndex]
    }
    
    /// Returns an array of faces within this grid that share a common edge.
    /// Either one or two faces share a common edge at all times.
    public func facesSharing(edge: EdgeReferenceConvertible) -> [Face.Id] {
        return _facesPerEdge[edge.edgeIndex]
    }
    
    /// Returns `true` if a given edge forms the side of a given face.
    public func faceContainsEdge(face: Face.Id, edge: Edge.Id) -> Bool {
        
        let face = faces[face.id.value]
        let edgeId = edgeIds[edge.edgeIndex]
        
        return face.containsEdge(id: edgeId)
    }
    
    /// Returns `true` if two given faces share a common edge.
    public func facesShareEdge(_ face1: FaceReferenceConvertible,
                               _ face2: FaceReferenceConvertible) -> Bool {
        
        let face1 = faces[face1.id.value]
        let face2 = faces[face2.id.value]
        
        return !Set(face1.localToGlobalEdges).isDisjoint(with: face2.localToGlobalEdges)
    }
    
    private mutating func _updateFaceResolved(_ faceId: FaceReferenceConvertible) {
        _faceIsSolved[faceId.id.value] = _internalIsFaceSolved(faceId)
    }
    
    private func _internalIsFaceSolved(_ faceId: FaceReferenceConvertible) -> Bool {
        let face = faces[faceId.id.value]
        
        guard let hint = face.hint else {
            return true
        }
        
        let edges = self.edges(forFace: faceId.id)
        return edges.count { edgeState(forEdge: $0) == .marked } == hint
    }
}
