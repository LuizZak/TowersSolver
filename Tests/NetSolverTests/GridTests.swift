import XCTest
@testable import NetSolver

class GridTests: XCTestCase {
    func testBarriersForTile_nonWrapping() {
        let grid = Grid(rows: 3, columns: 3, wrapping: false)
        
        XCTAssertEqual(Set(grid.barriersForTile(atColumn: 0, row: 0)), [.left, .top])
        XCTAssertEqual(Set(grid.barriersForTile(atColumn: 1, row: 0)), [.top])
        XCTAssertEqual(Set(grid.barriersForTile(atColumn: 2, row: 0)), [.top, .right])
        XCTAssertEqual(Set(grid.barriersForTile(atColumn: 0, row: 1)), [.left])
        XCTAssertEqual(Set(grid.barriersForTile(atColumn: 1, row: 1)), [])
        XCTAssertEqual(Set(grid.barriersForTile(atColumn: 2, row: 1)), [.right])
        XCTAssertEqual(Set(grid.barriersForTile(atColumn: 0, row: 2)), [.left, .bottom])
        XCTAssertEqual(Set(grid.barriersForTile(atColumn: 1, row: 2)), [.bottom])
        XCTAssertEqual(Set(grid.barriersForTile(atColumn: 2, row: 2)), [.bottom, .right])
    }
    
    func testBarriersForTile_wrapping() {
        let grid = Grid(rows: 3, columns: 3, wrapping: true)
        
        XCTAssertTrue(Set(grid.barriersForTile(atColumn: 0, row: 0)).isEmpty)
        XCTAssertTrue(Set(grid.barriersForTile(atColumn: 1, row: 0)).isEmpty)
        XCTAssertTrue(Set(grid.barriersForTile(atColumn: 2, row: 0)).isEmpty)
        XCTAssertTrue(Set(grid.barriersForTile(atColumn: 0, row: 1)).isEmpty)
        XCTAssertTrue(Set(grid.barriersForTile(atColumn: 1, row: 1)).isEmpty)
        XCTAssertTrue(Set(grid.barriersForTile(atColumn: 3, row: 1)).isEmpty)
        XCTAssertTrue(Set(grid.barriersForTile(atColumn: 0, row: 2)).isEmpty)
        XCTAssertTrue(Set(grid.barriersForTile(atColumn: 1, row: 2)).isEmpty)
        XCTAssertTrue(Set(grid.barriersForTile(atColumn: 2, row: 2)).isEmpty)
    }
}
