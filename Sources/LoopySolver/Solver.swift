/// Solver for a Loopy match
public final class Solver {
    /// Shared metadata for step types
    private var metadataList: [String: SolverStepMetadata] = [:]

    /// Set to `true` when a solver step reports an invalid state before it can
    /// be detected by the solver via `isConsistent`.
    private var _diagnosedInconsistentState: Bool = false

    // Solver steps applied during normal resolving.
    private var steps: [SolverStep] = []

    // Solver steps applied after exhausting normal solving attempts.
    private var postSolveAttemptSteps: [SolverStep] = []

    /// Whether ephemeral basic solver steps have been removed already
    private var hasRemovedEphemeral = false

    /// Whether ephemeral post-solve solver steps have been removed already
    private var hasRemovedPostSolveEphemeral = false

    /// Whether this solver was spawned by a solver when attempting to inspect
    /// the results of a play isolatedly.
    var isChildSolver = false

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
    private var postSolveGuessesAvailable: Int

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
    /// - seealso: `LoopyGrid.isConsistent`
    public var isConsistent: Bool {
        if _diagnosedInconsistentState {
            return true
        }

        return grid.isConsistent
    }

    public init(grid: LoopyGrid) {
        self.grid = grid
        guessesAvailable = maxNumberOfGuesses
        postSolveGuessesAvailable = 10

        addSteps()
    }

    func mergeSolver(_ solver: Solver) {
        grid = solver.grid
        metadataList = solver.metadataList
    }

    private func makeSubsolver(grid: LoopyGrid) -> Solver {
        let solver = Solver(grid: grid)
        if self.grid == grid {
            solver.metadataList = metadataList
        }
        solver.maxNumberOfGuesses = guessesAvailable
        solver.isChildSolver = true

        return solver
    }

    private func addSteps() {
        steps.append(ZeroSolverStep())
        steps.append(DeadEndRemovalSolverStep())
        steps.append(TwoEdgesPerVertexSolverStep())
        steps.append(ExactEdgeCountSolverStep())
        steps.append(SolePathEdgeExtenderSolverStep())
        steps.append(CornerSolverStep())
        steps.append(CornerEntrySolverStep())
        steps.append(SinglePathSolverStep())
        steps.append(NeighboringSemiCompleteFacesSolverStep())
        steps.append(NeighboringShortFacesSolverStep())
        steps.append(InvalidLoopClosingDetectionSolverStep())
        steps.append(BifurcationSolverStep())
        steps.append(PermutationSolverStep())
        steps.append(VertexPropagationSolverStep())

        postSolveAttemptSteps.append(InsideOutsideSolverStep())
        postSolveAttemptSteps.append(CommonEdgesBetweenGuessesSolverStep())
    }

    public func solve() -> Result {
        basicSolveCycle()

        if isSolved {
            // Present a clean solution by disabling remaining normal edges that
            // are not part of the solution
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

    private func basicSolveCycle() {
        // Keep applying passes until the grid no longer changes between steps
        while isConsistent && !isSolved {
            var oldGrid = grid

            applySolverLoopToExhaustion {
                grid = applySteps(to: grid)
            }

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

        if !isChildSolver && isConsistent && !isSolved {
            let before = grid
            grid = applyPostSolveAttemptSteps(to: grid)

            if grid != before {
                basicSolveCycle()
            }
        }
    }

    /// Applies a solver changes block until either a solution is found, an
    /// inconsistency is reached, or no changes have been made during the cycle.
    private func applySolverLoopToExhaustion(changes: () -> Void) {
        // Keep applying passes until the grid no longer changes between steps
        while !isSolved && isConsistent {
            let oldGrid = grid

            changes()

            if grid == oldGrid {
                break
            }
        }
    }

    private func applySteps(to grid: LoopyGrid) -> LoopyGrid {
        defer {
            if !hasRemovedEphemeral {
                hasRemovedEphemeral = true

                steps = steps.filter { !$0.isEphemeral }
            }
        }

        return applySteps(steps, to: grid, quitOnChange: true)
    }

    private func applyPostSolveAttemptSteps(to grid: LoopyGrid) -> LoopyGrid {
        defer {
            if !hasRemovedPostSolveEphemeral {
                hasRemovedPostSolveEphemeral = true

                postSolveAttemptSteps = postSolveAttemptSteps.filter { !$0.isEphemeral }
            }
        }

        return applySteps(postSolveAttemptSteps, to: grid, quitOnChange: true)
    }

    private func applySteps(_ steps: [SolverStep], to grid: LoopyGrid, quitOnChange: Bool) -> LoopyGrid {
        var grid = grid
        for step in steps where !_diagnosedInconsistentState {
            let newGrid = step.apply(to: grid, self)

            if quitOnChange && newGrid != grid {
                return newGrid
            }

            grid = newGrid
        }
        return grid
    }

    /// Perform speculative plays where some edges are marked and then consistency
    /// is checked to verify if the edge is not actually part of the solved
    /// puzzle.
    private func speculate() {
        if guessesAvailable <= 0 {
            return
        }

        let plays = collectSpeculativeSteps().prefix(guessesAvailable)

        for play in plays where guessesAvailable > 0 {
            guessesAvailable -= 1

            if doSpeculativePlay(play, guesses: guessesAvailable) {
                return
            }
        }
    }

    private func doSpeculativePlay(_ edge: Edge.Id, guesses: Int) -> Bool {
        return withSubsolver(grid: grid) { subSolver in
            subSolver.maxNumberOfGuesses = guesses
            subSolver.guessesAvailable = guesses
            subSolver.grid.withEdge(edge) { $0.state = .marked }

            if subSolver.solve() == .solved {
                mergeSolver(subSolver)
                return true
            }

            if !subSolver.isConsistent {
                grid.withEdge(edge) { $0.state = .disabled }
                return true
            }

            return false
        }
    }

    private func collectSpeculativeSteps() -> [Edge.Id] {
        var plays: [Edge.Id] = []

        // Search for vertices with open loop ends to fill
        struct VertEntry {
            var edges: [Edge.Id]
            var priority: Int
        }

        var vertEntries: [VertEntry] = []

        for e in grid.edgeIds where grid.edgeState(forEdge: e) == .normal {
            let start = grid.edgeVertices(forEdge: e).start
            let end = grid.edgeVertices(forEdge: e).end

            guard grid.markedEdges(forVertex: start) == 1 else {
                continue
            }
            guard grid.markedEdges(forVertex: end) == 1 else {
                continue
            }

            let hintedFaces =
                grid.faceIds.count {
                    grid.faceContainsEdge(face: $0, edge: e) && grid.hintForFace($0) != nil
                }
            let semicompleteFaces =
                grid.faceIds.count {
                    grid.faceContainsEdge(face: $0, edge: e) && grid.isFaceSemicomplete($0)
                }

            let priority = hintedFaces + semicompleteFaces + 1

            vertEntries.append(VertEntry(edges: [e], priority: priority))
        }

        for i in 0..<grid.vertices.count {
            guard grid.markedEdges(forVertex: i) == 1 else {
                continue
            }

            let edgesToPlay =
                grid
                .edgesSharing(vertexIndex: i)
                .filter { grid.edgeState(forEdge: $0) == .normal }

            let hintedFaces =
                grid.faceIds.count {
                    grid.vertices(forFace: $0).contains(i) && grid.hintForFace($0) != nil
                }

            if hintedFaces == 0 {
                continue
            }

            let semicompleteFaces =
                grid.faceIds.count {
                    grid.vertices(forFace: $0).contains(i) && grid.isFaceSemicomplete($0)
                }

            let priority = hintedFaces + semicompleteFaces

            vertEntries.append(VertEntry(edges: edgesToPlay, priority: priority))
        }

        // Sort entries by number of faces the play would affect to increase
        // chances we find a definite outcome of valid/invalid from the play
        //
        // Attempt to make the sort as stable as possible to make execution more
        // predictable, aiding in debugging if something goes awry
        vertEntries.stableSort(by: { (v1, v2) in
            return v1.priority > v2.priority
        })

        for entry in vertEntries {
            plays.append(contentsOf: entry.edges)
        }

        // Look for semi-complete faces that are missing one edge to solve
        for face in grid.faceIds.sorted(by: { (l, _) in grid.isFaceSemicomplete(l) }) {
            let edges = grid.edges(forFace: face)

            if edges.count(where: { grid.edgeState(forEdge: $0) == .marked }) + 1
                == grid.hintForFace(face)
            {
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

extension Solver: SolverStepDelegate {
    public func metadataForSolverStepClass<T: SolverStep>(_ solverStepType: T.Type)
        -> SolverStepMetadata
    {
        let key = T.metadataKey

        if let meta = metadataList[key] {
            return meta
        }

        let metadata = SolverStepMetadata()

        metadataList[key] = metadata

        return metadata
    }

    public func canSolverStepPerformGuessAttempt(_ step: SolverStep) -> Bool {
        if postSolveAttemptSteps.contains(where: { $0 === step }) {
            return postSolveGuessesAvailable > 0
        }

        return guessesAvailable > 0
    }

    public func solverStepDidPerformGuess(_ step: SolverStep) {
        if postSolveAttemptSteps.contains(where: { $0 === step }) {
            postSolveGuessesAvailable -= 1
            return
        }

        guessesAvailable -= 1
    }

    public func solverStepDidReportInconsistentState(_ step: SolverStep) {
        _diagnosedInconsistentState = true
    }

    public func withSubsolver<T>(grid: LoopyGrid, do closure: (Solver) throws -> T) rethrows -> T {
        let solver = makeSubsolver(grid: grid)
        defer {
            guessesAvailable -= solver.maxNumberOfGuesses - solver.guessesAvailable
        }

        return try closure(solver)
    }
}
