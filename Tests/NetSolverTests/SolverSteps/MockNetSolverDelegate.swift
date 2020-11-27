@testable import NetSolver

class MockNetSolverDelegate: NetSolverDelegate {
    private var _didPrepare = false
    
    var didCallEnqueue: [NetSolverStep] = []
    var didCallMarkIsInvalid = false
    
    var mock_unavailablePortsForTile: ((_ column: Int, _ row: Int) -> Set<EdgePort>)?
    
    var metadata: GridMetadata
    var baseSolverDelegate: SolverInvocation!
    
    init() {
        metadata = GridMetadata(rows: 1, columns: 1)
    }
    
    func mock_prepare(forGrid grid: Grid) {
        _didPrepare = true
        
        metadata = GridMetadata(forGrid: grid)
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
    
    func unavailablePortsForTile(atColumn column: Int, row: Int) -> Set<EdgePort> {
        if let mocked =  mock_unavailablePortsForTile {
            return mocked(column, row)
        }
        
        return baseSolverDelegate.unavailablePortsForTile(atColumn: column, row: row)
    }
}
