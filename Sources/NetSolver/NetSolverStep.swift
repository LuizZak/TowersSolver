/// Delegate for a solver which can be used to enqueue subsequent solver steps
protocol NetSolverDelegate {
    func enqueue(_ step: NetSolverStep)
}

/// A solver step for a Net game
protocol NetSolverStep {
    func apply(on grid: Grid, delegate: NetSolverDelegate) -> Grid
}
