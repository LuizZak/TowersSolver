/// A solver step that looks for vertices which feature two marked edges and marks
/// all remaining edges as not part of the solution (since these would result in
/// an intersecting loopy line at that vertex)
public class TwoEdgesPerVertexSolverStep: SolverStep {
    public func apply(to grid: LoopyGrid) -> LoopyGrid {
        let controller = LoopyGridController(grid: grid)
        
        for vertex in 0..<grid.vertices.count {
            let edges = grid.edgesSharing(vertexIndex: vertex)
            let marked = edges.count { grid.edgeState(forEdge: $0) == .marked }
            
            if marked == 2 {
                let toDisable = edges.filter { grid.edgeState(forEdge: $0) != .marked }
                controller.setEdges(state: .disabled, forEdges: toDisable)
            }
        }
        
        return controller.grid
    }
}
