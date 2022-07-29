import Foundation
import Commons

/// A solver step that evaluates all valid combinations of edges of a face and
/// finds required/invalid edges by comparing the permutations.
public class PermutationSolverStep: SolverStep {
    public func apply(to grid: LoopyGrid, _ delegate: SolverStepDelegate) -> LoopyGrid {
        var grid = grid

        @ConcurrentValue
        var toDisable: Set<LoopyGrid.EdgeId> = []

        @ConcurrentValue
        var toMark: Set<LoopyGrid.EdgeId> = []

        let queue = OperationQueue()

        for faceId in grid.faceIds {
            queue.addOperation {
                let faceEdges = Set(grid.edges(forFace: faceId))
                let permutations = grid.permuteSolutionsAsEdges(forFace: faceId)
                
                // Find edges that are present across all solutions
                let permanent = permutations.reduce(faceEdges) {
                    $0.intersection($1)
                }
                // Find edges that don't participate at all in any solution
                let notPresent = permutations.reduce(faceEdges) {
                    $0.subtracting($1)
                }

                toDisable.formUnion(notPresent)
                toMark.formUnion(permanent)
            }
        }

        queue.waitUntilAllOperationsAreFinished()

        grid.setEdges(state: .disabled, forEdges: toDisable)
        grid.setEdges(state: .marked, forEdges: toMark)

        return grid
    }
}
