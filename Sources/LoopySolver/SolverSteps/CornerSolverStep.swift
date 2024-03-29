/// Solves grid cells that are on a corner in some scenarios:
///
/// 1. When the number of required edges exceeds edges not shared with another
/// face.
///
///     In this case, the outer edges cannot be part of the solution, since their
///     singular path would exceed the solution of the face.
///
/// 2. When the number of required edges shared amongst other cells is smaller
/// than the required solution of the cell.
///
///     This indicates that the cell's outer edges are all part of the solution.
///
///     This only works for cells that have a single sequential number of edges that
///     are outside the graph and not connected to other faces.
///
/// 3. When the number of shared and non-shared edges both match the requirement
/// for the face, this means that the solution is either a single continuous line
/// passing through the inner shared edges, or the outer non-shared edges. Any
/// other combination of solution would result in either more or less edges being
/// marked for the face.
///
/// 3.1. When 3. applies, if the inner path of the line traverses through a
/// face that has hint matching `edges_count - 1`, the inner path cannot
/// be taken, since that face would ultimately hijack the loopy line path
/// around itself in order to satisfy its own edge count.
/// This rule does not apply if the face in question shares one of the
/// two vertices where the inner and outer path for the corner face join.
public class CornerSolverStep: SolverStep {
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
        for id in grid.faceIds {
            applyToFace(id)
        }
    }

    func applyToFace(_ faceId: Face.Id) {
        // Requires hint!
        guard let hint = grid.hintForFace(faceId) else {
            return
        }

        let edges = grid.edges(forFace: faceId)

        // Store last face shape so we don't redo work unnecessarily
        if metadata.matchesStoredFaceState(faceId, from: grid) {
            return
        }
        defer {
            metadata.storeFaceState(faceId, from: grid)
        }

        if grid.isFaceSolved(faceId)
            && !edges.contains(where: { grid.edgeState(forEdge: $0) == .normal })
        {
            return
        }

        let linearPaths =
            grid
            .ignoringDisabledEdges()
            .linearPathGraphEdges(around: faceId.id)
            .map {
                $0.filter { grid.faceContainsEdge(face: faceId, edge: $0) }
            }

        // 1.
        // Detect sequential edges that exceed the required number for the face
        for path in linearPaths {
            if path.count > hint {
                grid.setEdges(state: .disabled, forEdges: path)
            }
        }

        // Grab all connected edges that form a linear path of length longer than
        // one.
        // These will be our edges for testing with.
        let longLinearPaths = linearPaths.filter { $0.count > 1 }
        if longLinearPaths.count != 1 {
            return
        }

        let nonShared = longLinearPaths[0]

        // Can only apply next solving logics when the non-shared edges form a
        // single sequential line across the outer side of the face
        if !grid.isUniqueSegment(nonShared) || grid.isLoop(nonShared) {
            return
        }

        // 2.
        // If the number of edges that are shared amount to less than the required
        // edges for the solution, this means that all outer edges are part of the
        // solution, since at least one of the outer edges will have to be marked
        // to be part of the solution, and if a single outer edge is marked, all
        // outer edges must be marked due to them forming a single continuous line.
        if grid.edges(forFace: faceId).count - nonShared.count < hint {
            grid.setEdges(state: .marked, forEdges: nonShared)
            return
        }

        // Sort edges found such that we get an array of edges from start to end
        let sorted = nonShared.sorted(by: {
            let e1 = grid.edgeVertices(forEdge: $0)
            let e2 = grid.edgeVertices(forEdge: $1)

            return e1.end == e2.start
        })

        // 3.
        // If the number of edges outside and inside the grid are the same, and
        // match the hint value, this indicates the solution must pass through
        // all inner edges, _or_ all _outer_ edges.
        // In this case, any edges connected to the joining point between the inner
        // and outer edges (that are not the inner and outer edges themselves)
        // that are _unique_ paths for the line (meaning only a single edge joins
        // from either side of the join vertex, apart from the inner/outer edges)
        // are mandatorily part of the solution, since they are common in the two
        // solution scenarios.
        //
        // For example, in the grid bellow, the `2` cell at the corner can be
        // solved by either passing the loopy line inside or outside its edges,
        // and in both situations the only escape path for the line is through
        // the top-left and bottom-right edges:
        //
        // !___!__
        // | 2 |
        // └---┴--
        //
        // In this case, these paths are mandatorily part of the solution:
        //
        // ║___!__
        // | 2 |
        // └---┴══
        //
        if grid.edges(forFace: faceId).count == nonShared.count * 2 && nonShared.count == hint {
            // Find the out-going edges from the join vertices
            let start =
                grid
                .ignoringDisabledEdges()
                .edgesConnected(to: sorted.first!)
                .filter { !grid.faceContainsEdge(face: faceId, edge: $0) }

            let end =
                grid
                .ignoringDisabledEdges()
                .edgesConnected(to: sorted.last!)
                .filter { !grid.faceContainsEdge(face: faceId, edge: $0) }

            if start.count == 1 {
                grid.setEdges(state: .marked, forEdges: start)
            }
            if end.count == 1 {
                grid.setEdges(state: .marked, forEdges: end)
            }

            // 3.1
            // Test if the outer path is not 'hijacked' by an `edge_count - 1`-hinted
            // face.
            let shared = grid.edges(forFace: faceId)
                .filter { !nonShared.contains($0) }

            // Find vertices where inner and outer paths join (we'll use that to
            // filter the 'hijacking' faces and only apply to those that don't
            // share that vertex).
            let joinVertices =
                Set(shared.map(grid.edgeVertices).flatMap { [$0.start, $0.end] })
                .intersection(
                    nonShared.map(grid.edgeVertices(forEdge:)).flatMap { [$0.start, $0.end] }
                )

            // Find vertices for inner edges (excluding vertices from join above)
            // These are the query vertices we'll use to test for the hijacking
            // faces
            let testVertices = Set(grid.vertices(forFace: faceId)).subtracting(joinVertices)

            for vertex in testVertices {
                let faces =
                    grid
                    .facesSharing(vertexIndex: vertex)
                    // Ignore faces that contain one of the join vertices
                    .filter({ !grid.vertices(forFace: $0).contains(where: joinVertices.contains) })

                if faces.contains(where: grid.isFaceSemiComplete) {
                    // Hijacking!
                    // Mark outer edges as solution and quit.
                    grid.setEdges(state: .disabled, forEdges: shared)
                    grid.setEdges(state: .marked, forEdges: nonShared)
                    return
                }
            }
        }
    }
}
