class SolverInvocation {
    var steps: [NetSolverStep] = []
    var grid: Grid
    var metadata: GridMetadata
    var isValid = true
    
    init(grid: Grid) {
        self.grid = grid
        self.metadata = GridMetadata(forGrid: grid)
    }
    
    /// Apply all currently enqueued solver steps
    func apply() -> SolverInvocationResult {
        while !steps.isEmpty && isValid {
            let step = steps.removeFirst()
            
            let actions = step.apply(on: grid, delegate: self)
            grid = performGridActions(actions, grid: grid)
        }
        
        let state: ResultState
        
        if isValid {
            state = NetGridController(grid: grid).isSolved ? .solved : .unsolved
        } else {
            state = .invalid
        }
        
        return SolverInvocationResult(state: state, grid: grid)
    }
    
    func performGridActions(_ actions: [GridAction], grid: Grid) -> Grid {
        var grid = grid
        
        for action in actions {
            grid = performGridAction(action, grid: grid)
        }
        
        return grid
    }
    
    func performGridAction(_ action: GridAction, grid: Grid) -> Grid {
        var grid = grid
        
        switch action {
        case let .lockOrientation(column, row, orientation):
            grid[row: row, column: column].isLocked = true
            grid[row: row, column: column].orientation = orientation
            
        case let .markUnavailableIngoing(column, row, ports):
            // Figure out which orientations require the ports mentioned and
            // remove them from the allowed set
            let available = grid[row: row, column: column].orientations(excludingPorts: ports)
            
            metadata.setPossibleOrientations(column: column, row: row, orientations: available)
            
        case let .markImpossibleOrientations(column, row, orientations):
            let available = metadata.possibleOrientations(column: column, row: row)
            
            metadata.setPossibleOrientations(column: column, row: row, orientations: available.subtracting(orientations))
        }
        
        return grid
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
}

extension SolverInvocation: NetSolverDelegate {
    func markIsInvalid() {
        isValid = false
    }
    
    func enqueue(_ step: NetSolverStep) {
        steps.append(step)
    }
    
    func requiredIncomingPortsForTile(atColumn column: Int, row: Int) -> Set<EdgePort> {
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
