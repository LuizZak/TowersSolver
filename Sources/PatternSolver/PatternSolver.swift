import Commons

public class PatternSolver: GameSolverType {
    private(set) public var state: SolverState
    private(set) public var grid: PatternGrid

    public init(grid: PatternGrid) {
        self.grid = grid
        state = .unsolved
    }

    public func solve() -> SolverState {
        return .invalid
    }
}
