@testable import NetSolver

class MockNetSolverDelegate: NetSolverDelegate {
    private var _didPrepare = false
    
    var didCallEnqueue: [NetSolverStep] = []
    var didCallMarkIsInvalid = false
    
    var mock_unavailablePortsForTile: (_ column: Int, _ row: Int) -> Set<EdgePort> = { (_, _) in [] }
    
    var metadata: GridMetadata
    
    init() {
        metadata = GridMetadata(rows: 1, columns: 1)
    }
    
    func mock_prepare(forGrid grid: Grid) {
        _didPrepare = true
        
        metadata = GridMetadata(forGrid: grid)
    }
    
    func markIsInvalid() {
        didCallMarkIsInvalid = true
    }
    
    func enqueue(_ step: NetSolverStep) {
        precondition(_didPrepare, "Invoke mock_prepare(forGrid:) before using \(MockNetSolverDelegate.self)")
        
        didCallEnqueue.append(step)
    }
    
    func unavailablePortsForTile(atColumn column: Int, row: Int) -> Set<EdgePort> {
        return mock_unavailablePortsForTile(column, row)
    }
}
