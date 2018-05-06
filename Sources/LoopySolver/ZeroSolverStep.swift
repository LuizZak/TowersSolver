/// Trivial solver step that unmarks the edges of every zero-hinted cell.
public class ZeroSolverStep: SolverStep {
    public func apply(to grid: LoopyGrid, _ delegate: SolverStepDelegate) -> LoopyGrid {
        let controller = LoopyGridController(grid: grid)
        
        for faceId in grid.faceIds where grid.hintForFace(faceId) == 0 {
            controller.setEdges(state: .disabled, forFace: faceId)
        }
        
        return controller.grid
    }
}
