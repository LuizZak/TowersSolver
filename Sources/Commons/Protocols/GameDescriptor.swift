/// Provides a standard interface for describing puzzle games in the application.
public protocol GameDescriptor {
    /// A game state/grid associated with this game
    associatedtype GameState

    /// The type of solver associated with this game descriptor.
    associatedtype SolverType: GameSolverType

    /// Requests that a solver be created for a game loaded from a given game id.
    func createSolver(fromGameId gameId: String) throws -> SolverType

    /// Requests that a solver be created for a particular game state.
    func createSolver(_ state: GameState) -> SolverType
}
