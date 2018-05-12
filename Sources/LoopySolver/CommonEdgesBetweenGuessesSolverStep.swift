/// A solver step that attempts to make guesses between certain possible paths
/// of the line along faces and, from the result, resolving the common edges
/// between the possible solutions.
///
/// Both common marked and disabled edges from possible path outcomes are detected.
///
/// In the following board, the line can go either left or bottom of the centered
/// `1` cell, and if it does, both paths taken will result in the
///
/// .___.___.___.        .___.___.___.        .___.___.___.
/// !___!___!___!        !___!___!___!        !___!___!___!
/// !___!___!___!        ║₌₌₌║   !___!        .   ║   !___!
/// . 1 !_1_.___! either . 1 .₌1₌.___!   or   . 1 ║ 1 .___!
/// .___║___!___!        .___║___!___!        .___║___!___!
/// !___!___!___!        !___!___!___!        !___!___!___!
///
/// Results in common marked edges shown in this mask:
///
/// .   .   .   .                .   .   .   .
/// .   .   .   .  <- marked     .   .   .   .
/// .   ║   .   .     edges      .   .₌₌₌.   .
/// . 1 . 1 .   .                . 1 . 1 .   .
/// .   .   .   .   disabled     .   .   .   .
/// .   .   .   .      edges ->  .   .   .   .
///
/// So both changes would be made accordingly.
///
public class CommonEdgesBetweenGuessesSolverStep: SolverStep {
    public func apply(to grid: LoopyGrid, _ delegate: SolverStepDelegate) -> LoopyGrid {
        let solver = InternalSolver(grid: grid, solverStep: self, delegate: delegate)
        solver.apply()
        return solver.grid
    }
}

private class InternalSolver {
    var controller: LoopyGridController
    var solverStep: SolverStep
    var delegate: SolverStepDelegate
    
    var grid: LoopyGrid {
        return controller.grid
    }
    
    init(grid: LoopyGrid, solverStep: SolverStep, delegate: SolverStepDelegate) {
        controller = LoopyGridController(grid: grid)
        self.solverStep = solverStep
        self.delegate = delegate
    }
    
    func apply() {
        let candidates = collectCandidates()
        for candidate in candidates {
            if apply(on: candidate) {
                return
            }
        }
    }
    
    func apply(on candidate: Candidate) -> Bool {
        var results: [LoopyGrid] = []
        var badEdges: [Edge.Id] = []
        
        // Create sub-solvers with no guessings enabled to test the side effects
        for edge in candidate.edges where delegate.canSolverStepPerformGuessAttempt(solverStep) {
            var testGrid = grid
            testGrid.withEdge(edge) {
                $0.state = .marked
            }
            
            let didSolve = delegate.withSubsolver(grid: testGrid) { solver -> Bool in
                solver.maxNumberOfGuesses = 0
                
                _=solver.solve()
                
                if solver.isSolved {
                    // Marking this edge resulted in a proper solution!
                    controller.grid = solver.grid
                    
                    return true
                } else if !solver.isConsistent {
                    // This edge is a bad edge to play! Mark it into a set of edges
                    // to disable separately
                    badEdges.append(edge)
                } else {
                    results.append(solver.grid)
                }
                
                return false
            }
            
            if didSolve {
                return true
            }
        }
        
        var modified = false
        
        // Now check common edge states across results
        for id in grid.edgeIds {
            let states = results.reduce(Set([.disabled, .marked, .normal])) { $0.intersection([$1.edgeState(forEdge: id)]) }
            
            // Pick edges that have the same exact result across all candidate solutions
            // for the vertex
            if states.count == 1, let state = states.first {
                if state != .normal, grid.edgeState(forEdge: id) != state {
                    controller.setEdge(state: state, forEdge: id)
                    modified = true
                }
            }
        }
        
        // Disable bad edges
        for edge in badEdges {
            controller.setEdge(state: .disabled, forEdge: edge)
            modified = true
        }
        
        return modified
    }
    
    /// Collects candidate edges to apply the common edges logic to
    func collectCandidates() -> [Candidate] {
        var candidates: [Candidate] = []
        
        for v in 0..<grid.vertices.count {
            if let candidate = candidate(forVertex: v) {
                candidates.append(candidate)
            }
        }
        
        for f in grid.faceIds {
            if let candidate = candidate(forFace: f) {
                candidates.append(candidate)
            }
        }
        
        return candidates
    }
    
    /// Returns a candidate set of edges to play based on a given face's state.
    func candidate(forFace face: Face.Id) -> Candidate? {
        // Can only work on hinted faces!
        guard let hint = grid.hintForFace(face) else {
            return nil
        }
        
        // Avoid wasting expensive time looking into already solved faces
        if grid.isFaceSolved(face) {
            return nil
        }
        
        if grid.edgeCount(withState: .marked, onFace: face) == hint - 1 {
            let edges =
                grid.edges(forFace: face)
                    .filter({ grid.edgeState(forEdge: $0) == .normal })
            
            if !edges.isEmpty {
                return Candidate(edges: edges)
            }
        }
        
        return nil
    }
    
    /// Returns a candidate set of edges to inspect based on information from a
    /// given vertex.
    func candidate(forVertex v: Int) -> Candidate? {
        // Test vertices that form incomplete loopy lines (marked edge count
        // around vertex is equal to one)
        let edges = grid.edgesSharing(vertexIndex: v)
        
        let edgesMarked = edges.filter {
            grid.edgeState(forEdge: $0) == .marked
        }
        
        guard edgesMarked.count == 1 else {
            return nil
        }
        
        let edgesNormal = edges.filter {
            grid.edgeState(forEdge: $0) == .normal
        }
        
        // Dead end!
        guard edgesNormal.count > 0 else {
            return nil
        }
        
        // Find a common connected face to inspect by checking for faces sharing
        // the non-disabled and non-marked edges sharing the vertex.
        let commonFaces = edgesNormal
            .map(grid.facesSharing(edge:))
            .map(Set.init)
            .reduce(Set(grid.facesSharing(vertexIndex: v))) { $1.intersection($0) }
        
        // Can only inspect if one common face is sharing the edge, to deduce path
        // results.
        guard commonFaces.count == 1, let face = commonFaces.first else {
            return nil
        }
        
        guard let hint = grid.hintForFace(face) else {
            return nil
        }
        
        // Check for almost complete faces. These should give us the best results,
        // since marking their edges results in other edges being disabled, leading
        // to better overall side effects to inspect.
        guard grid.edgeCount(withState: .marked, onFace: face) == hint - 1 else {
            return nil
        }
        
        return Candidate(edges: edgesNormal)
    }
    
    struct Candidate {
        var edges: [Edge.Id]
    }
}
