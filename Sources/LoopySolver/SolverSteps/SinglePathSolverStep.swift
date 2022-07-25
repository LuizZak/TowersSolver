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
    public static let metadataKey: String = "\(SinglePathSolverStep.self)"

    public func apply(to grid: LoopyGrid, _ delegate: SolverStepDelegate) -> LoopyGrid {
        let metadata = delegate.metadataForSolverStepClass(type(of: self))

        let solver = InternalSolver(grid: grid, metadata: metadata)
        solver.apply()

        return solver.grid
    }
}

private class InternalSolver {
    var metadata: SolverStepMetadata

    var grid: LoopyGrid

    init(grid: LoopyGrid, metadata: SolverStepMetadata) {
        self.grid = grid
        self.metadata = metadata
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

        if metadata.matchesStoredFaceState(face, from: grid) {
            return
        }
        defer {
            metadata.storeFaceState(face, from: grid)
        }

        guard let hint = grid.hintForFace(face) else {
            return
        }

        // Collect edges
        var edgeRuns: [Set<Edge.Id>] =
            grid
            .ignoringDisabledEdges()
            .linearPathGraphEdges(around: face)

        guard !edgeRuns.isEmpty else {
            return
        }

        edgeRuns.sort(by: { $0.count > $1.count })

        if edgeRuns[0].count == hint && grid.edges(forFace: face).count - edgeRuns[0].count < hint {
            grid.setEdges(state: .marked, forEdges: edgeRuns[0])
        }
    }
}
