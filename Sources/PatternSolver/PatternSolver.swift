import Commons
import Interval

public class PatternSolver: GameSolverType {
    private(set) public var state: SolverState
    private(set) public var grid: PatternGrid

    public init(grid: PatternGrid) {
        self.grid = grid
        state = .unsolved
    }

    public func solve() -> SolverState {
        return state
    }

    /// From a given set of tiles and a list of dark tile runs, returns an interval
    /// for each run, where the interval represents the tiles of that run that
    /// overlap with itself when the runs are laid out from left-most to
    /// right-most order, in the available spaces in `tiles`.
    ///
    /// A `nil` value indicates that the run does not overlap with itself, and
    /// thus no clues can be derived from it.
    ///
    /// The number of entries in the returned array is the same as `runs.runCount`.
    func overlappingRuns(in runs: PatternGrid.RunsHint, tiles: [PatternTile]) -> [Interval<Int>?] {
        return (0..<runs.runCount).map { _ in
            nil
        }
    }
}
