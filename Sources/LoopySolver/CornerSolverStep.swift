/// Solves grid cells that are on a corner in two scenarios:
///
/// 1. When the number of required edges shared amongst other cells is smaller
/// than the required solution of the cell.
///
/// This indicates that the cell's outer edges are all part of the solution.
///
/// This only works for cells that have a single sequential number of edges that
/// are outside the graph and not connected to other faces.
///
/// 2. When the number of required edges exceeds edges not shared with another
/// face.
///
/// In this case, the outer edges cannot be part of the solution, since their
/// singular path would exceed the solution of the face.
public class CornerSolverStep: SolverStep {
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
        for id in grid.faceIds {
            applyToFace(id)
        }
    }
    
    func applyToFace(_ faceId: Face.Id) {
        let face = grid.faceWithId(faceId)
        
        // Requires hint!
        guard let hint = face.hint else {
            return
        }
        
        let nonShared = controller.nonSharedEdges(forFace: faceId)
        
        // Can only solve when the non-shared edges form a single sequential line
        // across the outer side of the face
        if !nonShared.edges(in: grid).isUniqueSegment {
            return
        }
        
        // If the number of edges not shared among other faces exceeds the hint,
        // then the unshared sequential edges are not part of the solution
        if nonShared.count > hint {
            controller.setEdges(state: .disabled, forEdges: nonShared)
            
            return
        }
        
        // If the number of edges that are shared ammount to less than the required
        // edges for the solution, this means that all outer edges are part of the
        // solution, since at least one of the outer edges will have to be marked
        // to be part of the solution, and if a single outer edge is marked, all
        // outer edges must be marked due to them forming a single continuous line.
        if face.edgesCount - nonShared.count < hint {
            controller.setEdges(state: .marked, forEdges: nonShared)
        }
    }
}
