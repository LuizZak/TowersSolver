import Commons

public class PatternGame: GameDescriptor {
    public typealias GameState = PatternGrid
    public typealias SolverType = PatternSolver

    public init() {
        
    }

    public func createSolver(_ state: PatternGrid) -> PatternSolver {
        PatternSolver(grid: state)
    }

    public func createSolver(fromGameId gameId: String) throws -> PatternSolver {
        let gen = try PatternGridGenerator(gameId: gameId)

        return createSolver(gen.grid)
    }
}
