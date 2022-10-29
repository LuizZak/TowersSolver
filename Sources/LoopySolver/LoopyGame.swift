import Commons

public class LoopyGame: GameDescriptor {
    public init() {

    }
    
    public func createSolver(_ state: LoopyGrid) -> Solver {
        return Solver(grid: state)
    }

    public func createSolver(fromGameId gameId: String) throws -> Solver {
        let grid = try LoopyGridLoader.loadFromGameID(gameId)

        return createSolver(grid)
    }
}
