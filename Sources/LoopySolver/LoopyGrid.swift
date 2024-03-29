import Commons
@_exported import Geometry

@usableFromInline
final class BackingLoopyGrid: Equatable {
    typealias VertexType = Vertex
    typealias EdgeType = Edge
    typealias FaceId = Face.Id
    typealias EdgeId = Edge.Id

    @usableFromInline
    var _markedEdgesPerVertex: [Int] = []
    @usableFromInline
    var _edgesConnectedToEdge: [Edge.Id: [Edge.Id]] = [:]
    @usableFromInline
    var _edgesPerVertex: [[Edge.Id]] = []
    @usableFromInline
    var _nonDisabledEdgesPerVertex: [[Edge.Id]] = []
    @usableFromInline
    var _facesPerVertex: [[Face.Id]] = []
    @usableFromInline
    var _facesPerEdge: [[Face.Id]] = []
    @usableFromInline
    var _faceIsSolved: [Bool] = []
    @usableFromInline
    var _ignoringDisabledEdges: Bool = false

    /// Sequence of single-edge runs currently known
    var _edgeRuns: [[Edge.Id]] = []

    @usableFromInline
    var edges: [Edge] = [] {
        didSet {
            clearCaches()
        }
    }
    @usableFromInline
    var faces: [Face] = [] {
        didSet {
            clearCaches()
        }
    }
    @usableFromInline
    var vertices: [Vertex] = [] {
        didSet {
            clearCaches()
        }
    }
    @usableFromInline
    var edgeIds: [Edge.Id] = [] {
        didSet {
            clearCaches()
        }
    }
    @usableFromInline
    var faceIds: [Face.Id] = [] {
        didSet {
            clearCaches()
        }
    }

    @usableFromInline
    var lastIsConsistentResult: Bool?

    @usableFromInline
    init(
        edges: [Edge],
        faces: [Face],
        vertices: [Vertex],
        edgeIds: [Edge.Id],
        faceIds: [Face.Id],
        lastIsConsistentResult: Bool?
    ) {

        self.edges = edges
        self.faces = faces
        self.vertices = vertices
        self.edgeIds = edgeIds
        self.faceIds = faceIds
        self.lastIsConsistentResult = lastIsConsistentResult
    }

    @usableFromInline
    init() {
        edges = []
        faces = []
        vertices = []
        edgeIds = []
        faceIds = []
        lastIsConsistentResult = nil
    }

    @usableFromInline
    func makeCopy() -> BackingLoopyGrid {

        let copy =
            BackingLoopyGrid(
                edges: edges,
                faces: faces,
                vertices: vertices,
                edgeIds: edgeIds,
                faceIds: faceIds,
                lastIsConsistentResult: lastIsConsistentResult
            )

        copy._markedEdgesPerVertex = _markedEdgesPerVertex
        copy._edgesConnectedToEdge = _edgesConnectedToEdge
        copy._edgesPerVertex = _edgesPerVertex
        copy._nonDisabledEdgesPerVertex = _nonDisabledEdgesPerVertex
        copy._facesPerVertex = _facesPerVertex
        copy._facesPerEdge = _facesPerEdge
        copy._faceIsSolved = _faceIsSolved
        copy._ignoringDisabledEdges = _ignoringDisabledEdges
        copy._edgeRuns = _edgeRuns

        return copy
    }

    @usableFromInline
    func clearCaches() {
        lastIsConsistentResult = nil
    }

    @usableFromInline
    func updateEdge(_ index: Int, _ newEdge: Edge) {
        let previous = edges[index]
        let new = newEdge

        if edges[index] == newEdge {
            return
        }

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

        if previous.state.isEnabled && !new.state.isEnabled {
            _nonDisabledEdgesPerVertex[new.start].removeAll(where: { $0.edgeIndex == index })
            _nonDisabledEdgesPerVertex[new.end].removeAll(where: { $0.edgeIndex == index })
        }
        else if !previous.state.isEnabled && new.state.isEnabled {
            _nonDisabledEdgesPerVertex[new.start].append(EdgeId(index))
            _nonDisabledEdgesPerVertex[new.end].append(EdgeId(index))
        }

        edges[index] = newEdge
    }

    @usableFromInline
    static func == (lhs: BackingLoopyGrid, rhs: BackingLoopyGrid) -> Bool {
        return lhs.edges == rhs.edges
            && lhs.faces == rhs.faces
            && lhs.vertices == rhs.vertices
            && lhs.edgeIds == rhs.edgeIds
            && lhs.faceIds == rhs.faceIds
    }
}

/// A grid for a loopy game.
/// Consists of a collection of vertices laid on a grid, connected with edges
/// forming faces.
public struct LoopyGrid: Equatable, PolygonGraph {
    @usableFromInline
    internal var _backing = BackingLoopyGrid()

    public typealias VertexType = Vertex
    public typealias EdgeType = Edge
    public typealias FaceId = Face.Id
    public typealias EdgeId = Edge.Id

    @inlinable
    internal var _markedEdgesPerVertex: [Int] {
        get {
            return _backing._markedEdgesPerVertex
        }
        set {
            _ensureUniqueCopy()
            _backing._markedEdgesPerVertex = newValue
        }
    }

    @inlinable
    internal var _edgesConnectedToEdge: [Edge.Id: [Edge.Id]] {
        get {
            return _backing._edgesConnectedToEdge
        }
        set {
            _ensureUniqueCopy()
            _backing._edgesConnectedToEdge = newValue
        }
    }

    @inlinable
    internal var _edgesPerVertex: [[Edge.Id]] {
        get {
            return _backing._edgesPerVertex
        }
        set {
            _ensureUniqueCopy()
            _backing._edgesPerVertex = newValue
        }
    }

    @inlinable
    internal var _facesPerVertex: [[Face.Id]] {
        get {
            return _backing._facesPerVertex
        }
        set {
            _ensureUniqueCopy()
            _backing._facesPerVertex = newValue
        }
    }

    @inlinable
    internal var _facesPerEdge: [[Face.Id]] {
        get {
            return _backing._facesPerEdge
        }
        set {
            _ensureUniqueCopy()
            _backing._facesPerEdge = newValue
        }
    }

    @inlinable
    internal var _faceIsSolved: [Bool] {
        get {
            return _backing._faceIsSolved
        }
        set {
            _ensureUniqueCopy()
            _backing._faceIsSolved = newValue
        }
    }

    @inlinable
    internal var _ignoringDisabledEdges: Bool {
        get {
            return _backing._ignoringDisabledEdges
        }
        set {
            _ensureUniqueCopy()
            _backing._ignoringDisabledEdges = newValue
        }
    }

    @inlinable
    internal var _nonDisabledEdgesPerVertex: [[Edge.Id]] {
        get {
            return _backing._nonDisabledEdgesPerVertex
        }
        set {
            _ensureUniqueCopy()
            _backing._nonDisabledEdgesPerVertex = newValue
        }
    }

    /// List of edges that connect vertices
    @inlinable
    internal var edges: [Edge] {
        get {
            return _backing.edges
        }
        set {
            _ensureUniqueCopy()
            _backing.edges = newValue
        }
    }

    /// List of faces in this grid.
    ///
    /// Faces are compositions of vertex indices, with an optional hint associated.
    @inlinable
    internal var faces: [Face] {
        get {
            return _backing.faces
        }
        set {
            _ensureUniqueCopy()
            _backing.faces = newValue
        }
    }

    /// The list of vertices on this grid.
    /// Each vertex is always connected to two or more edges, and always belongs
    /// to one or more faces.
    private(set) public var vertices: [Vertex] {
        get {
            return _backing.vertices
        }
        set {
            _ensureUniqueCopy()
            _backing.vertices = newValue
        }
    }

    /// List of edge IDs in this grid.
    ///
    /// Every edge in `edges` has a matching edge ID within this array, and vice-versa.
    private(set) public var edgeIds: [Edge.Id] {
        get {
            return _backing.edgeIds
        }
        set {
            _ensureUniqueCopy()
            _backing.edgeIds = newValue
        }
    }

    /// List of face IDs in this grid.
    ///
    /// Every face in `faces` has a matching face ID within this array, and vice-versa.
    private(set) public var faceIds: [Face.Id] {
        get {
            return _backing.faceIds
        }
        set {
            _ensureUniqueCopy()
            _backing.faceIds = newValue
        }
    }

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
    @inlinable
    public var isConsistent: Bool {
        if let last = _backing.lastIsConsistentResult {
            return last
        }

        for i in 0..<vertices.count {
            if markedEdges(forVertex: i) > 2 {
                _backing.lastIsConsistentResult = false
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
                _backing.lastIsConsistentResult = false
                return false
            }
            if faceEdges.count(where: { edges[$0.edgeIndex].state.isEnabled }) < hint {
                _backing.lastIsConsistentResult = false
                return false
            }
        }

        // Fetch all marked edges and try to connect them into a single contiguous
        // line.
        var runs: [Set<EdgeId>] = []
        var edgesCollected: Set<Edge.Id> = []

        for edge in edgeIds where edgeState(forEdge: edge) == .marked {
            if edgesCollected.contains(edge) {
                continue
            }

            let run =
                singlePathEdges(
                    fromEdge: edge,
                    includeTest: { edges[$0.edgeIndex].state == .marked }
                )

            edgesCollected.formUnion(run)

            runs.append(run)
        }

        if runs.count > 1 && runs.contains(where: isLoop) {
            _backing.lastIsConsistentResult = false
            return false
        }

        _backing.lastIsConsistentResult = true
        return true
    }

    public init() {
        _backing = BackingLoopyGrid()
    }

    @inlinable
    internal mutating func _ensureUniqueCopy() {
        if isKnownUniquelyReferenced(&_backing) {
            return
        }

        _backing = _backing.makeCopy()
    }

    /// Returns a copy of this grid with disabled edges ignored when queried over
    /// with `edge-` methods.
    ///
    /// Edge references across both grid are compatible as long as they are not
    /// structurally modified.
    public func ignoringDisabledEdges() -> LoopyGrid {
        var copy = self
        copy._ignoringDisabledEdges = true
        return copy
    }

    /// With a given face reference, apply a set of changes to the matching face.
    /// Changes block is not called, in case face is not found within this grid.
    public mutating func withFace(_ face: FaceReferenceConvertible, changes: (inout Face) -> Void) {
        changes(&faces[face.id.value])

        _updateFaceResolved(face)
    }

    @inlinable
    public mutating func withEdge(_ edge: Int, changes: (inout Edge) -> Void) {
        withEdge(Edge.Id(edge), changes: changes)
    }

    /// With a given edge reference, apply a set of changes to the matching edge.
    /// Changes block is not called, in case edge is not found within this grid.
    @inlinable
    public mutating func withEdge(_ edge: EdgeReferenceConvertible, changes: (inout Edge) -> Void) {
        let index = edge.edgeIndex
        let previous = edges[index]
        var new = previous

        changes(&new)

        if previous == new {
            return
        }

        _ensureUniqueCopy()
        _backing.updateEdge(index, new)

        for f in _facesPerEdge[index] {
            _updateFaceResolved(f)
        }
    }

    public mutating func addVertex(_ vertex: Vertex) {
        vertices.append(vertex)

        _facesPerVertex.append([])
        _edgesPerVertex.append([])
        _nonDisabledEdgesPerVertex.append([])
        _markedEdgesPerVertex.append(0)
    }

    public mutating func addOrGetVertex(x: Int, y: Int) -> Int {
        return addOrGetVertex(Vertex(x: x, y: y))
    }

    public mutating func addOrGetVertex(x: Float, y: Float) -> Int {
        return addOrGetVertex(Vertex(x: x, y: y))
    }

    public mutating func addOrGetVertex(_ vertex: Vertex) -> Int {
        if let index = vertices.firstIndex(of: vertex) {
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
            _backing._edgesConnectedToEdge[el, default: []].append(edgeId)
        }
        for el in _edgesPerVertex[end] {
            _backing._edgesConnectedToEdge[el, default: []].append(edgeId)
        }

        _backing._edgesConnectedToEdge[edgeId, default: []]
            .append(
                contentsOf:
                    _edgesPerVertex[start]
                    + _edgesPerVertex[end]
            )

        _edgesPerVertex[start].append(edgeId)
        _edgesPerVertex[end].append(edgeId)
        _nonDisabledEdgesPerVertex[start].append(edgeId)
        _nonDisabledEdgesPerVertex[end].append(edgeId)

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
        precondition(
            Set(indices).sorted() == indices.sorted(),
            "indices list contains repeated vertex indices! \(indices)"
        )

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

        let face = Face(
            id: faceId,
            indices: indices,
            localToGlobalEdges: localToGlobalEdges,
            hint: hint
        )

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
    @inlinable
    public func edgeId(forEdge edge: EdgeReferenceConvertible) -> Edge.Id? {
        return Edge.Id(edge.edgeIndex)
    }

    /// Returns a matching Face Id for a given face.
    /// Returns `nil`, in case the face is not found within this graph.
    ///
    /// This method uses only the face's vertex array to figure out equality.
    @inlinable
    public func faceId(forFace face: FaceReferenceConvertible) -> Face.Id {
        return face.id
    }

    /// Gets the edge with a given id on this grid.
    ///
    /// - precondition: id is contained within this loopy grid
    @inlinable
    public func edgeWithId(_ id: EdgeId) -> Edge {
        return edges[id.value]
    }
}

// MARK: - Edge mutation methods
extension LoopyGrid {
    /// Sets the state of the given edges on this loopy grid.
    @inlinable
    public mutating func setEdges<S: Sequence>(state: Edge.State, forEdges edges: S)
    where S.Element == EdgeId {
        for edge in edges {
            withEdge(edge) {
                $0.state = state
            }
        }
    }

    /// Sets the state of the given edges on this loopy grid.
    @inlinable
    public mutating func setEdges<S: Sequence>(
        state: Edge.State,
        forEdges edges: S,
        where predicate: (Edge) -> Bool
    ) where S.Element == EdgeId {

        for edge in edges {
            withEdge(edge) {
                if predicate($0) {
                    $0.state = state
                }
            }
        }
    }

    /// Sets the state of the edges of a given face on this loopy grid.
    @inlinable
    public mutating func setEdges(state: Edge.State, forFace face: FaceReferenceConvertible) {
        setEdges(state: state, forEdges: edges(forFace: face.id))
    }

    /// Sets the edge state for a given edge on this LoopyGrid
    @inlinable
    public mutating func setEdge(state: Edge.State, forEdge edge: EdgeReferenceConvertible) {
        withEdge(edge) {
            $0.state = state
        }
    }
}

// MARK: - Vertex querying methods
extension LoopyGrid {
    /// Returns the index of the vertex with the given coordinates.
    ///
    /// Returns nil, in case the coordinate does not match any vertex.
    @inlinable
    public func vertexIndex(x: Float, y: Float) -> Int? {
        return vertices.firstIndex(of: Vertex(x: x, y: y))
    }

    /// Returns a list of vertex indices that make up a face.
    @inlinable
    public func vertices(forFace face: FaceReferenceConvertible) -> [Int] {
        return faces[face.id.value].indices
    }

    /// Returns the shared vertices between two faces.
    @inlinable
    public func sharedVertices(
        between first: FaceReferenceConvertible,
        _ second: FaceReferenceConvertible
    ) -> [Int] {
        let first = faces[first.id.value]
        let second = faces[second.id.value]

        return Array(Set(first.indices).intersection(second.indices))
    }

    /// Returns the number of edges marked for a given vertex
    @inlinable
    public func markedEdges(forVertex vertex: Int) -> Int {
        return _markedEdgesPerVertex[vertex]
    }
}

// MARK: - Edge querying methods
extension LoopyGrid {
    @inlinable
    internal func edgeReferenceFrom<E: EdgeReferenceConvertible>(_ edge: E) -> Edge {
        return edges[edge.edgeIndex]
    }

    @inlinable
    internal func edgeReferenceFrom(_ edge: EdgeReferenceConvertible) -> Edge {
        return edges[edge.edgeIndex]
    }

    @inlinable
    internal func shouldIgnore(_ edge: Edge) -> Bool {
        return _ignoringDisabledEdges ? !edge.state.isEnabled : false
    }

    // Public methods
    
    /// Returns `true` if `edgeId` refers to a valid edge within this graph.
    @inlinable
    public func hasEdgeId(_ edgeId: EdgeId) -> Bool {
        edgeIds.contains(edgeId)
    }

    /// Returns the state of a given edge reference
    @inlinable
    public func edgeState<E: EdgeReferenceConvertible>(forEdge edge: E) -> Edge.State {
        let edge = edgeReferenceFrom(edge)
        return edge.state
    }

    @inlinable
    public func edgeState(forEdge edge: EdgeReferenceConvertible) -> Edge.State {
        let edge = edgeReferenceFrom(edge)
        return edge.state
    }

    /// Returns `true` if a given edge starts or ends at a given vertex.
    @inlinable
    public func edgeSharesVertex(_ edge: EdgeReferenceConvertible, vertex: Int) -> Bool {
        let edge = edgeReferenceFrom(edge)
        return edge.sharesVertex(vertex)
    }

    /// Returns `true` if two edges match vertices-wise (ignoring edge state).
    /// Comparison ignores order of vertices between edges.
    @inlinable
    public func edgesMatchVertices(
        _ first: EdgeReferenceConvertible,
        _ second: EdgeReferenceConvertible
    ) -> Bool {
        let first = first.edgeIndex
        let second = second.edgeIndex

        return first == second || edges[first].matchesEdgeVertices(edges[second])
    }

    /// Returns `true` if two edges have a vertex index in common.
    @inlinable
    public func edgesShareVertex(_ first: EdgeId, _ second: EdgeId) -> Bool {
        let v = edgeVertices(forEdge: second)

        return edgeSharesVertex(first, vertex: v.start) || edgeSharesVertex(first, vertex: v.end)
    }

    /// Returns the two vertex indices for the start/end of a given edge.
    @inlinable
    public func edgeVertices(forEdge edge: EdgeId) -> (start: Int, end: Int) {
        let edge = edgeReferenceFrom(edge)

        return (edge.start, edge.end)
    }

    /// Returns the index for the edge of the given vertices.
    /// Detects both direction of edges.
    /// Returns `nil`, if no edge is present between the two edges.
    @inlinable
    public func edgeBetween(vertex1: Int, vertex2: Int) -> Edge.Id? {
        let v1 = edgesSharing(vertexIndex: vertex1)
        let v2 = edgesSharing(vertexIndex: vertex2)

        return v1.first(where: { v2.contains($0) })
    }

    /// Returns an array of all edges within this grid sharing a given common
    /// vertex index.
    @inlinable
    public func edgesSharing(vertexIndex: Int) -> [Edge.Id] {
        if _ignoringDisabledEdges {
            return _nonDisabledEdgesPerVertex[vertexIndex]
        } else {
            return _edgesPerVertex[vertexIndex]
        }
    }

    @inlinable
    public func edgesConnected(to edge: Int) -> [Edge.Id] {
        return edgesConnected(to: Edge.Id(edge))
    }

    /// Returns an array of all edges that are connected to a given edge.
    @inlinable
    public func edgesConnected(to edge: EdgeReferenceConvertible) -> [Edge.Id] {
        let index = edge.edgeIndex
        let id = Edge.Id(index)

        if _ignoringDisabledEdges {
            return _edgesConnectedToEdge[id, default: []].filter {
                !shouldIgnore(edgeReferenceFrom($0))
            }
        }

        return _edgesConnectedToEdge[id, default: []]
    }

    /// Returns an array of all edges that enclose a face with a given id.
    @inlinable
    public func edges(forFace face: Face.Id) -> [Edge.Id] {
        let face = faces[face.id.value]
        return face.localToGlobalEdges
    }

    /// Returns the edge ID of the shared edge between two faces.
    /// If the two faces do not share an edge, nil is returned, instead.
    @inlinable
    public func sharedEdge(
        between first: FaceId,
        _ second: FaceId
    ) -> Edge.Id? {

        let face1 = faces[first.id.value]
        let face2 = faces[second.id.value]

        return face1.localToGlobalEdges.first(where: face2.localToGlobalEdges.contains)
    }

    /// Returns the edge ID of the shared edge between two faces.
    /// If the two faces do not share an edge, nil is returned, instead.
    @inlinable
    public func sharedEdge(
        between first: FaceReferenceConvertible,
        _ second: FaceReferenceConvertible
    ) -> Edge.Id? {

        let face1 = faces[first.id.value]
        let face2 = faces[second.id.value]

        return face1.localToGlobalEdges.first(where: face2.localToGlobalEdges.contains)
    }
}

// MARK: - Face querying methods
extension LoopyGrid {
    /// Returns `true` if `faceId` refers to a valid face within this graph.
    @inlinable
    public func hasFaceId(_ faceId: FaceId) -> Bool {
        faceIds.contains(faceId)
    }

    /// Gets the hint for a particular face in this loopy grid
    @inlinable
    public func hintForFace(_ face: FaceReferenceConvertible) -> Int? {
        return faces[face.id.value].hint
    }

    /// Returns a value specifying whether a given face is semi-complete within
    /// the grid.
    ///
    /// Semi complete faces have a required edge count equal to their total edge
    /// count - 1, i.e. all but one of its edges are part of the solution.
    @inlinable
    public func isFaceSemiComplete(_ face: FaceReferenceConvertible) -> Bool {
        return faces[face.id.value].isSemiComplete
    }

    /// Returns the edge count for a given face.
    @inlinable
    public func edgeCount(forFace face: FaceReferenceConvertible) -> Int {
        return faces[face.id.value].edgesCount
    }

    /// Returns the number of edges of a given face that are in a specified state.
    @inlinable
    public func edgeCount(
        withState state: Edge.State,
        onFace face: FaceReferenceConvertible
    ) -> Int {
        return edges(forFace: face.id).count(where: { edgeState(forEdge: $0) == state })
    }

    /// Returns `true` if a given face is considered solved on this grid.
    ///
    /// Faces are solved if they are surrounded by exactly as many marked edges
    /// as their hint points.
    ///
    /// Non-hinted faces are always considered to be 'solved'.
    @inlinable
    public func isFaceSolved(_ faceId: FaceReferenceConvertible) -> Bool {
        return _faceIsSolved[faceId.id.value]
    }

    /// Returns an array of vertices that make up a specified polygon face
    @inlinable
    public func polygonFor(face: FaceReferenceConvertible) -> [Vertex] {
        let face = faces[face.id.value]
        return face.indices.map { vertices[$0] }
    }

    /// Returns an array of faces within this grid that share a given vertex index.
    @inlinable
    public func facesSharing(vertexIndex: Int) -> [FaceId] {
        return _facesPerVertex[vertexIndex]
    }

    /// Returns an array of faces within this grid that share a common edge.
    /// Either one or two faces share a common edge at all times.
    @inlinable
    public func facesSharing(edge: EdgeReferenceConvertible) -> [FaceId] {
        return _facesPerEdge[edge.edgeIndex]
    }

    /// Returns an array of faces that share an edge with a given face.
    @inlinable
    public func facesEdgeAdjacent(to face: FaceReferenceConvertible) -> Set<FaceId> {
        var result: Set<FaceId> = []
        
        for edge in edges(forFace: face) {
            let faces = facesSharing(edge: edge)
            
            for other in faces where other != face.id {
                result.insert(other)
            }
        }

        return result
    }

    /// Returns an array of faces that share a vertex, but not an edge, with a given
    /// face.
    @inlinable
    public func facesVertexAdjacent(to face: FaceReferenceConvertible) -> Set<FaceId> {
        var result: Set<FaceId> = []
        
        for vertex in vertices(forFace: face) {
            let faces = facesSharing(vertexIndex: vertex)
            
            for other in faces where other != face.id && !facesShareEdge(face, other) {
                result.insert(other)
            }
        }

        return result
    }

    /// Returns an array of all edges of a face on a grid that are not shared with
    /// any other face.
    public func nonSharedEdges(forFace face: FaceReferenceConvertible) -> [EdgeId] {
        return edges(forFace: face.id).filter { edge in
            facesSharing(edge: edge) == [face.id]
        }
    }

    /// Returns a list of all faces surrounding a given face such that the shared
    /// edge is open (`.disabled`)
    @inlinable
    public func facesConnectedTo(_ face: FaceId) -> [FaceId] {
        neighboringFaces(around: face, withEdgeStates: [.disabled])
    }

    /// Returns a list of all faces surrounding a given face such that the shared
    /// edge is closed (`.marked`)
    @inlinable
    public func facesDisconnectedTo(_ face: FaceId) -> [FaceId] {
        neighboringFaces(around: face, withEdgeStates: [.marked])
    }

    /// Returns a list of all faces surrounding a given face such that the shared
    /// edge has one of the specified edge states.
    @inlinable
    public func neighboringFaces(around face: FaceId, withEdgeStates states: Set<Edge.State>) -> [FaceId] {
        edges(forFace: face).filter {
            states.contains(edgeState(forEdge: $0))
        }.flatMap {
            facesSharing(edge: $0).filter {
                $0 != face
            }
        }
    }

    @inlinable
    public func faceContainsEdge(face: FaceId, edge: EdgeId) -> Bool {
        let face = faces[face.id.value]
        let edgeId = edgeIds[edge.edgeIndex]

        return face.containsEdge(id: edgeId)
    }

    public func faceContainsVertex(face: FaceId, vertex: Int) -> Bool {
        vertices(forFace: face).contains(vertex)
    }

    /// Returns `true` if two given faces share a common edge.
    @inlinable
    public func facesShareEdge(
        _ face1: FaceReferenceConvertible,
        _ face2: FaceReferenceConvertible
    ) -> Bool {

        let face1 = faces[face1.id.value]
        let face2 = faces[face2.id.value]

        return !Set(face1.localToGlobalEdges).isDisjoint(with: face2.localToGlobalEdges)
    }

    /// Returns a list of different combinations of edges representing how to
    /// mark the edges of a given face such that it is solved. The non-presence
    /// of an edge in the set indicates that it should not be marked.
    ///
    /// The return is a list, where each entry of the list is a set of edge ids
    /// that a loopy line would have to pass through to solve the face, taking in
    /// consideration its hint and pre-existing marked/disabled edges.
    public func permuteSolutionsAsEdges(forFace face: FaceReferenceConvertible) -> [Set<EdgeId>] {
        let faceEdges = edges(forFace: face)
        let hint = hintForFace(face)

        let vertices = vertices(forFace: face)

        var edgesPerVertex: [Int: [EdgeId]] = [:]
        vertices.forEach {
            edgesPerVertex[$0] = edgesSharing(vertexIndex: $0)
        }

        let markedEdges = Set(faceEdges.filter { edgeState(forEdge: $0) == .marked })
        let disabledEdges = Set(faceEdges.filter { edgeState(forEdge: $0) == .disabled })

        // Note: Assumes all edges in input belong to `face`.
        func solvesTile(_ edges: Set<EdgeId>) -> Bool {
            if let hint = hint, edges.count != hint {
                return false
            }

            // Check for edge states that should be respected in the result
            if !edges.intersection(disabledEdges).isEmpty {
                return false
            }
            if edges.intersection(markedEdges) != markedEdges {
                return false
            }

            // Do a pre-vertex check on the current grid to short circuit before
            // copying the grid if possible
            for vertex in vertices {
                // A vertex of degree 2 needs either none or both edges marked
                // at the same time.
                if let e = edgesPerVertex[vertex], e.count == 2 {
                    let intersection = edges.intersection(e)
                    if intersection.count == 1 {
                        return false
                    }
                }
            }

            // Ensure that lines are not continued into dead ends, or turns into
            // a 3-point star in one of the vertices
            var gridCopy = self
            gridCopy.setEdges(state: .disabled, forEdges: faceEdges)
            gridCopy.setEdges(state: .marked, forEdges: edges)
            for vertex in vertices {
                // 3-point star
                let markedEdgesOnCopy = gridCopy.markedEdges(forVertex: vertex)
                if self.markedEdges(forVertex: vertex) <= 2 && markedEdgesOnCopy > 2 {
                    return false
                }

                // Loop was cut off on edge of the face
                if markedEdgesOnCopy > 0 && edgesPerVertex[vertex]?.count(where: { gridCopy.edgeState(forEdge: $0).isEnabled }) == 1 {
                    return false
                }

                // A vertex of degree 2 needs either none or both edges marked
                // at the same time.
                if let e = edgesPerVertex[vertex] {
                    let countOnThisFace = e.count(where: {
                        gridCopy.edgeState(forEdge: $0).isEnabled && faceEdges.contains($0)
                    })

                    let intersection = edges.intersection(e)
                    if countOnThisFace == 2 && intersection.count == 1 {
                        return false
                    }
                }
            }

            return true
        }

        var result: Set<Set<EdgeId>> = []

        // Recursive permutation that flip-flops the presence of a vertex on a
        // set.
        func permute(at index: Int, current: Set<EdgeId>) {
            if solvesTile(current) {
                result.insert(current)
            }

            if index >= faceEdges.count {
                return
            }

            let edge = faceEdges[index]
            permute(at: index + 1, current: current.union([edge]))
            permute(at: index + 1, current: current)
        }

        permute(at: 0, current: [])

        return Array(result)
    }

    // MARK: Internals

    @usableFromInline
    internal mutating func _updateFaceResolved(_ faceId: FaceReferenceConvertible) {
        _faceIsSolved[faceId.id.value] = _internalIsFaceSolved(faceId)
    }

    private func _internalIsFaceSolved(_ faceId: FaceReferenceConvertible) -> Bool {
        let face = faces[faceId.id.value]

        guard let hint = face.hint else {
            return true
        }

        let edges = self.edges(forFace: faceId.id)
        return edges.count(hint) { edgeState(forEdge: $0) == .marked }
    }
}

// MARK: - Face network querying methods
extension LoopyGrid {
    /// Returns a list of all faces that can be reached by crossing open (`.disabled`)
    /// edges, recursively.
    @inlinable
    public func networkForFace(_ face: FaceId) -> PolygonGraphSubset<Self> {
        var visited: Set<FaceId> = []
        var queue: [FaceId] = [face]

        var result: Set<FaceId> = []

        while !queue.isEmpty {
            let face = queue.removeFirst()
            guard visited.insert(face).inserted else {
                continue
            }

            result.insert(face)

            for next in facesConnectedTo(face) {
                queue.append(next)
            }
        }

        return subset(faces: result)
    }

    /// Returns a list of networks (faces that are connected to each other) that
    /// are neighboring a given list of faces, but are not connected to any of
    /// the faces on the input list.
    ///
    /// Neighboring networks are considered for edges that are closed (`.marked`)
    /// only.
    func neighboringNetworksFor<S: Sequence>(_ faces: S) -> [PolygonGraphSubset<Self>] where S.Element == FaceId {
        let initialFaces: Set<FaceId> = Set(faces)

        var result: [PolygonGraphSubset<Self>] = []

        for face in faces {
            for next in facesDisconnectedTo(face) {
                guard !initialFaces.contains(next) else {
                    continue
                }

                let network = self.networkForFace(next)
                if !result.contains(network) {
                    result.append(network)
                }
            }
        }
        
        return result
    }
}
