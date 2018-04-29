/// A simple solver step that marks edges of faces which have exactly the same
/// number of non-disabled edges as their hint as being part of the solution.
///
/// This step also marks remaining edges of faces that are already solved as disabled.
public class ExactEdgeCountSolverStep: SolverStep {
    public func apply(to grid: LoopyGrid) -> LoopyGrid {
        let controller = LoopyGridController(grid: grid)
        
        for faceId in grid.faceIds {
            let face = grid.faceWithId(faceId)
            let edges = face.localToGlobalEdges.edges(in: grid)
            
            let enabledEdges = edges.filter { $0.isEnabled }
            
            if enabledEdges.count == face.hint {
                controller.setEdges(state: .marked, forEdges: enabledEdges)
                continue
            }
            
            let markedEdges = edges.filter { $0.state == .marked }
            let normalEdges = edges.filter { $0.state == .normal }
            
            if markedEdges.count == face.hint {
                controller.setEdges(state: .disabled, forEdges: normalEdges)
            }
        }
        
        return controller.grid
    }
}
