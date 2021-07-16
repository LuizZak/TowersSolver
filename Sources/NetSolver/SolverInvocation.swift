class SolverInvocation {
    private typealias GuessMove = (column: Int, row: Int, orientation: Tile.Orientation)
    
    var steps: [NetSolverStep] = []
    var grid: Grid
    var metadata: GridMetadata
    var isValid = true
    var maxGuesses: Int = 5
    
    init(grid: Grid) {
        self.grid = grid
        self.metadata = GridMetadata(forGrid: grid)
    }
    
    /// Resets the possible orientations set for each tile of the grid to their
    /// corresponding normalized ports set of orientations via `.normalizedByPortSet`
    func resetPossibleOrientationsSet() {
        for row in 0..<grid.rows {
            for column in 0..<grid.columns {
                let tile = grid[row: row, column: column]
                
                let orientationSet =
                    Set(Tile.Orientation.allCases)
                    .normalizedByPortSet(onTileKind: tile.kind)
                
                metadata.setPossibleOrientations(column: column, row: row, orientationSet)
            }
        }
    }
    
    /// Apply all currently enqueued solver steps
    func apply() -> SolverInvocationResult {
        performSolverSteps()
        
        let state: ResultState
        let controller = NetGridController(grid: grid)
        
        if isValid && !controller.isInvalid {
            state = controller.isSolved ? .solved : .unsolved
        } else {
            state = .invalid
        }
        
        return SolverInvocationResult(state: state, grid: grid)
    }
    
    func performSolverSteps() {
        while !steps.isEmpty && isValid {
            let step = steps.removeFirst()
            
            let actions = step.apply(on: grid, delegate: self)
            performGridActions(actions)
        }
    }
    
    func performGridActions(_ actions: [GridAction]) {
        for action in actions {
            performGridAction(action)
        }
    }
    
    func lockOrientation(column: Int, row: Int, orientation: Tile.Orientation) {
        grid[row: row, column: column].isLocked = true
        grid[row: row, column: column].orientation = orientation
        
        propagateTileCheck(column: column, row: row)
    }
    
    func performGridAction(_ action: GridAction) {
        switch action {
        case .markAsInvalid:
            markIsInvalid()
        
        case let .lockOrientation(column, row, orientation):
            lockOrientation(column: column, row: row, orientation: orientation)
            
        case let .markUnavailableIngoing(column, row, ports):
            // Figure out which orientations require the ports mentioned and
            // remove them from the allowed set
            let possible = metadata.possibleOrientations(column: column, row: row)
            let available = grid[row: row, column: column].orientations(excludingPorts: ports)
            guard !available.isDisjoint(with: possible) else {
                break
            }
            
            performGridAction(
                .markImpossibleOrientations(column: column,
                                            row: row,
                                            Set(Tile.Orientation.allCases).subtracting(available))
            )
            
        case let .markImpossibleOrientations(column, row, orientations):
            let possible = metadata.possibleOrientations(column: column, row: row)
            guard !possible.isDisjoint(with: orientations) else {
                break
            }
            
            let tile = grid[row: row, column: column]
            let remaining =
                possible
                .subtracting(orientations)
                .normalizedByPortSet(onTileKind: tile.kind)
            
            metadata.setPossibleOrientations(column: column, row: row, remaining)
            
            // Possible orientation set contains only one item - lock tile on the
            // specified orientation
            if remaining.count == 1, let first = remaining.first {
                lockOrientation(column: column, row: row, orientation: first)
            } else if remaining.isEmpty {
                // Possible orientation set is empty - mark grid as invalid
                markIsInvalid()
            }
            
            propagateTileCheck(column: column, row: row)
        }
    }
    
    func performGuessMoves() -> GuessMovesResult {
        guard maxGuesses > 0 else {
            return .guessesExhausted
        }
        
        var guesses = generateGuessMoves()
        
        while maxGuesses > 0, let next = guesses.popLast() {
            let subSolver = makeSubSolver(grid: self.grid)
            subSolver.lockOrientation(column: next.column, row: next.row, orientation: next.orientation)
            
            maxGuesses -= 1
            
            let result = subSolver.apply()
            switch result.state {
            case .solved:
                self.grid = result.grid
                return .gridSolved(result.grid)
            
            case .invalid:
                performGridAction(
                    .markImpossibleOrientations(column: next.column,
                                                row: next.row,
                                                [next.orientation])
                )
                return .gridChanged
                
            case .unsolved:
                continue
            }
        }
        
        return .guessesExhausted
    }
    
    func makeSubSolver(grid: Grid) -> SolverInvocation {
        let solver = SolverInvocation(grid: grid)
        solver.maxGuesses = maxGuesses - 1
        solver.isValid = isValid
        solver.metadata = metadata
        
        return solver
    }
    
    private func propagateTileCheck(column: Int, row: Int) {
        enqueueGeneralTileCheck(column: column, row: row)
        
        EdgePort.allCases.forEach { port in
            let neighbor = grid.columnRowByMoving(column: column, row: row, direction: port)
            
            enqueueGeneralTileCheck(column: neighbor.column, row: neighbor.row)
        }
    }
    
    private func hasEnqueuedGeneralTileCheck(column: Int, row: Int) -> Bool {
        for case let step as GeneralTileCheckSolverStep in steps {
            if step.column == column && step.row == row {
                return true
            }
        }
        
        return false
    }
    
    private func enqueueGeneralTileCheck(column: Int, row: Int) {
        guard !grid[row: row, column: column].isLocked else {
            return
        }
        guard !hasEnqueuedGeneralTileCheck(column: column, row: row) else {
            return
        }
        
        enqueue(GeneralTileCheckSolverStep(column: column, row: row))
    }
    
    private func generateGuessMoves() -> [GuessMove] {
        var guesses: [GuessMove] = []
        
        for row in 0..<grid.rows {
            for column in 0..<grid.columns {
                let tile = grid[row: row, column: column]
                guard !tile.isLocked else { continue }
                
                // Find orientations that match required and available ports
                // for this tile
                let required = requiredPortsForTile(atColumn: column, row: row)
                
                let reduced =
                    tile
                    .orientations(excludingPorts: unavailableIncomingPortsForTile(atColumn: column, row: row))
                    .filter { required.isSubset(of: Tile.portsForTile(kind: tile.kind, orientation: $0)) }
                
                for orientation in metadata.possibleOrientations(column: column, row: row).intersection(reduced) {
                    guesses.append((column: column, row: row, orientation: orientation))
                }
            }
        }
        
        return guesses
    }
    
    struct SolverInvocationResult {
        var state: ResultState
        var grid: Grid
    }
    
    enum ResultState {
        case solved
        case unsolved
        case invalid
    }
    
    enum GuessMovesResult {
        case gridSolved(Grid)
        case gridChanged
        case guessesExhausted
    }
}

extension SolverInvocation: NetSolverDelegate {
    func markIsInvalid() {
        isValid = false
    }
    
    func enqueue(_ step: NetSolverStep) {
        steps.append(step)
    }
    
    func lockedTileNetworks() -> [Network] {
        return Network.fromLockedTiles(onGrid: grid)
    }
    
    func possibleOrientationsForTile(atColumn column: Int, row: Int) -> Set<Tile.Orientation> {
        return metadata.possibleOrientations(column: column, row: row)
    }
    
    func requiredPortsForTile(atColumn column: Int, row: Int) -> Set<EdgePort> {
        var ports: Set<EdgePort> = []
        
        // Check surrounding tiles for guaranteed available ports and tiles that
        // are locked while facing torwards the requested tile
        let surrounding = EdgePort.allCases.filter { edgePort in
            let neighborCoordinates = grid.columnRowByMoving(column: column, row: row, direction: edgePort)
            
            // Edge port that points from the neighbor tile back to the queried
            // tile
            let backEdgePort = edgePort.opposite
            
            // Check locked tiles that face torwards from the tile
            let neighbor = grid[row: neighborCoordinates.row, column: neighborCoordinates.column]
            if neighbor.isLocked && neighbor.ports.contains(backEdgePort) {
                return true
            }
            // Check guaranteed available back ports from available orientations
            let neighborOrientations
                = metadata.possibleOrientations(column: neighborCoordinates.column,
                                                row: neighborCoordinates.row)
            let neighborCommonAvailable
                = neighbor.commonAvailablePorts(orientations: neighborOrientations)
            
            if neighborCommonAvailable.contains(backEdgePort) {
                return true
            }
            
            return false
        }

        ports.formUnion(surrounding)
        
        // Subtract barriers
        ports.subtract(grid.barriersForTile(atColumn: column, row: row))
        
        return ports
    }
    
    func unavailableIncomingPortsForTile(atColumn column: Int, row: Int) -> Set<EdgePort> {
        // Start with barriers
        var unavailable = grid.barriersForTile(atColumn: column, row: row)
        
        // Check surrounding tiles for guaranteed unavailabilities and tiles that
        // are locked while facing away the requested tile
        let surrounding = EdgePort.allCases.filter { edgePort in
            let neighborCoordinates = grid.columnRowByMoving(column: column, row: row, direction: edgePort)
            
            // Edge port that points from the neighbor tile back to the queried
            // tile
            let backEdgePort = edgePort.opposite
            
            // Check locked tiles that face away from the tile
            let neighbor = grid[row: neighborCoordinates.row, column: neighborCoordinates.column]
            if neighbor.isLocked && !neighbor.ports.contains(backEdgePort) {
                return true
            }
            // Check guaranteed unavailable back ports from available orientations
            let neighborOrientations = metadata.possibleOrientations(column: neighborCoordinates.column, row: neighborCoordinates.row)
            let unavailable = neighbor.commonUnavailablePorts(orientations: neighborOrientations)
            if unavailable.contains(backEdgePort) {
                return true
            }
            
            return false
        }
        
        unavailable.formUnion(surrounding)
        
        return unavailable
    }
    
    func guaranteedOutgoingAvailablePortsForTile(atColumn column: Int, row: Int) -> Set<EdgePort> {
        let tile = grid[row: row, column: column]
        if tile.isLocked {
            return tile.ports
        }
        
        let orientations = metadata.possibleOrientations(column: column, row: row)
        return tile.commonAvailablePorts(orientations: orientations)
    }
    
    func guaranteedOutgoingUnavailablePortsForTile(atColumn column: Int, row: Int) -> Set<EdgePort> {
        let tile = grid[row: row, column: column]
        if tile.isLocked {
            return tile.ports.symmetricDifference(EdgePort.allCases)
        }
        
        let orientations = metadata.possibleOrientations(column: column, row: row)
        return tile.commonUnavailablePorts(orientations: orientations)
    }
}
