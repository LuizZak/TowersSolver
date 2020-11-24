/// Solver for a Net game
public final class Solver {
    private(set) public var grid: Grid
    
    public init(grid: Grid) {
        self.grid = grid
    }
    
    /// Attempts to solve the grid for this solver, returning a boolean value
    /// indicating whether the solve attempt succeeded.
    public func solve() -> Bool {
        return false
    }
}

extension Solver {
    
}
