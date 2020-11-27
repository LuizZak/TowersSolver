import XCTest
@testable import NetSolver

class EndPointNeighborsSolverStepTests: BaseSolverStepTestClass {
    func testApply_nonWrapping_onEdge_surroundedByEndPoints() {
        let grid = TestGridBuilder(columns: 6, rows: 3)
            .setTile(1, 0, kind: .endPoint, orientation: .north)
            .setTile(2, 0, kind: .endPoint, orientation: .north)
            .setTile(3, 0, kind: .endPoint, orientation: .north)
            .build()
        mockDelegate.mock_prepare(forGrid: grid)
        let sut = EndPointNeighborsSolverStep(column: 2, row: 0)
        
        let result = sut.apply(on: grid, delegate: mockDelegate)
        
        XCTAssertEqual(result, [.lockOrientation(column: 2, row: 0, orientation: .south)])
    }
    
    func testApply_wrapping_onEdge_surroundedByEndPoints() {
        let grid = TestGridBuilder(columns: 6, rows: 3)
            .setTile(1, 0, kind: .endPoint, orientation: .north)
            .setTile(2, 0, kind: .endPoint, orientation: .north)
            .setTile(3, 0, kind: .endPoint, orientation: .north)
            .setWrapping(true)
            .build()
        mockDelegate.mock_prepare(forGrid: grid)
        let sut = EndPointNeighborsSolverStep(column: 2, row: 0)
        
        let result = sut.apply(on: grid, delegate: mockDelegate)
        
        XCTAssertEqual(result, [
            .markImpossibleOrientations(column: 2, row: 0, [.east, .west])
        ])
    }
}
