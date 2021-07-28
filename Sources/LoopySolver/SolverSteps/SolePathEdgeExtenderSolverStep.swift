/// A solver step that deals with solution edges that end in vertices with a single
/// possible exit path for the marked edge.
///
/// In the following example, the marked edge ends up in a corner, with some disabled
/// edges around it:
///
///     ........
///     !__.__._ -
///        '
///
/// To satisfy the loop requirement, the line must be extended such that it connects
/// with the only possible next path:
///
///     .__.__._
///     !__.__._ -
///        '
///
public class SolePathEdgeExtenderSolverStep: SolverStep {
    public func apply(to grid: LoopyGrid, _ delegate: SolverStepDelegate) -> LoopyGrid {
        let solver = InternalSolver(grid: grid)
        solver.apply()
        
        return solver.grid
    }
}

private class InternalSolver {
    var grid: LoopyGrid
    
    init(grid: LoopyGrid) {
        self.grid = grid
    }
    
    func apply() {
        applyInternal()
    }
    
    private func applyInternal() {
        var stack: [Int] = []
        var visited: Set<Int> = []
        
        for i in 0..<grid.vertices.count {
            let marked = grid.markedEdges(forVertex: i)
            guard marked == 1 else {
                continue
            }
            
            let edges = grid.edgesSharing(vertexIndex: i)
            let enabled = edges.count { grid.edgeState(forEdge: $0) == .normal }
            guard enabled == 1 else {
                continue
            }
            
            stack.append(i)
        }
        
        while !stack.isEmpty {
            let next = stack.removeLast()
            if visited.contains(next) {
                continue
            }

            visited.insert(next)
            
            let edges = grid.edgesSharing(vertexIndex: next)
            let normal = edges.filter { grid.edgeState(forEdge: $0) == .normal }
            let markedCount = edges.count { grid.edgeState(forEdge: $0) == .marked }
            
            if normal.count == 1 && markedCount == 1 {
                grid.setEdges(state: .marked, forEdges: normal)
                
                for edge in edges {
                    let vertices = grid.vertices(forEdge: edge)
                    
                    if grid.markedEdges(forVertex: vertices.start) == 1 {
                        stack.append(vertices.start)
                    }
                    if grid.markedEdges(forVertex: vertices.end) == 1 {
                        stack.append(vertices.end)
                    }
                }
            }
        }
    }
}
