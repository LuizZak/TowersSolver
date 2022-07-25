import XCTest

@testable import NetSolver

class AwayFromBarriersSolverStepTests: BaseSolverStepTestClass {
    func testApply_nonWrappingGrid_cornerTile_atTopLeftCorner() {
        let grid = TestGridBuilder(columns: 3, rows: 3)
            .setAllTiles(kind: .L, orientation: .north)
            .build()
        mockDelegate.mock_prepare(forGrid: grid)
        let sut = AwayFromBarriersSolverStep(column: 0, row: 0)

        let result = sut.apply(on: grid, delegate: mockDelegate)

        XCTAssertEqual(result, [.lockOrientation(column: 0, row: 0, orientation: .east)])
    }

    func testApply_nonWrappingGrid_lineTile_atTopEdge() {
        // Set an I tile at the top-center tile and check it is locked away from
        // the edge, always preferring east orientation
        let grid = TestGridBuilder(columns: 3, rows: 3)
            .setAllTiles(kind: .L, orientation: .north)
            .setTile(1, 0, kind: .I, orientation: .north)
            .build()
        mockDelegate.mock_prepare(forGrid: grid)
        let sut = AwayFromBarriersSolverStep(column: 1, row: 0)

        let result = sut.apply(on: grid, delegate: mockDelegate)

        XCTAssertEqual(result, [.lockOrientation(column: 1, row: 0, orientation: .east)])
    }

    func testApply_nonWrappingGrid_lineTile_atLeftEdge() {
        // Set an I tile at the left-center tile and check it is locked away from
        // the edge, always preferring north orientation
        let grid = TestGridBuilder(columns: 3, rows: 3)
            .setAllTiles(kind: .L, orientation: .north)
            .setTile(0, 1, kind: .I, orientation: .west)
            .build()
        mockDelegate.mock_prepare(forGrid: grid)
        let sut = AwayFromBarriersSolverStep(column: 0, row: 1)

        let result = sut.apply(on: grid, delegate: mockDelegate)

        XCTAssertEqual(result, [.lockOrientation(column: 0, row: 1, orientation: .north)])
    }

    func testApply_nonWrappingGrid_tripleTile_atTopEdge() {
        // Set a T tile at the top-center tile and check it is locked away from
        // the edge
        let grid = TestGridBuilder(columns: 3, rows: 3)
            .setAllTiles(kind: .L, orientation: .north)
            .setTile(1, 0, kind: .T, orientation: .north)
            .build()
        mockDelegate.mock_prepare(forGrid: grid)
        let sut = AwayFromBarriersSolverStep(column: 1, row: 0)

        let result = sut.apply(on: grid, delegate: mockDelegate)

        XCTAssertEqual(result, [.lockOrientation(column: 1, row: 0, orientation: .south)])
    }

    func testApply_nonWrappingGrid_endPoint_atTopEdge_markUnavailable() {
        // End-points at the edge of non-wrapping grids or with surrounding barriers
        // should have unavailable ports reported
        let grid = TestGridBuilder(columns: 3, rows: 3)
            .setAllTiles(kind: .L, orientation: .north)
            .setTile(1, 0, kind: .endPoint, orientation: .north)
            .build()
        mockDelegate.mock_prepare(forGrid: grid)
        let sut = AwayFromBarriersSolverStep(column: 1, row: 0)

        let result = sut.apply(on: grid, delegate: mockDelegate)

        XCTAssertEqual(
            result,
            [
                .markImpossibleOrientations(column: 1, row: 0, [.north])
            ]
        )
    }

    func testApply_noAvailablePorts_markAsInvalid() {
        // Create a grid with a line piece sitting on a corner, which cannot be
        // solved if the grid is non-wrapping
        let grid = TestGridBuilder(columns: 2, rows: 2)
            .setTile(0, 0, kind: .I, orientation: .north)
            .build()
        mockDelegate.mock_prepare(forGrid: grid)
        let sut = AwayFromBarriersSolverStep(column: 0, row: 0)

        let result = sut.apply(on: grid, delegate: mockDelegate)

        XCTAssertEqual(result, [.markAsInvalid])
    }

    func testApply_ignoreLockedTiles() {
        let grid = TestGridBuilder(columns: 2, rows: 2)
            .setTile(0, 0, kind: .I, orientation: .north, locked: true)
            .build()
        mockDelegate.mock_prepare(forGrid: grid)
        let sut = AwayFromBarriersSolverStep(column: 0, row: 0)

        let result = sut.apply(on: grid, delegate: mockDelegate)

        XCTAssertEqual(result, [])
    }
}
