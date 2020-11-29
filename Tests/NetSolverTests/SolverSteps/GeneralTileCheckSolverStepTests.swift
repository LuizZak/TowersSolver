import XCTest
@testable import NetSolver

class GeneralTileCheckSolverStepTests: BaseSolverStepTestClass {
    func testApply_requiredMatchesGuaranteedUnavailableOutgoing_markAsInvalid() {
        let grid = TestGridBuilder(columns: 1, rows: 1)
            .build()
        mockDelegate.mock_prepare(forGrid: grid)
        mockDelegate.mock_requiredPortsForTile = { (_, _) in
            return [.top]
        }
        mockDelegate.mock_guaranteedOutgoingUnavailablePortsForTile = { (_, _) in
            return [.top]
        }
        let sut = GeneralTileCheckSolverStep(column: 0, row: 0)
        
        let result = sut.apply(on: grid, delegate: mockDelegate)
        
        XCTAssertEqual(result, [.markAsInvalid])
    }
    
    func testApply_unavailableIncomingMatchesAllButOneDirection() {
        let grid = TestGridBuilder(columns: 1, rows: 1)
            .setTileKind(0, 0, kind: .L)
            .build()
        mockDelegate.mock_prepare(forGrid: grid)
        mockDelegate.mock_unavailableIncomingPortsForTile = { (_, _) in
            return [.left, .bottom]
        }
        let sut = GeneralTileCheckSolverStep(column: 0, row: 0)
        
        let result = sut.apply(on: grid, delegate: mockDelegate)
        
        XCTAssertEqual(result, [
            .markImpossibleOrientations(column: 0, row: 0, [.east, .south, .west])
        ])
    }
    
    func testApply_unavailableIncomingMatchesAllDirections() {
        let grid = TestGridBuilder(columns: 1, rows: 1)
            .setTile(0, 0, kind: .I, orientation: .north)
            .build()
        mockDelegate.mock_prepare(forGrid: grid)
        mockDelegate.mock_unavailableIncomingPortsForTile = { (_, _) in
            return [.left, .bottom]
        }
        let sut = GeneralTileCheckSolverStep(column: 0, row: 0)
        
        let result = sut.apply(on: grid, delegate: mockDelegate)
        
        XCTAssertEqual(result, [
            .markImpossibleOrientations(column: 0, row: 0, [.north, .east])
        ])
    }
    
    func testApply_requiredMatchesOnlyOneOrientation_lockOrientation() {
        let grid = TestGridBuilder(columns: 3, rows: 3)
            .setTile(1, 1, kind: .endPoint, orientation: .north)
            .build()
        mockDelegate.mock_prepare(forGrid: grid)
        mockDelegate.mock_requiredPortsForTile = { (_, _) in
            return [.right]
        }
        let sut = GeneralTileCheckSolverStep(column: 1, row: 1)
        
        let result = sut.apply(on: grid, delegate: mockDelegate)
        
        XCTAssertEqual(result, [
            .markImpossibleOrientations(column: 1, row: 1, [.north, .south, .west])
        ])
    }
    
    func testApply_requiredDiscardsUnavailableDirections() {
        let grid = TestGridBuilder(columns: 1, rows: 1)
            .setTile(0, 0, kind: .L, orientation: .north)
            .build()
        mockDelegate.mock_prepare(forGrid: grid)
        mockDelegate.mock_requiredPortsForTile = { (_, _) in
            return [.right]
        }
        mockDelegate.mock_unavailableIncomingPortsForTile = { (_, _) in
            return []
        }
        let sut = GeneralTileCheckSolverStep(column: 0, row: 0)
        
        let result = sut.apply(on: grid, delegate: mockDelegate)
        
        XCTAssertEqual(result, [
            .markImpossibleOrientations(column: 0, row: 0, [.south, .west])
        ])
    }
    
    func testApply_markImpossibleOrientations() {
        let grid = TestGridBuilder(columns: 3, rows: 3)
            .setTileKind(1, 1, kind: .L)
            .build()
        mockDelegate.mock_prepare(forGrid: grid)
        mockDelegate.mock_guaranteedOutgoingUnavailablePortsForTile = { (_, _) in
            return [.right]
        }
        let sut = GeneralTileCheckSolverStep(column: 1, row: 1)
        
        let result = sut.apply(on: grid, delegate: mockDelegate)
        
        XCTAssertEqual(result, [.markImpossibleOrientations(column: 1, row: 1, [.north, .east])])
    }
    
    func testApply_unavailableOrientationsAreEquivalent_disableOnlyOne() {
        let grid = TestGridBuilder(columns: 3, rows: 3)
            .setTileKind(1, 1, kind: .I)
            .build()
        mockDelegate.mock_prepare(forGrid: grid)
        mockDelegate.mock_requiredPortsForTile = { (_, _) in
            return [.left]
        }
        let sut = GeneralTileCheckSolverStep(column: 1, row: 1)
        
        let result = sut.apply(on: grid, delegate: mockDelegate)
        
        XCTAssertEqual(result, [
            .markImpossibleOrientations(column: 1, row: 1, [.north])
        ])
    }
}
