import Commons

public class NetGame: GameDescriptor {
    public init() {

    }
    
    public func createSolver(_ state: Grid) -> Solver {
        return Solver(grid: state)
    }

    public func createSolver(fromGameId gameId: String) throws -> Solver {
        let gen = try NetGridGenerator(gameId: gameId)

        return createSolver(gen.grid)
    }
}
