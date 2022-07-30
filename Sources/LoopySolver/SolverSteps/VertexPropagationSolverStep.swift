// TODO: Remove the redundant functionality from CornerEntrySolverStep that
// replicates the behavior of this solver, but without recursive propagation.

/// Performs propagation of vertex-type entrances into certain face configurations.
///
/// When a vertex entrance is detected on a hinted tile, a permutation is
/// performed to find out vertex exits from the same face, propagating forwards
/// until a non-hinted tile is found, or a line can be created with the present
/// information.
///
/// This allows the solver to detect entrances to a face based on the neighboring
/// faces' states:
///
/// input:
///     •───•
///   1 |   |
/// •───•───•
/// |   | 1 |
/// •───•───•
///
/// result:
///     •───•
///   1 |   |
/// •───•───•
/// |   | 1  
/// •───•   •
///
/// The recursive nature of the propagation also allows cascading of vertex
/// entries across multiple faces:
///
/// input:
///     •───•───•───•
///   1 |   |   |   |
/// •───•───•───•───•
/// |   | 2 |   |   |
/// •───•───•───•───•
/// |   |   | 2 |   |
/// •───•───•───•───•
/// |   |   |       |
/// •───•───•───•───•
///
/// result:
///     •───•───•───•
///   1 |   |   |   |
/// •───•───•───•───•
/// |   | 2 |   |   |
/// •───•───•───•───•
/// |   |   | 2 |   |
/// •───•───•───•===•
/// |   |   |       |
/// •───•───•───•───•
///
public class VertexPropagationSolverStep: SolverStep {
    public func apply(to grid: LoopyGrid, _ delegate: SolverStepDelegate) -> LoopyGrid {
        let solver = InternalSolver(grid: grid, delegate: delegate)

        solver.apply()

        return solver.grid
    }
}

private class InternalSolver {
    var grid: LoopyGrid
    var delegate: SolverStepDelegate

    var hintedFaces: Set<LoopyGrid.FaceId>

    init(grid: LoopyGrid, delegate: SolverStepDelegate) {
        self.grid = grid
        self.delegate = delegate

        hintedFaces = Set(grid.faceIds.filter { grid.hintForFace($0) != nil })
    }

    func apply() {
        var visited: Set<FaceEntry> = []
        var queue = collectCandidates()

        while !queue.isEmpty {
            let face = queue.removeFirst()

            apply(to: face, visited: &visited, queue: &queue)
        }
    }

    func apply(to entry: FaceEntry, visited: inout Set<FaceEntry>, queue: inout [FaceEntry]) {
        // Check if the vertex has a single available shared edge within this
        // face - if so, mark the edge and continue checking permutations
        let faceEdges = Set(grid.edges(forFace: entry.face))
        let edgesOnVertex = faceEdges.intersection(grid.edgesSharing(vertexIndex: entry.vertexIndex))
        let enabledEdgesOnVertex =
            edgesOnVertex
            .filter {
                grid.edgeState(forEdge: $0) == .normal
            }
        let markedEdgesOnVertex = grid.markedEdges(forVertex: entry.vertexIndex)
        
        if enabledEdgesOnVertex.count == 1 && markedEdgesOnVertex == 0 {
            grid.setEdges(state: .marked, forEdges: enabledEdgesOnVertex)
        }

        // For hinted tiles, we can fix the entry edges and iterate over the
        // resulting solutions, flagging edges that are common across all
        // solutions as well as edges that don't show up in any solution
        if grid.hintForFace(entry.face) != nil && !grid.facesShareEdge(entry.face, entry.start) {
            var solutions = grid.permuteSolutionsAsEdges(forFace: entry.face)
            solutions = filterSolutionsToEntranceVertex(solutions, sharedEdges: entry.sharedEdges, vertex: entry.vertexIndex)

            let toMark = solutions.reduce(faceEdges) {
                $0.intersection($1)
            }
            let toDisable = solutions.reduce(faceEdges) {
                $0.subtracting($1)
            }

            grid.setEdges(state: .marked, forEdges: toMark)
            grid.setEdges(state: .disabled, forEdges: toDisable)
        }

        for candidate in inspectCandidate(face: entry.face, entry: entry.start, sharedEdges: entry.sharedEdges, markingVertex: entry.vertexIndex) {
            if visited.insert(candidate).inserted {
                queue.append(candidate)
            }
        }
    }

    func collectCandidates() -> [FaceEntry] {
        var result: [FaceEntry] = []

        for face in grid.faceIds {
            result.append(contentsOf: inspectCandidate(face: face, entry: nil))
        }

        return result
    }

    func inspectCandidate(
        face: FaceReferenceConvertible,
        entry: FaceReferenceConvertible?,
        sharedEdges: Set<LoopyGrid.EdgeId> = [],
        markingVertex: Int? = nil
    ) -> [FaceEntry] {
        
        guard hintedFaces.contains(face.id) else {
            return []
        }
        guard !grid.isFaceSolved(face) else {
            return []
        }
        
        let faceEdges = grid.edges(forFace: face)
        let adjacent =
            grid.facesVertexAdjacent(to: face)
            .union(grid.facesEdgeAdjacent(to: face))

        var solutions =
            grid.permuteSolutionsAsEdges(forFace: face)
        
        // If `alternativeStartEntryVertex` is present, ensure that only
        // permutations that take that vertex as an entry to 'start' are considered.
        // If any solution includes a shared edge, this restriction is lifted for
        // those cases.
        if let markingVertex = markingVertex {
            solutions = filterSolutionsToEntranceVertex(solutions, sharedEdges: sharedEdges, vertex: markingVertex)
        }
        
        guard !solutions.isEmpty else {
            return []
        }
        
        var result: [FaceEntry] = []

        for other in adjacent {
            guard other != entry?.id else {
                continue
            }

            if hintedFaces.contains(other) && grid.isFaceSolved(other) {
                continue
            }

            let vertices = grid.sharedVertices(between: face, other)

            for vertex in vertices {
                let startEdges =
                    faceEdges.filter { grid.edgeSharesVertex($0, vertex: vertex) }

                guard startEdges.count == 2 else {
                    continue
                }

                guard isVertexSpilling(vertex, from: face, startPermutations: solutions, to: other, alternativeStartEntryVertex: markingVertex) else {
                    continue
                }

                let sharedEdgeInSolutions: Set<Edge.Id> =
                    Set(faceEdges)
                    .intersection(grid.edges(forFace: other))
                    .filter { edge in
                        solutions.contains { solution in
                            solution.contains(edge)
                        }
                    }

                result.append(FaceEntry(face: other, start: face.id, sharedEdges: sharedEdgeInSolutions, vertexIndex: vertex))
            }
        }

        return result
    }

    // TODO: Reduce duplication of this function on CornerEntrySolverStep

    /// Returns `true` if an unfinished line is connecting from `start` to `end`,
    /// or if the only possible solution paths for `start` include moving the
    /// line across from its edge into another edge of `end`.
    ///
    /// Note: Assumes faces share `vertex`, but no edges.
    func isVertexSpilling(
        _ vertex: Int,
        from start: FaceReferenceConvertible,
        startPermutations solutions: [Set<LoopyGrid.EdgeId>],
        to end: FaceReferenceConvertible,
        alternativeStartEntryVertex: Int? = nil
    ) -> Bool {
        let edges = grid.edges(forFace: start)

        let startEdges =
            edges.filter { grid.edgeSharesVertex($0, vertex: vertex) }

        // If all solutions include exactly one of the two edges that share the
        // vertex in 'start', this implies the line has to cross from one face
        // to the other
        for solution in solutions {
            let inter = solution.intersection(startEdges)
            if inter.count != 1 {
                return false
            }
        }

        // Ignore the vertex entry if it is shared by an edge that is not exclusive
        // to either the start or end faces, or is not shared by either
        let vertexEdges = grid.edgesSharing(vertexIndex: vertex)
        for vertexEdge in vertexEdges {
            let isStartEdge = grid.faceContainsEdge(face: start.id, edge: vertexEdge)
            let isEndEdge = grid.faceContainsEdge(face: end.id, edge: vertexEdge)

            // If both are true, the faces share the edge - if both are false,
            // the edge belongs to an intermediary face connected to the vertex
            switch (isStartEdge, isEndEdge) {
            case (true, _), (_, true):
                continue
            case (false, false):
                return false
            }
        }

        return true
    }

    /// From an input set of solutions, trim solutions that don't include exactly
    /// a single edge containing 'vertex' in the set.
    func filterSolutionsToEntranceVertex(
        _ solutions: [Set<LoopyGrid.EdgeId>],
        sharedEdges: Set<LoopyGrid.EdgeId>,
        vertex: Int
    ) -> [Set<LoopyGrid.EdgeId>] {

        return solutions.filter { solution in
            if !solution.isDisjoint(with: sharedEdges) {
                return true
            }
            
            return solution.count(1, where: { grid.edgeSharesVertex($0, vertex: vertex) })
        }
    }
}

/// An entry produced to perform the entrance checks with.
private struct FaceEntry: Hashable {
    /// The ID of the face that needs to be checked.
    var face: LoopyGrid.FaceId

    /// The ID of the face that the line is exiting from.
    var start: LoopyGrid.FaceId

    /// Contains one or more edges that are common between the two faces that
    /// where used in 'start' to produce this entry.
    var sharedEdges: Set<LoopyGrid.EdgeId>

    /// The index of the vertex that is being propagated to this face.
    /// Is also shared by the start face.
    var vertexIndex: Int
}
