import XCTest
@testable import NetSolver

class SolverInvcationTests: XCTestCase {
    func testUnavailablePortsForTile_nonWrappingGrid() {
        let grid = TestGridBuilder(columns: 3, rows: 3)
            .build()
        let sut = SolverInvocation(grid: grid)
        
        XCTAssertEqual(sut.unavailablePortsForTile(atColumn: 0, row: 0), [.top, .left])
        XCTAssertEqual(sut.unavailablePortsForTile(atColumn: 1, row: 0), [.top])
        XCTAssertEqual(sut.unavailablePortsForTile(atColumn: 2, row: 0), [.top, .right])
        XCTAssertEqual(sut.unavailablePortsForTile(atColumn: 0, row: 1), [.left])
        XCTAssertEqual(sut.unavailablePortsForTile(atColumn: 1, row: 1), [])
        XCTAssertEqual(sut.unavailablePortsForTile(atColumn: 2, row: 1), [.right])
        XCTAssertEqual(sut.unavailablePortsForTile(atColumn: 0, row: 2), [.bottom, .left])
        XCTAssertEqual(sut.unavailablePortsForTile(atColumn: 1, row: 2), [.bottom])
        XCTAssertEqual(sut.unavailablePortsForTile(atColumn: 2, row: 2), [.bottom, .right])
    }
    
    func testUnavailablePortsForTile_neighborLockedTile() {
        // Create a grid with a locked T tile that is pointing south (all ports
        // except top are available as connections), and check the four surrounding
        // tiles for connection unavailability.
        let grid = TestGridBuilder(columns: 6, rows: 6)
            .setTile(2, 2, kind: .T, orientation: .south)
            .lockTile(atColumn: 2, row: 2)
            .build()
        let sut = SolverInvocation(grid: grid)
        
        // Top
        XCTAssertEqual(sut.unavailablePortsForTile(atColumn: 2, row: 1), [.bottom])
        // Left
        XCTAssertEqual(sut.unavailablePortsForTile(atColumn: 1, row: 2), [])
        // Right
        XCTAssertEqual(sut.unavailablePortsForTile(atColumn: 3, row: 2), [])
        // Bottom
        XCTAssertEqual(sut.unavailablePortsForTile(atColumn: 2, row: 3), [])
    }
}
