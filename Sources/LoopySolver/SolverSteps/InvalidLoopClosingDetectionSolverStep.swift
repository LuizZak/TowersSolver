/// Detects patterns where a single selected edge between two edges would form a
/// loop, but such loop would be invalid due to it not including other edges.
public class InvalidLoopClosingDetectionSolverStep: SolverStep {
    public func apply(to grid: LoopyGrid, _ delegate: SolverStepDelegate) -> LoopyGrid {
        let solver = InternalSolver(grid: grid, delegate: delegate)
        solver.apply()

        return solver.grid
    }
}

private class InternalSolver {
    var delegate: SolverStepDelegate

    var grid: LoopyGrid

    init(grid: LoopyGrid, delegate: SolverStepDelegate) {
        self.grid = grid
        self.delegate = delegate
    }

    func apply() {
        let metadata =
            delegate.metadataForSolverStepClass(InvalidLoopClosingDetectionSolverStep.self)

        if metadata.isGridStateStored(grid) {
            return
        }

        metadata.storeGridState(grid)

        let entries = collectEdges()
        let allMarked = grid.edgeIds.lazy.filter { self.grid.edgeState(forEdge: $0) == .marked }

        for edge in entries {
            apply(on: edge, allMarked: allMarked)
        }
    }

    private func collectEdges() -> [Entry] {
        var entries: [Entry] = []

        // Search for all edges, unmarked, which connect two vertices that point
        // to two dead-end marked edges (in a 'doorway' or 'window' fashion)
        for edge in grid.edgeIds where grid.edgeState(forEdge: edge) == .normal {
            let edgesSharingStart =
                grid.edgesSharing(vertexIndex: grid.edgeVertices(forEdge: edge).start)

            let _edgesInStart =
                edgesSharingStart
                .only { grid.edgeState(forEdge: $0) == .marked }

            guard let edgesInStart = _edgesInStart else {
                continue
            }

            let edgesSharingEnd =
                grid.edgesSharing(vertexIndex: grid.edgeVertices(forEdge: edge).end)

            let _edgesInEnd =
                edgesSharingEnd
                .only { grid.edgeState(forEdge: $0) == .marked }

            guard let edgesInEnd = _edgesInEnd else {
                continue
            }

            entries.append(
                Entry(
                    edge: edge,
                    firstEdge: edgesInStart,
                    secondEdge: edgesInEnd
                )
            )
        }

        return entries
    }

    private func apply<S: Sequence>(on entry: Entry, allMarked: S) where S.Element == Edge.Id {
        // Check if the edges from the entry link to one another
        let path =
            grid.singlePathEdges(fromEdge: entry.firstEdge) { edge in
                grid.edgeState(forEdge: edge) == .marked
            }

        // If path doesn't include both ends, it won't form a loop
        guard path.contains(entry.secondEdge) else {
            return
        }

        // If the path is actually the combination of all marked edges, then this
        // is just a valid possible path-closing edge.
        guard Set(allMarked) != Set(path) else {
            return
        }

        grid.withEdge(entry.edge) {
            $0.state = .disabled
        }
    }

    private struct Entry: Equatable {
        var edge: Edge.Id

        var firstEdge: Edge.Id
        var secondEdge: Edge.Id
    }
}
