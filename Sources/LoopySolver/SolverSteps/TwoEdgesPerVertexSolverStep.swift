/// A solver step that looks for vertices which feature two marked edges and marks
/// all remaining edges as not part of the solution (since these would result in
/// an intersecting loopy line at that vertex)
public class TwoEdgesPerVertexSolverStep: SolverStep {
    public func apply(to grid: LoopyGrid, _ delegate: SolverStepDelegate) -> LoopyGrid {
        let metadata = delegate.metadataForSolverStepClass(type(of: self))

        var grid = grid

        for vertex in 0..<grid.vertices.count {
            let marked = grid.markedEdges(forVertex: vertex)
            guard marked == 2 else {
                continue
            }

            if metadata.matchesStoredVertexState(vertex, from: grid) {
                continue
            }
            defer {
                metadata.storeVertexState(vertex, from: grid)
            }

            let edges = grid.edgesSharing(vertexIndex: vertex)

            let toDisable = edges.filter { grid.edgeState(forEdge: $0) != .marked }

            grid.setEdges(state: .disabled, forEdges: toDisable)
        }

        return grid
    }
}
