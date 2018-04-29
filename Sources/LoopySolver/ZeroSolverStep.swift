/// Trivial solver step that unmarks the edges of every zero-hinted cell.
public class ZeroSolverStep: SolverStep {
    public func apply(to grid: LoopyGrid) -> LoopyGrid {
        let controller = LoopyGridController(grid: grid)
        
        for faceId in grid.faceIds where grid.faceWithId(faceId).hint == 0 {
            controller.setEdges(state: .disabled, forFace: faceId)
        }
        
        return controller.grid
    }
}
