/// A protocol for objects capable of performing discrete solution steps on a loopy
/// field.
public protocol SolverStep {
    func apply(to grid: LoopyGrid, _ delegate: SolverStepDelegate) -> LoopyGrid
}

/// A delegate for solver steps to call to report invalid states ahead of time
/// during their analysis.
public protocol SolverStepDelegate {
    /// Called by a SolverStep when an invalid state is diagnosed ahead of time.
    func solverStepDidReportInconsistentState(_ step: SolverStep)
}
