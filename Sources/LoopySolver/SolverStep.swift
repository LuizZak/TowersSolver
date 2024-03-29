/// A protocol for objects capable of performing discrete solution steps on a loopy
/// field.
public protocol SolverStep: AnyObject {
    static var metadataKey: String { get }

    /// Whether this solver step should be removed from the solve loop after it
    /// has been executed at least once.
    var isEphemeral: Bool { get }

    func apply(to grid: LoopyGrid, _ delegate: SolverStepDelegate) -> LoopyGrid
}

extension SolverStep {
    public static var metadataKey: String {
        return "\(self)"
    }

    public var isEphemeral: Bool {
        return false
    }
}

/// A delegate for solver steps to call to report invalid states ahead of time
/// during their analysis.
public protocol SolverStepDelegate: AnyObject {
    /// Gets the shared metadata for a given solver step type.
    ///
    /// If no metadata is available, one is created for the solver step.
    func metadataForSolverStepClass<T: SolverStep>(_ solverStepType: T.Type) -> SolverStepMetadata

    /// Called by a SolverStep when an invalid state is diagnosed ahead of time.
    func solverStepDidReportInconsistentState(_ step: SolverStep)

    /// Called to notify that a solver step performed a guessing attempt.
    func solverStepDidPerformGuess(_ step: SolverStep)

    /// Called by a solver type to query whether any attempts at guessing can be
    /// performed.
    func canSolverStepPerformGuessAttempt(_ step: SolverStep) -> Bool

    /// Requests a sub-solver with a specified grid to use in a temporary solution
    /// attempt.
    /// Guesses applied to this sub-solver count towards any parent solver's
    /// guess attempt count.
    func withSubsolver<T>(grid: LoopyGrid, do closure: (Solver) throws -> T) rethrows -> T
}
