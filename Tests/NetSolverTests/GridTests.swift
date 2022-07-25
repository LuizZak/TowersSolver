import XCTest

@testable import NetSolver

class GridTests: XCTestCase {
    func testIsWithinBounds() {
        let grid = Grid(rows: 3, columns: 2)

        XCTAssertTrue(grid.isWithinBounds(column: 0, row: 0))
        XCTAssertTrue(grid.isWithinBounds(column: 1, row: 0))
        XCTAssertTrue(grid.isWithinBounds(column: 0, row: 1))
        XCTAssertTrue(grid.isWithinBounds(column: 1, row: 1))
        XCTAssertTrue(grid.isWithinBounds(column: 0, row: 2))
        XCTAssertTrue(grid.isWithinBounds(column: 1, row: 2))
    }

    func testIsWithinBounds_returnsFalseForOutOfBounds() {
        let grid = Grid(rows: 3, columns: 2)

        XCTAssertFalse(grid.isWithinBounds(column: -1, row: 0))
        XCTAssertFalse(grid.isWithinBounds(column: 0, row: -1))
        XCTAssertFalse(grid.isWithinBounds(column: 2, row: 0))
        XCTAssertFalse(grid.isWithinBounds(column: 0, row: 3))
    }

    func testAreNeighbors() {
        let grid = Grid(rows: 3, columns: 3)

        XCTAssertTrue(grid.areNeighbors(atColumn1: 1, row1: 1, column2: 1, row2: 0))
        XCTAssertTrue(grid.areNeighbors(atColumn1: 1, row1: 1, column2: 2, row2: 1))
        XCTAssertTrue(grid.areNeighbors(atColumn1: 1, row1: 1, column2: 1, row2: 2))
        XCTAssertTrue(grid.areNeighbors(atColumn1: 1, row1: 1, column2: 0, row2: 1))
    }

    func testAreNeighbors_diagonalTiles_returnsFalse() {
        let grid = Grid(rows: 3, columns: 3)

        XCTAssertFalse(grid.areNeighbors(atColumn1: 1, row1: 1, column2: 0, row2: 0))
        XCTAssertFalse(grid.areNeighbors(atColumn1: 1, row1: 1, column2: 2, row2: 0))
        XCTAssertFalse(grid.areNeighbors(atColumn1: 1, row1: 1, column2: 2, row2: 2))
        XCTAssertFalse(grid.areNeighbors(atColumn1: 1, row1: 1, column2: 0, row2: 2))
    }

    func testAreNeighbors_oppositeTiles_wrappingGrid_returnsTrue() {
        let grid = Grid(rows: 3, columns: 3, wrapping: true)

        XCTAssertTrue(grid.areNeighbors(atColumn1: 0, row1: 0, column2: 2, row2: 0))
        XCTAssertTrue(grid.areNeighbors(atColumn1: 0, row1: 0, column2: 0, row2: 2))
        XCTAssertTrue(grid.areNeighbors(atColumn1: 2, row1: 0, column2: 0, row2: 0))
        XCTAssertTrue(grid.areNeighbors(atColumn1: 0, row1: 2, column2: 0, row2: 0))
    }

    func testAreNeighbors_oppositeTiles_nonWrappingGrid_returnsFalse() {
        let grid = Grid(rows: 3, columns: 3, wrapping: false)

        XCTAssertFalse(grid.areNeighbors(atColumn1: 0, row1: 0, column2: 2, row2: 0))
        XCTAssertFalse(grid.areNeighbors(atColumn1: 0, row1: 0, column2: 0, row2: 2))
        XCTAssertFalse(grid.areNeighbors(atColumn1: 2, row1: 0, column2: 0, row2: 0))
        XCTAssertFalse(grid.areNeighbors(atColumn1: 0, row1: 2, column2: 0, row2: 0))
    }

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

        XCTAssert(
            grid.columnRowByMoving(column: 0, row: 1, direction: .left) == (grid.columns - 1, 1)
        )
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

    func testEdgePort_neighborTiles() {
        let grid = Grid(rows: 3, columns: 3)

        XCTAssertEqual(grid.edgePort(from: (column: 1, row: 1), to: (1, 0)), .top)
        XCTAssertEqual(grid.edgePort(from: (column: 1, row: 1), to: (2, 1)), .right)
        XCTAssertEqual(grid.edgePort(from: (column: 1, row: 1), to: (1, 2)), .bottom)
        XCTAssertEqual(grid.edgePort(from: (column: 1, row: 1), to: (0, 1)), .left)
    }

    func testEdgePort_nonNeighborTiles_returnsNil() {
        let grid = Grid(rows: 3, columns: 3)

        XCTAssertNil(grid.edgePort(from: (column: 1, row: 1), to: (0, 0)))
        XCTAssertNil(grid.edgePort(from: (column: 1, row: 1), to: (2, 0)))
        XCTAssertNil(grid.edgePort(from: (column: 1, row: 1), to: (2, 2)))
        XCTAssertNil(grid.edgePort(from: (column: 1, row: 1), to: (0, 2)))
    }

    func testEdgePort_neighborTiles_wrappingGrid() {
        let grid = Grid(rows: 3, columns: 3, wrapping: true)

        XCTAssertEqual(grid.edgePort(from: (column: 0, row: 1), to: (2, 1)), .left)
        XCTAssertEqual(grid.edgePort(from: (column: 2, row: 1), to: (0, 1)), .right)
        XCTAssertEqual(grid.edgePort(from: (column: 1, row: 0), to: (1, 2)), .top)
        XCTAssertEqual(grid.edgePort(from: (column: 1, row: 2), to: (1, 0)), .bottom)
    }

    func testEdgePort_neighborTiles_nonWrappingGrid_returnsNil() {
        let grid = Grid(rows: 3, columns: 3, wrapping: false)

        XCTAssertNil(grid.edgePort(from: (column: 0, row: 1), to: (2, 1)))
        XCTAssertNil(grid.edgePort(from: (column: 2, row: 1), to: (0, 1)))
        XCTAssertNil(grid.edgePort(from: (column: 1, row: 0), to: (1, 2)))
        XCTAssertNil(grid.edgePort(from: (column: 1, row: 2), to: (1, 0)))
    }
}
