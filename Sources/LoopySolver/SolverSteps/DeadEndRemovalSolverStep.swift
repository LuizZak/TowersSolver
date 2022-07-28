/// Detects and removes dead-ends of edges that connect to vertices that don't have
/// another valid edge to connect to.
///
/// For example, on the following grid, the top-left edge was marked as disabled
/// and not part of the solution, and the left-most edge is now a dead end edge
/// (the line ends abruptly at the corner):
///
///     .  .__.
///     !__!__!
///
/// This step would remove the dead-end edges until all edges present point to
/// vertices with at least two valid edges:
///
///     .  .__.
///     .  !__!
///
public class DeadEndRemovalSolverStep: SolverStep {
    public func apply(to grid: LoopyGrid, _ delegate: SolverStepDelegate) -> LoopyGrid {
        let solver = InternalSolver(grid: grid)
        solver.apply()

        return solver.grid
    }
}

private class InternalSolver {
    var grid: LoopyGrid

    init(grid: LoopyGrid) {
        self.grid = grid
    }

    func apply() {
        while applyInternal() {
            // Empty
        }
    }

    private func applyInternal() -> Bool {
        var didWork = false

        for i in 0..<grid.vertices.count {
            let edges = grid.edgesSharing(vertexIndex: i)

            let enabledCount = edges.count { grid.edgeState(forEdge: $0).isEnabled }

            if enabledCount == 1 {
                grid.setEdges(
                    state: .disabled,
                    forEdges: edges,
                    where: { $0.state.isEnabled }
                )

                didWork = true
            }
        }

        return didWork
    }
}
