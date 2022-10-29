/// Common protocol for game solvers
public protocol GameSolverType {
    /// Gets the current solver state.
    var state: SolverState { get }

    /// Requests that the current internal game state be solved, returning a
    /// value indicating the last solver state achieved.
    func solve() -> SolverState
}

/// Indicates the internal state of a solver.
public enum SolverState {
    /// An unsolved game state. Indicates that either an attempt to solve a game
    /// hasn't been invoked yet, or that the solver cannot further progress from
    /// the current state.
    case unsolved

    /// A solved game state.
    case solved

    /// Indicates that the game state was determined to be unsolvable according
    /// to the game's rules.
    ///
    /// Differs from `.invalid` in that the game state is initially consistent,
    /// but leads to unsolvable states.
    case unsolvable

    /// Indicates that the game state provided was determined to be invalid
    /// according to the game's rules.
    ///
    /// Differs from `.unsolvable` in that the game state is not consistent from
    /// the get go.
    case invalid
}
