import XCTest
@testable import NetSolver

class LoopDetectionSolverStepTests: BaseSolverStepTestClass {
    func testApply_simpleUCase() {
        // Grid with a simple U-shaped configuration where
        // the inner U has the bottom two tiles locked.
        //
        // ┌  ┌  ┐  ┐
        // │ *└ *┘  │
        // └  ─  ─  ┘
        let grid = TestGridBuilder(columns: 4, rows: 3)
            // row 1
            .setTile(0, 0, kind: .L, orientation: .east)
            .setTile(1, 0, kind: .L, orientation: .east)
            .setTile(2, 0, kind: .L, orientation: .south)
            .setTile(3, 0, kind: .L, orientation: .south)
            // row 2
            .setTile(0, 1, kind: .I, orientation: .north)
            .setTile(1, 1, kind: .L, orientation: .north, locked: true)
            .setTile(2, 1, kind: .L, orientation: .west, locked: true)
            .setTile(3, 1, kind: .I, orientation: .north)
            // row 3
            .setTile(0, 2, kind: .L, orientation: .north)
            .setTile(1, 2, kind: .I, orientation: .west)
            .setTile(2, 2, kind: .I, orientation: .west)
            .setTile(3, 2, kind: .L, orientation: .west)
            //
            .build()
        mockDelegate.mock_prepare(forGrid: grid)
        mockDelegate.metadata.setPossibleOrientations(column: 1, row: 0, [.east, .south, .west])
        let sut = LoopDetectionSolverStep()
        
        let result = sut.apply(on: grid, delegate: mockDelegate)
        
        XCTAssertEqual(result, [
            .markImpossibleOrientations(column: 1, row: 0, [.east])
        ])
    }
    
    func testApply_wrappedGrid() {
        //  ┐  ┐ ┌  ┌
        // *┘  │ │ *└
        //  ─  ┘ └  ─
        let grid = TestGridBuilder(columns: 4, rows: 3)
            .setWrapping(true)
            // row 1
            .setTile(0, 0, kind: .L, orientation: .south)
            .setTile(1, 0, kind: .L, orientation: .south)
            .setTile(2, 0, kind: .L, orientation: .east)
            .setTile(3, 0, kind: .L, orientation: .east)
            // row 2
            .setTile(0, 1, kind: .L, orientation: .west, locked: true)
            .setTile(1, 1, kind: .I, orientation: .north)
            .setTile(2, 1, kind: .I, orientation: .north)
            .setTile(3, 1, kind: .L, orientation: .north, locked: true)
            // row 3
            .setTile(0, 2, kind: .I, orientation: .west)
            .setTile(1, 2, kind: .L, orientation: .west)
            .setTile(2, 2, kind: .L, orientation: .north)
            .setTile(3, 2, kind: .I, orientation: .west)
            //
            .build()
        mockDelegate.mock_prepare(forGrid: grid)
        mockDelegate.metadata.setPossibleOrientations(column: 0, row: 0, [.east, .south, .north])
        let sut = LoopDetectionSolverStep()
        
        let result = sut.apply(on: grid, delegate: mockDelegate)
        
        XCTAssertEqual(result, [
            .markImpossibleOrientations(column: 0, row: 0, [.south])
        ])
    }
    
    func testApply_nonMatchingNetworks_doNothing() {
        // ┌  ┌  ┐  ┐
        // │ *│ *│  │
        // └  ─  ─  ┘
        let grid = TestGridBuilder(columns: 4, rows: 3)
            // row 1
            .setTile(0, 0, kind: .L, orientation: .east)
            .setTile(1, 0, kind: .L, orientation: .east)
            .setTile(2, 0, kind: .L, orientation: .south)
            .setTile(3, 0, kind: .L, orientation: .south)
            // row 2
            .setTile(0, 1, kind: .I, orientation: .north)
            .setTile(1, 1, kind: .I, orientation: .north, locked: true)
            .setTile(2, 1, kind: .I, orientation: .north, locked: true)
            .setTile(3, 1, kind: .I, orientation: .north)
            // row 3
            .setTile(0, 2, kind: .L, orientation: .north)
            .setTile(1, 2, kind: .I, orientation: .west)
            .setTile(2, 2, kind: .I, orientation: .west)
            .setTile(3, 2, kind: .L, orientation: .west)
            //
            .build()
        mockDelegate.mock_prepare(forGrid: grid)
        mockDelegate.metadata.setPossibleOrientations(column: 1, row: 0, [.east, .south, .west])
        let sut = LoopDetectionSolverStep()
        
        let result = sut.apply(on: grid, delegate: mockDelegate)
        
        XCTAssertEqual(result, [])
    }
}
