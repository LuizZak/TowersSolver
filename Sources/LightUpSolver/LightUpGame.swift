import Commons

public class LightUpGame: GameDescriptor {
    public init() {

    }
    
    public func createSolver(_ state: LightUpGrid) -> LightUpSolver {
        return LightUpSolver(grid: state)
    }

    public func createSolver(fromGameId gameId: String) throws -> LightUpSolver {
        let gen = try LightUpGridGenerator(gameId: gameId)

        return createSolver(gen.grid)
    }
}
