/// Solver for a Loopy match
public class Solver {
    public var field: LoopyField
    private var steps: [SolverStep] = []
    
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
                    .filter { $0.state == .marked }
            
            if marked.count != hint {
                return false
            }
        }
        
        let markedEdges = field.edges.filter { $0.state == .marked }
        if !markedEdges.isLoop {
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
    }
    
    public func solve() -> Result {
        // Keep applying passes until the field no longer changes between steps
        while !isSolved {
            let newField = applySteps(to: field)
            
            defer { field = newField }
            
            // No changes detected- stop solve attempts since no further changes
            // will be made, anyway.
            if field == newField {
                break
            }
        }
        
        return isSolved ? .solved : .unsolved
    }
    
    private func applySteps(to field: LoopyField) -> LoopyField {
        var field = field
        for step in steps {
            field = step.apply(to: field)
        }
        return field
    }
    
    public enum Result {
        case solved
        case unsolved
    }
}

public protocol SolverStep {
    func apply(to field: LoopyField) -> LoopyField
}
