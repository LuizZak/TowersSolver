/// Solver step that looks for any face that has an isolated number of edges that
/// can be inferred as the only solution for the cell.
///
/// E.g. on the following grid:
///
/// ```
/// •───•───•───•
/// │   │ 2 │   │
/// •───•───•───•
/// ║   │ 3 │   ║
/// •   •───•   •
/// ║ 2       2 ║
/// •═══•═══•═══•
/// ```
/// The center cell which requires three edges must have its left, bottom and
/// right edges marked as part of the solution.
public class SinglePathSolverStep: SolverStep {
    public func apply(to grid: LoopyGrid) -> LoopyGrid {
        let solver = InternalSolver(grid: grid)
        solver.apply()
        
        return solver.grid
    }
}

private class InternalSolver {
    var controller: LoopyGridController
    
    var grid: LoopyGrid {
        return controller.grid
    }
    
    init(grid: LoopyGrid) {
        controller = LoopyGridController(grid: grid)
    }
    
    func apply() {
        for face in grid.faceIds {
            applyToFace(face)
        }
    }
    
    func applyToFace(_ face: Face.Id) {
        if grid.isFaceSolved(face) {
            return
        }
        
        guard let hint = grid.hintForFace(face) else {
            return
        }
        
        // Collect edges
        var edgeRuns: [[Edge.Id]] = []
        
        for edge in grid.edges(forFace: face) {
            if edgeRuns.contains(where: { $0.contains(edge) }) {
                continue
            }
            
            let path = GraphUtils.singlePathEdges(in: grid, fromEdge: edge)
            edgeRuns.append(path.compactMap(grid.edgeId(forEdge:)))
        }
        
        guard !edgeRuns.isEmpty else {
            return
        }
        
        edgeRuns.sort(by: { $0.count > $1.count })
        
        if edgeRuns[0].count == hint && grid.edges(forFace: face).count - edgeRuns[0].count < hint {
            controller.setEdges(state: .marked, forEdges: edgeRuns[0])
        }
    }
}
