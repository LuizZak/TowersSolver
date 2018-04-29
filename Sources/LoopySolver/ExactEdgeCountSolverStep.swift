/// A simple solver step that marks edges of faces which have exactly the same
/// number of non-disabled edges as their hint.
public class ExactEdgeCountSolverStep: SolverStep {
    public func apply(to grid: LoopyGrid) -> LoopyGrid {
        let controller = LoopyGridController(grid: grid)
        
        for faceId in grid.faceIds {
            let face = grid.faceWithId(faceId)
            let edges =
                face.localToGlobalEdges
                    .edges(in: grid)
                    .filter { $0.isEnabled }
            
            if edges.count == face.hint {
                controller.setEdges(state: .marked, forEdges: edges)
            }
        }
        
        return controller.grid
    }
}
