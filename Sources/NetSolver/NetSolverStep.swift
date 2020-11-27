/// A solver step for a Net game
protocol NetSolverStep {
    func apply(on grid: Grid, delegate: NetSolverDelegate) -> [GridAction]
}
