public final class SolverStepMetadata {
    private var metadata: [String: Any] = [:]
    private var vertexStates: [Int: [Edge.State]] = [:]
    private var faceMetadata: [Int: Any] = [:]
    private var flag = false

    public subscript<T>(_ name: String, type type: T.Type) -> T? {
        get {
            return metadata[name] as? T
        }
        set {
            metadata[name] = newValue
        }
    }

    public subscript<T>(_ name: String, type type: T.Type, defaultValue defaultValue: T) -> T {
        get {
            return metadata[name] as? T ?? defaultValue
        }
        set {
            metadata[name] = newValue
        }
    }

    public init() {

    }

    public func storeVertexState(_ vertex: Int, from grid: LoopyGrid) {
        vertexStates[vertex] = grid.edgesSharing(vertexIndex: vertex).map(grid.edgeState)
    }

    public func matchesStoredVertexState(_ vertex: Int, from grid: LoopyGrid) -> Bool {
        guard let storedEdgeStates = vertexStates[vertex] else {
            return false
        }

        let edges = grid.edgesSharing(vertexIndex: vertex)
        for i in 0..<edges.count {
            if grid.edgeState(forEdge: edges[i]) != storedEdgeStates[i] {
                return false
            }
        }

        return true
    }

    public func storeGridState(_ grid: LoopyGrid) {
        self["_grids", type: [LoopyGrid].self, defaultValue: []].append(grid)
    }

    public func isGridStateStored(_ grid: LoopyGrid) -> Bool {
        return self["_grids", type: [LoopyGrid].self, defaultValue: []].contains(grid)
    }

    public func storeFaceState(_ faceId: Face.Id, from grid: LoopyGrid) {
        faceMetadata[faceId.value] = grid.edges(forFace: faceId).map(grid.edgeWithId)
    }

    public func matchesStoredFaceState(_ faceId: Face.Id, from grid: LoopyGrid) -> Bool {
        guard let stored = faceMetadata[faceId.value] as? [Edge] else {
            return false
        }

        return stored.elementsEqual(
            grid.edges(forFace: faceId).lazy.map(grid.edgeWithId)
        )
    }

    public func markFace(_ faceId: Face.Id) {
        metadata["_individualFace\(faceId.value)"] = true
    }

    public func isFaceMarked(_ faceId: Face.Id) -> Bool {
        return self["_individualFace\(faceId.value)", type: Bool.self] == true
    }

    /// Marks a global flag to this metadata that stipulates an overall action
    /// was already taken.
    public func markFlag() {
        flag = true
    }

    /// Returns `true` if `markFlag()` has been invoked previously in this metadata
    /// instance.
    public func isFlagMarked() -> Bool {
        return flag
    }
}
