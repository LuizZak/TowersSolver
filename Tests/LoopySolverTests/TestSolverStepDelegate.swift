import LoopySolver

class TestSolverStepDelegate: SolverStepDelegate {
    var metadatas: [String: SolverStepMetadata] = [:]

    var isInconsistentState: Bool = false

    public func metadataForSolverStepClass<T: SolverStep>(_ solverStepType: T.Type)
        -> SolverStepMetadata
    {
        let type = "\(solverStepType)"
        return metadatas[type, default: SolverStepMetadata()]
    }

    func solverStepDidReportInconsistentState(_ step: SolverStep) {
        isInconsistentState = true
    }

    func canSolverStepPerformGuessAttempt(_ step: SolverStep) -> Bool {
        return true
    }

    func solverStepDidPerformGuess(_ step: SolverStep) {

    }

    func withSubsolver<T>(grid: LoopyGrid, do closure: (Solver) throws -> T) rethrows -> T {
        let solver = Solver(grid: grid)
        return try closure(solver)
    }
}
