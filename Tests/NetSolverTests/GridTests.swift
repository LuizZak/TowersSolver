import XCTest
@testable import NetSolver

class GridTests: XCTestCase {
    func testBarriersForTile_1x1_nonWrapping() {
        let grid = Grid(rows: 1, columns: 1, wrapping: false)
        
        XCTAssertEqual(grid.barriersForTile(atColumn: 0, row: 0), [.top, .left, .right, .bottom])
    }
    
    func testBarriersForTile_2x2_nonWrapping() {
        let grid = Grid(rows: 2, columns: 2, wrapping: false)
        
        XCTAssertEqual(grid.barriersForTile(atColumn: 0, row: 0), [.top, .left])
        XCTAssertEqual(grid.barriersForTile(atColumn: 1, row: 0), [.top, .right])
        XCTAssertEqual(grid.barriersForTile(atColumn: 0, row: 1), [.bottom, .left])
        XCTAssertEqual(grid.barriersForTile(atColumn: 1, row: 1), [.bottom, .right])
    }
    
    func testBarriersForTile_3x3_nonWrapping() {
        let grid = Grid(rows: 3, columns: 3, wrapping: false)
        
        XCTAssertEqual(grid.barriersForTile(atColumn: 0, row: 0), [.top, .left])
        XCTAssertEqual(grid.barriersForTile(atColumn: 1, row: 0), [.top])
        XCTAssertEqual(grid.barriersForTile(atColumn: 2, row: 0), [.top, .right])
        XCTAssertEqual(grid.barriersForTile(atColumn: 0, row: 1), [.left])
        XCTAssertEqual(grid.barriersForTile(atColumn: 1, row: 1), [])
        XCTAssertEqual(grid.barriersForTile(atColumn: 2, row: 1), [.right])
        XCTAssertEqual(grid.barriersForTile(atColumn: 0, row: 2), [.bottom, .left])
        XCTAssertEqual(grid.barriersForTile(atColumn: 1, row: 2), [.bottom])
        XCTAssertEqual(grid.barriersForTile(atColumn: 2, row: 2), [.bottom, .right])
    }
    
    func testBarriersForTile_wrapping() {
        let grid = Grid(rows: 3, columns: 3, wrapping: true)
        
        XCTAssertTrue(grid.barriersForTile(atColumn: 0, row: 0).isEmpty)
        XCTAssertTrue(grid.barriersForTile(atColumn: 1, row: 0).isEmpty)
        XCTAssertTrue(grid.barriersForTile(atColumn: 2, row: 0).isEmpty)
        XCTAssertTrue(grid.barriersForTile(atColumn: 0, row: 1).isEmpty)
        XCTAssertTrue(grid.barriersForTile(atColumn: 1, row: 1).isEmpty)
        XCTAssertTrue(grid.barriersForTile(atColumn: 3, row: 1).isEmpty)
        XCTAssertTrue(grid.barriersForTile(atColumn: 0, row: 2).isEmpty)
        XCTAssertTrue(grid.barriersForTile(atColumn: 1, row: 2).isEmpty)
        XCTAssertTrue(grid.barriersForTile(atColumn: 2, row: 2).isEmpty)
    }
    
    func testColumnRowByMoving_top() {
        let grid = Grid(rows: 3, columns: 3)
        
        XCTAssert(grid.columnRowByMoving(column: 1, row: 1, direction: .top) == (1, 0))
    }
    
    func testColumnRowByMoving_top_wrapping() {
        let grid = Grid(rows: 3, columns: 3)
        
        XCTAssert(grid.columnRowByMoving(column: 1, row: 0, direction: .top) == (1, grid.rows - 1))
    }
    
    func testColumnRowByMoving_left() {
        let grid = Grid(rows: 3, columns: 3)
        
        XCTAssert(grid.columnRowByMoving(column: 1, row: 1, direction: .left) == (0, 1))
    }
    
    func testColumnRowByMoving_left_wrapping() {
        let grid = Grid(rows: 3, columns: 3)
        
        XCTAssert(grid.columnRowByMoving(column: 0, row: 1, direction: .left) == (grid.columns - 1, 1))
    }
    
    func testColumnRowByMoving_right() {
        let grid = Grid(rows: 3, columns: 3)
        
        XCTAssert(grid.columnRowByMoving(column: 1, row: 1, direction: .right) == (2, 1))
    }
    
    func testColumnRowByMoving_right_wrapping() {
        let grid = Grid(rows: 3, columns: 3)
        
        XCTAssert(grid.columnRowByMoving(column: 2, row: 1, direction: .right) == (0, 1))
    }
    
    func testColumnRowByMoving_bottom() {
        let grid = Grid(rows: 3, columns: 3)
        
        XCTAssert(grid.columnRowByMoving(column: 1, row: 1, direction: .bottom) == (1, 2))
    }
    
    func testColumnRowByMoving_bottom_wrapping() {
        let grid = Grid(rows: 3, columns: 3)
        
        XCTAssert(grid.columnRowByMoving(column: 1, row: 2, direction: .bottom) == (1, 0))
    }
}
