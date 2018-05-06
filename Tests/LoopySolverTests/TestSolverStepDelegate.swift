import LoopySolver

class TestSolverStepDelegate: SolverStepDelegate {
    var isInconsistentState: Bool = false
    
    func solverStepDidReportInconsistentState(_ step: SolverStep) {
        isInconsistentState = true
    }
}
