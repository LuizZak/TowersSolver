import XCTest

@testable import NetSolver

class FlankedTileCheckerSolverStepTests: BaseSolverStepTestClass {
    func testApply_flankedTTile() {
        let grid = TestGridBuilder(columns: 3, rows: 3)
            .setTileKind(1, 1, kind: .T)
            .setTileKind(0, 1, kind: .endPoint)
            .setTileKind(2, 1, kind: .endPoint)
            .setTileKind(1, 2, kind: .endPoint)
            .build()
        let sut = FlankedTileCheckerSolverStep()
        mockDelegate.mock_prepare(forGrid: grid)

        let result = sut.apply(on: grid, delegate: mockDelegate)

        XCTAssertEqual(result, [
            .markImpossibleOrientations(
                column: 1,
                row: 1,
                [.south]
            ),
        ])
    }

    func testApply_flankedLTile() {
        let grid = TestGridBuilder(columns: 3, rows: 3)
            .setTileKind(1, 1, kind: .L)
            .setTileKind(0, 1, kind: .endPoint)
            .setTileKind(2, 1, kind: .endPoint)
            .setTileKind(1, 2, kind: .endPoint)
            .build()
        let sut = FlankedTileCheckerSolverStep()
        mockDelegate.mock_prepare(forGrid: grid)

        let result = sut.apply(on: grid, delegate: mockDelegate)

        XCTAssertEqual(result, [
            .markImpossibleOrientations(
                column: 1,
                row: 1,
                [.east, .south]
            ),
        ])
    }

    func testApply_flankedITile() {
        let grid = TestGridBuilder(columns: 3, rows: 3)
            .setTileKind(1, 1, kind: .I)
            .setTileKind(0, 1, kind: .endPoint)
            .setTileKind(2, 1, kind: .endPoint)
            .setTileKind(1, 2, kind: .endPoint)
            .build()
        let sut = FlankedTileCheckerSolverStep()
        mockDelegate.mock_prepare(forGrid: grid)

        let result = sut.apply(on: grid, delegate: mockDelegate)

        XCTAssertEqual(result, [
            .lockOrientation(
                column: 1,
                row: 1,
                orientation: .north
            ),
        ])
    }

    func testApply_flankedEndpointTile() {
        let grid = TestGridBuilder(columns: 3, rows: 3)
            .setTileKind(1, 1, kind: .endPoint)
            .setTileKind(0, 1, kind: .endPoint)
            .setTileKind(2, 1, kind: .endPoint)
            .setTileKind(1, 2, kind: .endPoint)
            .build()
        let sut = FlankedTileCheckerSolverStep()
        mockDelegate.mock_prepare(forGrid: grid)

        let result = sut.apply(on: grid, delegate: mockDelegate)

        XCTAssertEqual(result, [
            .lockOrientation(
                column: 1,
                row: 1,
                orientation: .north
            ),
        ])
    }
}
