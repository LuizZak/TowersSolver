/// Delegate for a solver which can be used to enqueue subsequent solver steps
protocol NetSolverDelegate {
    /// Enqueues a given solver step so it can be performed later
    func enqueue(_ step: NetSolverStep)
}
