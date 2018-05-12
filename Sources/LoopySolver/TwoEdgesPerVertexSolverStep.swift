/// A solver step that looks for vertices which feature two marked edges and marks
/// all remaining edges as not part of the solution (since these would result in
/// an intersecting loopy line at that vertex)
public class TwoEdgesPerVertexSolverStep: SolverStep {
    public func apply(to grid: LoopyGrid, _ delegate: SolverStepDelegate) -> LoopyGrid {
        let metadata = delegate.metadataForSolverStepClass(type(of: self))
        
        let controller = LoopyGridController(grid: grid)
        
        for vertex in 0..<grid.vertices.count {
            if metadata.matchesStoredVertexState(vertex, from: controller.grid) {
                continue
            }
            defer {
                metadata.storeVertexState(vertex, from: controller.grid)
            }
            
            let marked = grid.markedEdges(forVertex: vertex)
            
            if marked == 2 {
                let edges = grid.edgesSharing(vertexIndex: vertex)
                
                let toDisable = edges.filter { grid.edgeState(forEdge: $0) != .marked }
                controller.setEdges(state: .disabled, forEdges: toDisable)
            }
        }
        
        return controller.grid
    }
}
