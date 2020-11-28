import XCTest
@testable import NetSolver

class SolverInvcationTests: XCTestCase {
    func testPossibleOrientationsForTile() {
        let grid = Grid(rows: 1, columns: 1)
        let sut = SolverInvocation(grid: grid)
        
        sut.metadata.setPossibleOrientations(column: 0, row: 0, [.east, .south])
        
        XCTAssertEqual(sut.possibleOrientationsForTile(atColumn: 0, row: 0), [.east, .south])
    }
    
    func testPossibleOrientationsForTile_startWithAllOrientations() {
        let grid = Grid(rows: 1, columns: 1)
        let sut = SolverInvocation(grid: grid)
        
        XCTAssertEqual(sut.possibleOrientationsForTile(atColumn: 0, row: 0), Set(Tile.Orientation.allCases))
    }
    
    func testUnavailableIncomingPortsForTile_nonWrappingGrid() {
        let grid = TestGridBuilder(columns: 3, rows: 3)
            .build()
        let sut = SolverInvocation(grid: grid)
        
        XCTAssertEqual(sut.unavailableIncomingPortsForTile(atColumn: 0, row: 0), [.top, .left])
        XCTAssertEqual(sut.unavailableIncomingPortsForTile(atColumn: 1, row: 0), [.top])
        XCTAssertEqual(sut.unavailableIncomingPortsForTile(atColumn: 2, row: 0), [.top, .right])
        XCTAssertEqual(sut.unavailableIncomingPortsForTile(atColumn: 0, row: 1), [.left])
        XCTAssertEqual(sut.unavailableIncomingPortsForTile(atColumn: 1, row: 1), [])
        XCTAssertEqual(sut.unavailableIncomingPortsForTile(atColumn: 2, row: 1), [.right])
        XCTAssertEqual(sut.unavailableIncomingPortsForTile(atColumn: 0, row: 2), [.bottom, .left])
        XCTAssertEqual(sut.unavailableIncomingPortsForTile(atColumn: 1, row: 2), [.bottom])
        XCTAssertEqual(sut.unavailableIncomingPortsForTile(atColumn: 2, row: 2), [.bottom, .right])
    }
    
    func testUnavailableIncomingPortsForTile_neighborLockedTile() {
        // Create a grid with a locked T tile that is pointing south (all ports
        // except top are available as connections), and check the four surrounding
        // tiles for connection unavailability.
        let grid = TestGridBuilder(columns: 6, rows: 6)
            .setTile(2, 2, kind: .T, orientation: .south)
            .lockTile(atColumn: 2, row: 2)
            .build()
        let sut = SolverInvocation(grid: grid)
        
        // Top
        XCTAssertEqual(sut.unavailableIncomingPortsForTile(atColumn: 2, row: 1), [.bottom])
        // Left
        XCTAssertEqual(sut.unavailableIncomingPortsForTile(atColumn: 1, row: 2), [])
        // Right
        XCTAssertEqual(sut.unavailableIncomingPortsForTile(atColumn: 3, row: 2), [])
        // Bottom
        XCTAssertEqual(sut.unavailableIncomingPortsForTile(atColumn: 2, row: 3), [])
    }
    
    func testUnavailableIncomingPortsForTile_neighborRestrictedTile() {
        let grid = TestGridBuilder(columns: 3, rows: 3)
            .setTile(1, 0, kind: .L, orientation: .north)
            .lockTile(atColumn: 2, row: 2)
            .build()
        let sut = SolverInvocation(grid: grid)
        sut.metadata.setPossibleOrientations(column: 1, row: 0, [.west, .north])
        
        XCTAssertEqual(sut.unavailableIncomingPortsForTile(atColumn: 1, row: 1), [.top])
    }
    
    func testRequiredPortsForTile() {
        let grid = TestGridBuilder(columns: 2, rows: 2)
            .build()
        let sut = SolverInvocation(grid: grid)
        
        XCTAssertEqual(sut.requiredPortsForTile(atColumn: 1, row: 0), [])
    }
    
    func testRequiredPortsForTile_neighborLockedTile() {
        let grid = TestGridBuilder(columns: 2, rows: 2)
            .setTile(0, 0, kind: .I, orientation: .east)
            .lockTile(atColumn: 0, row: 0)
            .build()
        let sut = SolverInvocation(grid: grid)
        
        XCTAssertEqual(sut.requiredPortsForTile(atColumn: 1, row: 0), [.left])
    }
    
    func testRequiredPortsForTile_neighborRestrictedTile() {
        let grid = TestGridBuilder(columns: 2, rows: 2)
            .setTile(0, 0, kind: .L, orientation: .east)
            .build()
        let sut = SolverInvocation(grid: grid)
        sut.metadata.setPossibleOrientations(column: 0, row: 0, [.north, .east])
        
        XCTAssertEqual(sut.requiredPortsForTile(atColumn: 1, row: 0), [.left])
    }
    
    func testGuaranteedOutgoingAvailablePorts_lockedTile() {
        // Create a grid with a locked T tile, and test the outgoing ports match
        // the ports for the tile itself.
        let grid = TestGridBuilder(columns: 1, rows: 1)
            .setTile(0, 0, kind: .T, orientation: .south)
            .lockTile(atColumn: 0, row: 0)
            .build()
        let sut = SolverInvocation(grid: grid)
        
        XCTAssertEqual(sut.guaranteedOutgoingAvailablePortsForTile(atColumn: 0, row: 0), [.left, .bottom, .right])
    }
    
    func testGuaranteedOutgoingUnavailablePorts_lockedTile() {
        // Create a grid with a locked T tile, and test the outgoing ports match
        // the missing ports for the tile itself.
        let grid = TestGridBuilder(columns: 1, rows: 1)
            .setTile(0, 0, kind: .T, orientation: .south)
            .lockTile(atColumn: 0, row: 0)
            .build()
        let sut = SolverInvocation(grid: grid)
        
        XCTAssertEqual(sut.guaranteedOutgoingUnavailablePortsForTile(atColumn: 0, row: 0), [.top])
    }
    
    func testGuaranteedOutgoingAvailablePorts_restrictedTile() {
        // Create a grid with a tile that has orientation restrictions, and check
        // the resulting guaranteed outgoing ports match the restrictions
        let grid = TestGridBuilder(columns: 1, rows: 1)
            .setTileKind(0, 0, kind: .L)
            .build()
        let sut = SolverInvocation(grid: grid)
        sut.metadata.setPossibleOrientations(column: 0, row: 0, [.west, .north])
        
        XCTAssertEqual(sut.guaranteedOutgoingAvailablePortsForTile(atColumn: 0, row: 0), [.top])
    }
    
    func testGuaranteedOutgoingUnavailablePorts_restrictedTile() {
        // Create a grid with a tile that has orientation restrictions, and check
        // the resulting guaranteed outgoing ports match the restrictions
        let grid = TestGridBuilder(columns: 1, rows: 1)
            .setTileKind(0, 0, kind: .L)
            .build()
        let sut = SolverInvocation(grid: grid)
        sut.metadata.setPossibleOrientations(column: 0, row: 0, [.west, .north])
        
        XCTAssertEqual(sut.guaranteedOutgoingUnavailablePortsForTile(atColumn: 0, row: 0), [.bottom])
    }
    
    func testPerformGridAction_markUnavailableIngoing() {
        // Create a single tile grid with a corner tile, and mark the top port
        // as unavailable in-going, and check that the allowed orientations include
        // only east and south
        let grid = TestGridBuilder(columns: 1, rows: 1)
            .setTile(0, 0, kind: .L, orientation: .north)
            .build()
        let sut = SolverInvocation(grid: grid)
        
        _ = sut.performGridAction(.markUnavailableIngoing(column: 0, row: 0, [.top]), grid: grid)
        
        XCTAssertEqual(sut.metadata.possibleOrientations(column: 0, row: 0), [.east, .south])
    }
}
