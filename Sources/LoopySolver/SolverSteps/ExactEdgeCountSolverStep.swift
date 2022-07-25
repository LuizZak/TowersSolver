/// A simple solver step that marks edges of faces which have exactly the same
/// number of non-disabled edges as their hint as being part of the solution.
///
/// This step also marks remaining edges of faces that are already solved as disabled.
public class ExactEdgeCountSolverStep: SolverStep {
    public func apply(to grid: LoopyGrid, _ delegate: SolverStepDelegate) -> LoopyGrid {
        let controller = LoopyGridController(grid: grid)

        for face in grid.faceIds {
            let edges = grid.edges(forFace: face)

            if grid.isFaceSolved(face)
                && !edges.contains(where: { grid.edgeState(forEdge: $0) == .normal })
            {
                continue
            }

            let enabledEdgesCount = edges.count { grid.edgeState(forEdge: $0).isEnabled }

            if enabledEdgesCount == grid.hintForFace(face) {
                let enabledEdges = edges.filter { grid.edgeState(forEdge: $0).isEnabled }
                controller.setEdges(state: .marked, forEdges: enabledEdges)
                continue
            }

            let markedEdgesCount = edges.count { grid.edgeState(forEdge: $0) == .marked }

            if markedEdgesCount == grid.hintForFace(face) {
                let normalEdges = edges.filter { grid.edgeState(forEdge: $0) == .normal }
                controller.setEdges(state: .disabled, forEdges: normalEdges)
            }
        }

        return controller.grid
    }
}
