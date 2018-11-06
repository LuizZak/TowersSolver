/// A solver step that handles cases where a hinted face missing only one marked
/// edge while having two available edges to mark in series both connect to the
/// same one outgoing edge. In cases such as this, it can be verified that the
/// outgoing edge has to be marked, since any of the two possible line paths must
/// cross that edge to escape.
///
/// E.g. in the following case where a 4-cell has three of its edges marked, with
/// two available to chose from, we can infer that following either edge would
/// result in the marked (*) edge to be taken, since choosing either edge automatically
/// invalidates the other as a possible exit path:
///
///     •───•       •───•
///    /     \\          \
///   •       •═══•       •
///    \           \\    /
///     •───•   4   •   •
///    /     \     //    \
///   •       •───•       •
///    \    */     \     /
///     •───•       •───•
///
/// Either:
///
///    •───•       •───•           •───•       •───•
///   /     \\          \         /     \\          \
///  •       •═══•       •       •       •═══•       •
///   \           \\    /         \           \\    /
///    •   •   4   •   •     or    •───•   4   •   •
///   /           //    \         /    \\     //    \
///  •       •═══•       •       •       •   •       •
///   \    //     \     /         \     //    \     /
///    •───•       •───•           •───•       •───•
///
public class BifurcationSolverStep: SolverStep {
    public func apply(to grid: LoopyGrid, _ delegate: SolverStepDelegate) -> LoopyGrid {
        let solver = InnerSolver(grid: grid)
        solver.apply()
        
        return solver.grid
    }
}

private class InnerSolver {
    var grid: LoopyGrid
    
    init(grid: LoopyGrid) {
        self.grid = grid
    }
    
    func apply() {
        for face in grid.faceIds {
            apply(to: face)
        }
    }
    
    func apply(to face: Face.Id) {
        if grid.isFaceSolved(face) {
            return
        }
        
        // Must feature hint!
        guard let hint = grid.hintForFace(face) else {
            return
        }
        
        let markedCount = grid.edgeCount(withState: .marked, onFace: face)
        let enabledCount = grid.edgeCount(withState: .normal, onFace: face)
        
        guard markedCount + enabledCount == hint + 1 && enabledCount == 2 else {
            return
        }
        
        let edges = grid.edges(forFace: face)
        
        guard let (enabled1, enabled2) = edges.onlyTwo(where: { grid.edgeState(forEdge: $0) == .normal }) else {
            return
        }
        
        let enabledEdge1 = grid.edgeWithId(enabled1)
        let enabledEdge2 = grid.edgeWithId(enabled2)
        
        // Must be connected!
        guard let sharedVertex = enabledEdge1.sharedVertex(with: enabledEdge2) else {
            return
        }
        
        // Must share one more edge in common
        let common =
            Set(grid.edgesSharing(vertexIndex: sharedVertex))
                .symmetricDifference([enabled1, enabled2])
        
        if common.count == 1 {
            grid.setEdges(state: .marked, forEdges: common)
        }
    }
}
