/// Solver for a Loopy match
public class Solver {
    /// Set to `true` when a solver step reports an invalid state before it can
    /// be detected by the solver via `isConsistent`
    private var _diagnosedInconsistentState: Bool = false
    private var steps: [SolverStep] = []
    
    private(set) public var grid: LoopyGrid
    
    /// When the solver gets stuck and requires guessing a possible next play,
    /// this counter controls how many guesses it can attempt before stopping
    /// further guessing attempts.
    public var maxNumberOfGuesses: Int = 10 {
        didSet {
            guessesAvailable = maxNumberOfGuesses
        }
    }
    
    private var guessesAvailable: Int
    
    /// Returns `true` if the solution requirements are met on this solver's grid.
    ///
    /// Requirements for the grid to be considered solved:
    ///
    /// 1. A single, non-intersecting loop must be present on the grid by means
    /// marked edges. All marked edges must form a continuous loop.
    ///
    /// 2. All numbered faces must have that number of their edges marked as part
    /// of the solution.
    public var isSolved: Bool {
        for face in grid.faceIds {
            guard let hint = grid.hintForFace(face) else { continue }
            
            let marked =
                grid.edges(forFace: face)
                    .count { grid.edgeState(forEdge: $0) == .marked }
            
            if marked != hint {
                return false
            }
        }
        
        let markedEdges = grid.edgeIds.filter { grid.edgeState(forEdge: $0) == .marked }
        if !grid.isLoop(markedEdges) {
            return false
        }
        
        return true
    }
    
    /// Returns a value specifying whether the grid in this solver is consistent.
    /// Consistency is based upon a partial or full solution attempt, be that the
    /// target solution to the playfield or not.
    ///
    /// As soon as a undoubtedly invalid state is reached- either by analyzing the
    /// grid or as reported by a SolverStep, which cannot be undone by marking
    /// or disabling edges, a board is considered inconsistent.
    ///
    /// A grid is consistent when all of the following assertions hold:
    ///
    /// 1. A vertex has either zero, one, or two marked edges associated with it.
    /// 2. A face with a hint has less or exactly as many marked edges around it
    /// as its hint indicates.
    /// 3. A face with a hint has more or exactly as many non-disabled edges
    /// around it as its hint indicates.
    /// 4. If a set of edges form a closed loop, all marked edges in the grid
    /// must be part of the loop.
    public var isConsistent: Bool {
        if _diagnosedInconsistentState {
            return true
        }
        
        for i in 0..<grid.vertices.count {
            let edges = grid
                .edgesSharing(vertexIndex: i)
            
            if edges.count(where: { grid.edgeState(forEdge: $0) == .marked }) > 2 {
                return false
            }
        }
        
        for face in grid.faceIds {
            let edges = grid.edges(forFace: face)
            guard let hint = grid.hintForFace(face) else {
                continue
            }
            
            if edges.count(where: { grid.edgeState(forEdge: $0) == .marked }) > hint {
                return false
            }
            if edges.count(where: { grid.edgeState(forEdge: $0).isEnabled }) < hint {
                return false
            }
        }
        
        let marked = grid.edgeIds.filter { grid.edgeState(forEdge: $0) == .marked }
        
        var runs: [[Edge.Id]] = []
        for edge in marked {
            if runs.contains(where: { $0.contains(edge) }) {
                continue
            }
            
            let run =
                grid.singlePathEdges(fromEdge: edge,
                                     includeTest: { grid.edgeState(forEdge: $0) == .marked })
            
            runs.append(run)
        }
        
        if runs.count > 1 && runs.contains(where: grid.isLoop) {
            return false
        }
        
        return true
    }
    
    public init(grid: LoopyGrid) {
        self.grid = grid
        guessesAvailable = maxNumberOfGuesses
        
        addSteps()
    }
    
    private func addSteps() {
        steps.append(ZeroSolverStep())
        steps.append(DeadEndRemovalSolverStep())
        steps.append(CornerSolverStep())
        steps.append(ExactEdgeCountSolverStep())
        steps.append(TwoEdgesPerVertexSolverStep())
        steps.append(SolePathEdgeExtenderSolverStep())
        steps.append(CornerEntrySolverStep())
        steps.append(SinglePathSolverStep())
        steps.append(NeighboringSemiCompleteFacesSolverStep())
        steps.append(NeighboringShortFacesSolverStep())
        steps.append(InvalidLoopClosingDetectionSolverStep())
    }
    
    public func solve() -> Result {
        // Keep applying passes until the grid no longer changes between steps
        while !isSolved && isConsistent {
            var oldGrid = grid
            grid = applySteps(to: grid)
            
            // If no changes where made, try a speculative play here
            if grid == oldGrid {
                
                oldGrid = grid
                
                // Perform a speculative step to attempt solving the grid by making
                // guessing plays.
                speculate()
                
                // No changes detected- stop solve attempts since no further changes
                // will be made, anyway.
                if grid == oldGrid {
                    break
                }
            }
        }
        
        if isSolved {
            // Present a clean solution by disabling remaining normal edges that
            // not part of the solution
            for edge in grid.edgeIds {
                grid.withEdge(edge) { edge in
                    if edge.state == .normal {
                        edge.state = .disabled
                    }
                }
            }
            
            return .solved
        }
        
        return .unsolved
    }
    
    private func applySteps(to grid: LoopyGrid) -> LoopyGrid {
        let delegate = SolverDelegate()
        var grid = grid
        for step in steps where !delegate.isInconsistent {
            grid = step.apply(to: grid, delegate)
        }
        return grid
    }
    
    /// Perform speculative plays where some edges are marked and then consistency
    /// is checked to verify if the edge is not actually part of the solved
    /// puzzle.
    private func speculate() {
        if guessesAvailable == 0 {
            return
        }
        
        let plays = collectSpeculativeSteps().prefix(guessesAvailable)
        
        for play in plays where guessesAvailable > 0 {
            guessesAvailable -= 1
            
            if doSpeculativePlay(play, &guessesAvailable) {
                return
            }
        }
    }
    
    private func doSpeculativePlay(_ edge: Edge.Id, _ guessesAvailable: inout Int) -> Bool {
        let subSolver = Solver(grid: grid)
        subSolver.maxNumberOfGuesses = guessesAvailable
        defer {
            guessesAvailable -= subSolver.maxNumberOfGuesses - subSolver.guessesAvailable
        }
        
        subSolver.grid.withEdge(edge) { $0.state = .marked }
        
        if subSolver.solve() == .solved {
            grid = subSolver.grid
            return true
        }
        
        if !subSolver.isConsistent {
            grid.withEdge(edge) { $0.state = .disabled }
            return true
        }
        
        return false
    }
    
    private func collectSpeculativeSteps() -> [Edge.Id] {
        var plays: [Edge.Id] = []
        
        // Search for vertices with open loop ends to fill
        struct VertEntry {
            var vertex: Int
            var edges: [Edge.Id]
            var priority: Int
        }
        
        var vertEntries: [VertEntry] = []
        
        for i in 0..<grid.vertices.count {
            let edges = grid
                .edgesSharing(vertexIndex: i)
                .filter { grid.edgeState(forEdge: $0).isEnabled }
            
            if edges.count(where: { grid.edgeState(forEdge: $0) == .marked }) == 1 {
                let edgesToPlay = edges
                    .filter { grid.edgeState(forEdge: $0) == .normal }
                
                let hintedFaces =
                    grid.faceIds.count { grid.vertices(forFace: $0).contains(i) && grid.hintForFace($0) != nil }
                let semicompleteFaces =
                    grid.faceIds.count { grid.vertices(forFace: $0).contains(i) && grid.isFaceSemicomplete($0) }
                
                let priority = hintedFaces + semicompleteFaces
                
                vertEntries.append(VertEntry(vertex: i, edges: edgesToPlay, priority: priority))
            }
        }
        
        // Sort entries by number of faces the play would affect to increase chances
        // we find a definite outcome of valid/invalid from the play
        for entry in vertEntries.sorted(by: { $0.priority > $1.priority }) {
            plays.append(contentsOf: entry.edges)
        }
        
        // Look for semi-complete faces that are missing one edge to solve
        for face in grid.faceIds.sorted(by: { (l, _) in grid.isFaceSemicomplete(l) }) {
            let edges = grid.edges(forFace: face)
            
            if edges.count(where: { grid.edgeState(forEdge: $0) == .marked }) + 1 == grid.hintForFace(face) {
                plays.append(contentsOf: edges.filter({ grid.edgeState(forEdge: $0) == .normal }))
            }
        }
        
        return plays
    }
    
    public enum Result {
        case solved
        case unsolved
    }
    
    /// Represents one of the possible speculative play strategies to apply.
    ///
    /// - testIsInvalid: Performs a play where an edge is marked and the grid is
    /// then tested for inconsistencies during normal play.
    /// - play: An edge is marked and further plays happen on the new grid until
    /// either a solution is found or no more valid solutions can be derived from
    /// that point.
    public enum SpeculativePlay {
        case testIsInvalid(Edge)
        case play(Edge)
    }
}

class SolverDelegate: SolverStepDelegate {
    var isInconsistent = false
    
    func solverStepDidReportInconsistentState(_ step: SolverStep) {
        isInconsistent = true
    }
}
