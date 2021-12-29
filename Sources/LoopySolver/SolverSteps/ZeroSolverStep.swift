/// Trivial solver step that unmarks the edges of every zero-hinted cell.
public class ZeroSolverStep: SolverStep {
    public static let metadataKey: String = "\(ZeroSolverStep.self)"
    
    public var isEphemeral: Bool {
        return true
    }
    
    public func apply(to grid: LoopyGrid, _ delegate: SolverStepDelegate) -> LoopyGrid {
        let metadata = delegate.metadataForSolverStepClass(ZeroSolverStep.self)
        if metadata.isFlagMarked() {
            return grid
        }
        metadata.markFlag()
        
        var grid = grid
        
        for faceId in grid.faceIds where grid.hintForFace(faceId) == 0 {
            grid.setEdges(state: .disabled, forFace: faceId)
        }
        
        return grid
    }
}
