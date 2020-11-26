import XCTest
@testable import NetSolver

class AwayFromBarriersSolverStepTests: XCTestCase {
    var mockDelegate: MockNetSolverDelegate!
    
    override func setUp() {
        super.setUp()
        
        mockDelegate = MockNetSolverDelegate()
    }
    
    override func tearDown() {
        super.tearDown()
        
        mockDelegate = nil
    }
    
    func testApply_nonWrappingGrid_cornerTile_atTopLeftCorner() {
        let grid = TestGridBuilder(columns: 3, rows: 3)
            .setAllTiles(kind: .L, orientation: .north)
            .build()
        mockDelegate.mock_prepare(forGrid: grid)
        let sut = AwayFromBarriersSolverStep(column: 0, row: 0)
        
        _ = sut.apply(on: grid, delegate: mockDelegate)
        
        assertEnqueued(TileLockingStep(column: 0, row: 0, orientation: .east))
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
        
        _ = sut.apply(on: grid, delegate: mockDelegate)
        
        assertEnqueued(TileLockingStep(column: 1, row: 0, orientation: .east))
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
        
        _ = sut.apply(on: grid, delegate: mockDelegate)
        
        assertEnqueued(TileLockingStep(column: 0, row: 1, orientation: .north))
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
        
        _ = sut.apply(on: grid, delegate: mockDelegate)
        
        assertEnqueued(TileLockingStep(column: 1, row: 0, orientation: .south))
    }
    
    func testApply_nonWrappingGrid_endPoint_atTopEdge_doesNotChangeTileOrientation() {
        // Set an end point tile at the top-center tile and check that no locking
        // is done because the set of possible orientations is greater than one
        // while providing no equivalent ports amongst the available orientations.
        let grid = TestGridBuilder(columns: 3, rows: 3)
            .setAllTiles(kind: .L, orientation: .north)
            .setTile(1, 0, kind: .endPoint, orientation: .north)
            .build()
        mockDelegate.mock_prepare(forGrid: grid)
        let sut = AwayFromBarriersSolverStep(column: 1, row: 0)
        
        _ = sut.apply(on: grid, delegate: mockDelegate)
        
        assertEnqueuedNone()
    }
}

// MARK: - Assertion functions
private extension AwayFromBarriersSolverStepTests {
    func assertEnqueuedNone(line: UInt = #line) {
        guard !mockDelegate.didCallEnqueue.isEmpty else {
            return
        }
        
        XCTFail(
            """
            Expected no solver steps enqueued, but \(mockDelegate.didCallEnqueue.count) steps where found:
            
            \(mockDelegate.didCallEnqueue.map(String.init(describing:)).joined(separator: "\n"))
            """, line: line)
    }
    
    func assertEnqueued<Step: NetSolverStep & Equatable>(_ step: Step,
                                                         line: UInt = #line) {
        
        guard !mockDelegate.didCallEnqueue.isEmpty else {
            XCTFail(
                """
                Expected solver step \(step) is not enqueued.
                0 steps are currently enqueued.
                """, line: line)
            return
        }
        
        for s in mockDelegate.didCallEnqueue {
            if s as? Step == step {
                return
            }
        }
        
        XCTFail(
            """
            Expected solver step \(step) to be present, but isn't.
            \(mockDelegate.didCallEnqueue.count) steps are currently enqueued:
            
            \(mockDelegate.didCallEnqueue.map(String.init(describing:)).joined(separator: "\n"))
            """, line: line)
    }
    
    func assertOrientation(of tile: Tile,
                           oneOf orientations: Set<Tile.Orientation>,
                           line: UInt = #line) {
        
        XCTAssertTrue(
            orientations.contains(tile.orientation),
            """
            Expected either \
            [\(orientations.map(String.init(describing:)).joined(separator: ", "))] \
            but result is '\(tile.orientation)'
            """,
            line: line)
    }
}
