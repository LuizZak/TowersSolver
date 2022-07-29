/// A solver step that deals with loopy lines that touch a face in a corner in
/// such a way that the line has to traverse through the face, marking a minimal
/// number of edges around the face.
///
/// Ex: On the following grid, the top-right marked edge has to pass through the
/// 1-hinted face to be able to continue. Since we know that it will have to cross
/// the edges of the face, we know the left edge of the cell cannot be marked
/// (since it would exceed the requirement for the cell), and the right and bottom
/// edges of the face also cannot be marked, since it would require marking the
/// two edges to make the corner, which would exceed the requirement, as well.
///
///     .___.___.
///     !___!___║
///     !___!_1_!
///
/// This solver step also deals with cases of semi-complete edges that have an
/// entry point that enters through an edge:
///     .___.___.
///     !___!___║
///     !___!_3_!
///
/// It also handles cases of corner entries that result in a split between possible
/// paths taken around a face, one of which results in an invalid grid state, e.g.:
///
/// In the following grid configuration, the line path coming into a 4-cell
/// (denoted by '\\') may either take a path going right (1), or going down to
/// the left around the 4-cell (2), but if it takes the down-left path it will
/// result in not enough enabled edges being available to complete the clue, thus
/// resulting in the aforementioned down-left path to be an invalid play, and thus
/// discarded:
///
/// ══•                               ══•
///    ⤡ (1)                             ⤡
///     •───•       Marking edge          •   •      Which leaves the 4-cell
/// (2)/     \     (2) results in:       ⤢           with not enough edges to
/// ──•   4   •                       ──•   4   •    complete its hint!
///    \     /                           \
///     •───•                             •───•
///    /     \                           /     \
/// ──•       •──                     ──•       •──
///
public class CornerEntrySolverStep: SolverStep {
    public func apply(to grid: LoopyGrid, _ delegate: SolverStepDelegate) -> LoopyGrid {
        let metadata = delegate.metadataForSolverStepClass(type(of: self))

        let solver = InternalSolver(grid: grid, metadata: metadata)
        solver.apply()
        return solver.grid
    }
}

private class InternalSolver {
    var metadata: SolverStepMetadata

    var grid: LoopyGrid

    init(grid: LoopyGrid, metadata: SolverStepMetadata) {
        self.grid = grid
        self.metadata = metadata
    }

    func apply() {
        for i in 0..<grid.vertices.count {
            applyToVertex(i)
        }
        for face in grid.faceIds {
            // Must have hint!
            guard let hint = grid.hintForFace(face) else {
                continue
            }

            analyzeVertexEntryPoints(for: face, hint: hint)
            analyzeForkingHintedEdgesPath(for: face, hint: hint)
        }
    }

    func applyToVertex(_ vertexIndex: Int) {
        if metadata.matchesStoredVertexState(vertexIndex, from: grid) {
            return
        }
        defer {
            metadata.storeVertexState(vertexIndex, from: grid)
        }

        let edges = grid.edgesSharing(vertexIndex: vertexIndex)

        // Can only do work on loose ends of a loopy line (a vertex with a single
        // marked edge)
        guard let marked = edges.only(where: { grid.edgeState(forEdge: $0) == .marked }) else {
            return
        }

        let normal = edges.filter { grid.edgeState(forEdge: $0) == .normal }

        // If any of the faces is semi-complete, apply a different logic here to
        // 'hijack' the line into it's own path
        if let semiComplete = grid.facesSharing(vertexIndex: vertexIndex).first(
            where: grid.isFaceSemicomplete
        ) {
            if grid.isFaceSolved(semiComplete) {
                return
            }

            // Can only account for edges coming into the face from an outside
            // edge
            if grid.faceContainsEdge(face: semiComplete, edge: marked) {
                return
            }

            let oppositeEdges = grid.edges(forFace: semiComplete)
                .filter { !grid.edgeSharesVertex($0, vertex: vertexIndex) }

            grid.setEdges(state: .marked, forEdges: oppositeEdges)

            // Disable edges from other faces that share that vertex to finish
            // hijacking the line path
            let otherEdges =
                edges
                .filter {
                    !grid.faceContainsEdge(face: semiComplete, edge: grid.edgeId(forEdge: $0)!)
                }
                .filter { marked != $0 }

            grid.setEdges(state: .disabled, forEdges: otherEdges)

            return
        }

        // Find the face that all path candidate edges share
        let allFaces = normal.map { Set(grid.facesSharing(edge: $0)) }
        if allFaces.count == 0 {
            return
        }

        let commonFaces = allFaces.reduce(allFaces[0]) { result, faces in
            result.intersection(faces)
        }

        // Expect a single common face to work with
        if commonFaces.count != 1 {
            return
        }

        let faceId = commonFaces.first!

        applyToFace(faceId, vertex: vertexIndex)
    }

    func applyToFace(_ face: Face.Id, vertex: Int) {
        if metadata.matchesStoredFaceState(face, from: grid) {
            return
        }
        defer {
            metadata.storeFaceState(face, from: grid)
        }

        if grid.isFaceSolved(face) {
            return
        }

        // Requires hint!
        guard let hint = grid.hintForFace(face) else {
            return
        }

        let allEdges = grid.edges(forFace: face)

        let edges = allEdges.filter { grid.edgeSharesVertex($0, vertex: vertex) }

        let normalEdges = edges.filter { grid.edgeState(forEdge: $0) == .normal }

        if normalEdges.isEmpty {
            return
        }

        var leastCount = Int.max

        for edge in normalEdges {
            let edgesPath =
                grid.singlePathEdges(fromEdge: edge)
                .filter { grid.faceContainsEdge(face: face, edge: $0) }

            let edgeCount = edgesPath.count
            leastCount = min(edgeCount, leastCount)

            // If we follow this path, we'll end up with more edges marked than
            // the face requirement; disable this path, then
            if edgeCount > hint {
                grid.setEdges(state: .disabled, forEdges: edgesPath)
            }
        }

        if leastCount >= hint {
            // Disable all edges not sharing the common vertex
            let toDisable = allEdges.filter { !grid.edgeSharesVertex($0, vertex: vertex) }

            grid.setEdges(state: .disabled, forEdges: toDisable)
        }
    }

    /// Analyzes neighboring faces sharing vertices with `faceId`, noting whether
    /// there are any guaranteed entrances from a neighbor into the face based on
    /// line ends or if all possible solutions of the neighbor tile require that
    /// the line cross from it to `faceId`.
    func analyzeVertexEntryPoints(for faceId: Face.Id, hint: Int) {
        if grid.isFaceSolved(faceId) {
            return
        }

        let faceEdges = Set(grid.edges(forFace: faceId))

        for vertex in grid.vertices(forFace: faceId) {
            let edges = Set(grid.edgesSharing(vertexIndex: vertex))
            let ourEdges = faceEdges.intersection(edges)

            let faces = grid.facesSharing(vertexIndex: vertex)

            // Analyze only faces that share a vertex, but not a whole edge
            for other in faces where !grid.facesShareEdge(faceId, other) {
                // Ensure every edge shared by the vertex is either from `faceId`
                // _or_ `other`, to ensure that if the vertex is included in the
                // line, it has to either pass through `faceId` or `other`.
                // This is important for calculating which edges from `faceId`
                // should be affected.
                let theirEdges = Set(grid.edges(forFace: other)).filter {
                    grid.edgeSharesVertex($0, vertex: vertex)
                }
                if edges.subtracting(theirEdges) != ourEdges || edges.subtracting(ourEdges) != theirEdges {
                    continue
                }

                if isVertexSpilling(vertex, from: other, to: faceId) {
                    redirectEntryVertex(vertex, from: other, to: faceId)
                }
            }
        }
    }

    /// Returns `true` if an unfinished line is connecting from `start` to `end`,
    /// or if the only possible solution paths for `start` include moving the
    /// line across from its edge into another edge of `end`.
    ///
    /// Note: Assumes faces share `vertex`, but no edges.
    func isVertexSpilling(_ vertex: Int, from start: Face.Id, to end: Face.Id) -> Bool {
        let solutions =
            grid.permuteSolutionsAsEdges(forFace: start)
        
        let startEdges =
            grid.edges(forFace: start)
            .filter { grid.edgeSharesVertex($0, vertex: vertex) }

        guard !solutions.isEmpty else {
            return false
        }
        guard startEdges.count == 2 else {
            return false
        }

        // If all solutions include exactly one of the two edges that share the
        // vertex in 'start', this implies the line has to cross from one face
        // to the other.
        for solution in solutions {
            let inter = solution.intersection(startEdges)
            if inter.count != 1 {
                return false
            }
        }

        return true
    }

    // Forces the entry of the line from one face to another, going through a
    // given vertex index shared amongst each face.
    //
    // Note: Assumes that the two faces do not share an edge.
    func redirectEntryVertex(_ vertexIndex: Int, from start: LoopyGrid.FaceId, to faceId: LoopyGrid.FaceId) {
        let faceEdges = Set(grid.edges(forFace: faceId))
        let permutations = 
            grid.permuteSolutionsAsEdges(forFace: faceId)
            // Only consider solutions where exactly one edge of `faceId`
            // participates in the vertex
            .filter {
                $0.count(where: { grid.edgeSharesVertex($0, vertex: vertexIndex) }) == 1
            }
        
        // Find edges that are present across all solutions
        let permanent = permutations.reduce(faceEdges) {
            $0.intersection($1)
        }
        // Find edges that don't participate at all in any solution
        let notPresent = permutations.reduce(faceEdges) {
            $0.subtracting($1)
        }

        grid.setEdges(state: .disabled, forEdges: notPresent)
        grid.setEdges(state: .marked, forEdges: permanent)
    }

    func analyzeForkingHintedEdgesPath(for faceId: Face.Id, hint: Int) {
        if grid.isFaceSolved(faceId) {
            return
        }

        let vertices = grid.vertices(forFace: faceId)
        let faceEdges = Set(grid.edges(forFace: faceId))
        let enabledEdges =
            grid.edgeCount(forFace: faceId)
            - grid.edgeCount(withState: .disabled, onFace: faceId)

        // Look for edges perpendicular (i.e., sharing only one vertex with the
        // face) and analyze the neighboring edges (which are connected to the face)
        for vertex in vertices {
            let edgesOnVertex = grid.edgesSharing(vertexIndex: vertex)
            guard
                let entryEdge = edgesOnVertex.only(where: { grid.edgeState(forEdge: $0) == .marked }
                )
            else {
                continue
            }
            // One edge exactly must be connected from outside to the face (shares
            // one vertex with face), while the remaining must be part of the face
            // (sharing both vertices with face)
            guard edgesOnVertex.count(1, where: { !grid.faceContainsEdge(face: faceId, edge: $0) })
            else {
                continue
            }
            // Entry edge must be the perpendicular edge
            guard !grid.faceContainsEdge(face: faceId, edge: entryEdge) else {
                continue
            }

            // Edge.Id: Edge which starts this path
            // Int:     Count of edges forming single path from this edge on
            var paths: [(Edge.Id, Int)] = []

            for faceEdge in edgesOnVertex where faceEdge != entryEdge {
                let path = grid.singlePathEdges(fromEdge: faceEdge, excludeDisabled: true)

                // If we take this path, how many enabled edges which are sides
                // of the analyzed face will we end up with?
                let count = Set(path).count(where: faceEdges.contains)

                paths.append((faceEdge, count))
            }

            // If at least one of the paths, when not chosen, results in less
            // enabled edges than we need to complete the hint, disable all other
            // edges found (note that this algorithm takes in consideration many
            // paths, but in reality `paths.count` is at most 2
            if paths.contains(where: { enabledEdges - $1 < hint }) {
                for path in paths where enabledEdges - path.1 >= hint {
                    grid.setEdge(state: .disabled, forEdge: path.0)
                }
            }
        }
    }
}
