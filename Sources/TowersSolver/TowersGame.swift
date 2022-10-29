import Commons

public class TowersGame: GameDescriptor {
    public init() {

    }
    
    public func createSolver(_ state: Grid) -> Solver {
        return Solver(grid: state)
    }

    public func createSolver(fromGameId gameId: String) throws -> Solver {
        let gen = try GridGenerator(gameId: gameId)

        return createSolver(gen.grid)
    }
}
