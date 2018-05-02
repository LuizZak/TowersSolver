/// Solver for a Loopy match
public class Solver {
    private var steps: [SolverStep] = []
    
    public var field: LoopyField
    
    /// When the solver gets stuck and requires guessing a possible next play,
    /// this counter controls how many guesses it can attempt before stopping
    /// further guessing attempts.
    public var maxNumberOfGuesses: Int = 5
    
    /// Returns `true` if the solution requirements are met on this solver's field.
    ///
    /// Requirements for the field to be considered solved:
    ///
    /// 1. A single, non-intersecting loop must be present on the field by means
    /// marked edges. All marked edges must form a continuous loop.
    ///
    /// 2. All numbered faces must have that number of their edges marked as part
    /// of the solution.
    public var isSolved: Bool {
        for faceId in field.faceIds {
            let face = field.faceWithId(faceId)
            guard let hint = face.hint else { continue }
            
            let marked =
                face.localToGlobalEdges
                    .edges(in: field)
                    .count { $0.state == .marked }
            
            if marked != hint {
                return false
            }
        }
        
        let markedEdges = field.edges.filter { $0.state == .marked }
        if !markedEdges.isLoop {
            return false
        }
        
        return true
    }
    
    /// Returns a value specifying whether the field in this solver is consistent.
    /// Consistency is based upon a partial or full solution attempt, be that the
    /// target solution to the playfield or not.
    ///
    /// As soon as a undoubtedly invalid state is reached, which cannot be undone
    /// by marking or disabling edges, a board is considered inconsistent.
    ///
    /// A field is consistent when all of the following assertions hold:
    ///
    /// 1. A vertex has either zero, one, or two marked edges associated with it.
    /// 2. A face with a hint has less or exactly as many marked edges around it
    /// as its hint indicates.
    /// 3. A face with a hint has more or exactly as many non-disabled edges
    /// around it as its hint indicates.
    /// 4. If a set of edges form a closed loop, all marked edges in the field
    /// must be part of the loop.
    public var isConsistent: Bool {
        for i in 0..<field.vertices.count {
            let edges = field
                .edgesSharing(vertexIndex: i)
                .edges(in: field)
            
            if edges.count(where: { $0.state == .marked }) > 2 {
                return false
            }
        }
        
        for face in field.faces {
            let edges = field.edges(forFace: face)
            guard let hint = face.hint else {
                continue
            }
            
            if edges.count(where: { $0.state == .marked }) > hint {
                return false
            }
            if edges.count(where: { $0.isEnabled }) < hint {
                return false
            }
        }
        
        let marked = field.edges.filter { $0.state == .marked }
        
        var runs: [[Edge]] = []
        for edge in marked {
            if runs.contains(where: { $0.contains(edge) }) {
                continue
            }
            
            let run =
                GraphUtils
                    .singlePathEdges(in: field,
                                     fromEdge: edge,
                                     includeTest: { $0.state == .marked })
            
            runs.append(run)
        }
        
        if runs.count > 1 && runs.contains(where: { $0.isLoop }) {
            return false
        }
        
        return true
    }
    
    public init(field: LoopyField) {
        self.field = field
        
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
        // Keep applying passes until the field no longer changes between steps
        while !isSolved && isConsistent {
            let newField = applySteps(to: field)
            
            defer { field = newField }
            
            // No changes detected- stop solve attempts since no further changes
            // will be made, anyway.
            if field == newField {
                break
            }
        }
        
        // Perform a speculative step to attempt solving the grid by making
        // guessing plays.
        if !isSolved {
            speculate()
        }
        
        return isSolved ? .solved : .unsolved
    }
    
    private func speculate() {
        var attempts = maxNumberOfGuesses
        
        let plays = collectSpeculativeSteps()
        
        for (i, play) in plays.enumerated() {
            if attempts == 0 {
                return
            }
            
            if doSpeculativePlay(play, attempt: i + 1) {
                attempts -= 1
            }
            
            if isSolved {
                return
            }
        }
    }
    
    private func doSpeculativePlay(_ edge: Edge, attempt: Int) -> Bool {
        // Create a sub-solver to perform the play
        let subSolver = Solver(field: field)
        subSolver.maxNumberOfGuesses = maxNumberOfGuesses - attempt
        
        subSolver.field.withEdge(edge) { $0.state = .marked }
        if !subSolver.isConsistent {
            return false
        }
        
        // Attempt a full solve, now that the field is considered consistent
        if subSolver.solve() == .solved {
            field = subSolver.field
        }
        
        return true
    }
    
    private func applySteps(to field: LoopyField) -> LoopyField {
        var field = field
        for step in steps {
            field = step.apply(to: field)
        }
        return field
    }
    
    private func applyStep(_ step: SolverStep) {
        field = step.apply(to: field)
    }
    
    private func collectSpeculativeSteps() -> [Edge] {
        var plays: [Edge] = []
        
        // Look for faces that are one edge away to completion to guess their
        // edge
        for face in field.faces {
            let edges = field.edges(forFace: face)

            if edges.count(where: { $0.state == .marked }) + 1 == face.hint {
                plays.append(contentsOf: edges.filter({ $0.state == .normal }))
            }
        }
        
        // Search for vertices with open loop ends to fill
        for i in 0..<field.vertices.count {
            let edges = field
                .edgesSharing(vertexIndex: i)
                .edges(in: field)
                .filter { $0.isEnabled }
            
            if edges.count(where: { $0.state == .marked }) == 1 {
                let edgesToPlay = edges
                    .filter { $0.state == .normal }
                
                plays.append(contentsOf: edgesToPlay)
            }
        }
        
        return plays
    }
    
    public enum Result {
        case solved
        case unsolved
    }
}

public protocol SolverStep {
    func apply(to field: LoopyField) -> LoopyField
}
