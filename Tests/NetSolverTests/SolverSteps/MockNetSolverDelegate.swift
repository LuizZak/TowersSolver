@testable import NetSolver

class MockNetSolverDelegate: NetSolverDelegate {
    private var _didPrepare = false
    
    var didCallEnqueue: [NetSolverStep] = []
    var didCallMarkIsInvalid = false
    
    var mock_possibleOrientationsForTile: ((_ column: Int, _ row: Int) -> Set<Tile.Orientation>)?
    var mock_unavailableIncomingPortsForTile: ((_ column: Int, _ row: Int) -> Set<EdgePort>)?
    var mock_requiredPortsForTile: ((_ column: Int, _ row: Int) -> Set<EdgePort>)?
    var mock_guaranteedOutgoingUnavailablePortsForTile: ((_ column: Int, _ row: Int) -> Set<EdgePort>)?
    
    var metadata: GridMetadata {
        baseSolverDelegate.metadata
    }
    var baseSolverDelegate: SolverInvocation!
    
    init() {
        
    }
    
    func mock_prepare(forGrid grid: Grid) {
        _didPrepare = true
        
        baseSolverDelegate = SolverInvocation(grid: grid)
    }
    
    func markIsInvalid() {
        didCallMarkIsInvalid = true
        baseSolverDelegate.markIsInvalid()
    }
    
    func enqueue(_ step: NetSolverStep) {
        precondition(_didPrepare, "Invoke mock_prepare(forGrid:) before using \(MockNetSolverDelegate.self)")
        
        didCallEnqueue.append(step)
        
        baseSolverDelegate.enqueue(step)
    }
    
    func possibleOrientationsForTile(atColumn column: Int, row: Int) -> Set<Tile.Orientation> {
        if let mocked = mock_possibleOrientationsForTile {
            return mocked(column, row)
        }
        
        return baseSolverDelegate.possibleOrientationsForTile(atColumn: column, row: row)
    }
    
    func requiredPortsForTile(atColumn column: Int, row: Int) -> Set<EdgePort> {
        if let mocked = mock_requiredPortsForTile {
            return mocked(column, row)
        }
        
        return baseSolverDelegate.requiredPortsForTile(atColumn: column, row: row)
    }
    
    func unavailableIncomingPortsForTile(atColumn column: Int, row: Int) -> Set<EdgePort> {
        if let mocked = mock_unavailableIncomingPortsForTile {
            return mocked(column, row)
        }
        
        return baseSolverDelegate.unavailableIncomingPortsForTile(atColumn: column, row: row)
    }
    
    func guaranteedOutgoingAvailablePortsForTile(atColumn column: Int, row: Int) -> Set<EdgePort> {
        return baseSolverDelegate.guaranteedOutgoingAvailablePortsForTile(atColumn: column, row: row)
    }
    
    func guaranteedOutgoingUnavailablePortsForTile(atColumn column: Int, row: Int) -> Set<EdgePort> {
        if let mocked = mock_guaranteedOutgoingUnavailablePortsForTile {
            return mocked(column, row)
        }
        
        return baseSolverDelegate.guaranteedOutgoingUnavailablePortsForTile(atColumn: column, row: row)
    }
}
