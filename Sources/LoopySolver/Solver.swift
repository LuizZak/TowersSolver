/// Solver for a Loopy match
public class Solver {
    private var steps: [SolverStep] = []
    
    public var field: LoopyField
    
    /// When the solver gets stuck and requires guessing a possible next play,
    /// this counter controls how many guesses it can attempt before stopping
    /// further guessing attempts.
    public var maxNumberOfGuesses: Int = 10 {
        didSet {
            guessesAvailable = maxNumberOfGuesses
        }
    }
    
    private var guessesAvailable: Int
    
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
            
            if edges.count(where: { field.edgeState(forEdge: $0) == .marked }) > 2 {
                return false
            }
        }
        
        for face in field.faces {
            let edges = field.edges(forFace: face)
            guard let hint = face.hint else {
                continue
            }
            
            if edges.count(where: { field.edgeState(forEdge: $0) == .marked }) > hint {
                return false
            }
            if edges.count(where: { field.edgeState(forEdge: $0).isEnabled }) < hint {
                return false
            }
        }
        
        let marked = field.edgeIds.filter { field.edgeState(forEdge: $0) == .marked }
        
        var runs: [[Edge.Id]] = []
        for edge in marked {
            if runs.contains(where: { $0.contains(edge) }) {
                continue
            }
            
            let run =
                GraphUtils
                    .singlePathEdges(in: field,
                                     fromEdge: edge,
                                     includeTest: { field.edgeState(forEdge: $0) == .marked })
            
            runs.append(run)
        }
        
        if runs.count > 1 && runs.contains(where: field.isLoop) {
            return false
        }
        
        return true
    }
    
    public init(field: LoopyField) {
        self.field = field
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
        // Keep applying passes until the field no longer changes between steps
        while !isSolved && isConsistent {
            var oldField = field
            field = applySteps(to: field)
            
            // If no changes where made, try a speculative play here
            if field == oldField {
                
                oldField = field
                
                // Perform a speculative step to attempt solving the grid by making
                // guessing plays.
                speculate()
                
                // No changes detected- stop solve attempts since no further changes
                // will be made, anyway.
                if field == oldField {
                    break
                }
            }
        }
        
        if isSolved {
            // Present a clean solution by disabling remaining normal edges that
            // not part of the solution
            for edge in field.edgeIds {
                field.withEdge(edge) { edge in
                    if edge.state == .normal {
                        edge.state = .disabled
                    }
                }
            }
            
            return .solved
        }
        
        return .unsolved
    }
    
    /// Perform speculative plays where some edges are marked and then consistency
    /// is checked to verify if the edge is not actually part of the solved
    /// puzzle.
    private func speculate() {
        if guessesAvailable == 0 {
            return
        }
        
        let plays = collectSpeculativeSteps().prefix(guessesAvailable)
        
        for play in plays {
            guessesAvailable -= 1
            
            if doSpeculativePlay(play) {
                return
            }
        }
    }
    
    private func doSpeculativePlay(_ edge: Edge.Id) -> Bool {
        let subSolver = Solver(field: field)
        subSolver.maxNumberOfGuesses = 0
        
        subSolver.field.withEdge(edge) { $0.state = .marked }
        
        if subSolver.solve() == .solved {
            field = subSolver.field
            return true
        }
        
        if !subSolver.isConsistent {
            field.withEdge(edge) { $0.state = .disabled }
            return true
        }
        
        return false
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
    
    private func collectSpeculativeSteps() -> [Edge.Id] {
        var plays: [Edge.Id] = []
        
        // Search for vertices with open loop ends to fill
        struct VertEntry {
            var vertex: Int
            var edges: [Edge.Id]
            var priority: Int
        }
        
        var vertEntries: [VertEntry] = []
        
        for i in 0..<field.vertices.count {
            let edges = field
                .edgesSharing(vertexIndex: i)
                .filter { field.edgeState(forEdge: $0).isEnabled }
            
            if edges.count(where: { field.edgeState(forEdge: $0) == .marked }) == 1 {
                let edgesToPlay = edges
                    .filter { field.edgeState(forEdge: $0) == .normal }
                
                let hintedFaces =
                    field.faces.count { $0.indices.contains(i) && $0.hint != nil }
                let semicompleteFaces =
                    field.faces.count { $0.indices.contains(i) && $0.isSemiComplete }
                
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
        for face in field.faces.sorted(by: { (l, _) in l.isSemiComplete }) {
            let edges = field.edges(forFace: face)
            
            if edges.count(where: { field.edgeState(forEdge: $0) == .marked }) + 1 == face.hint {
                plays.append(contentsOf: edges.filter({ field.edgeState(forEdge: $0) == .normal }))
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
    /// - testIsInvalid: Performs a play where an edge is marked and the field is
    /// then tested for inconsistencies during normal play.
    /// - play: An edge is marked and further plays happen on the new field until
    /// either a solution is found or no more valid solutions can be derived from
    /// that point.
    public enum SpeculativePlay {
        case testIsInvalid(Edge)
        case play(Edge)
    }
}

public protocol SolverStep {
    func apply(to field: LoopyField) -> LoopyField
}
