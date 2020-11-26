/// Solver step which rotates tiles away from barriers, as well as the map edge,
/// in case the grid is non-wrapping.
/// Only locks and rotates tiles in case
struct AwayFromBarriersSolverStep: NetSolverStep {
    func apply(on grid: Grid, delegate: NetSolverDelegate) -> Grid {
        return grid
    }
}
