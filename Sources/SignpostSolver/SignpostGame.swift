import Commons

public class SignpostGame: GameDescriptor {
    public init() {

    }
    
    public func createSolver(_ state: Grid) -> Solver {
        return Solver(grid: state)
    }

    public func createSolver(fromGameId gameId: String) throws -> Solver {
        let gen = try SignpostGridGenerator(gameId: gameId)

        return createSolver(gen.grid)
    }
}
