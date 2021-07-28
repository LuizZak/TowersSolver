import XCTest
@testable import LoopySolver

class NeighboringSemiCompleteFacesSolverStepTests: XCTestCase {
    var sut: NeighboringSemiCompleteFacesSolverStep!
    var delegate: SolverStepDelegate!
    
    override func setUp() {
        super.setUp()
        
        sut = NeighboringSemiCompleteFacesSolverStep()
        delegate = TestSolverStepDelegate()
    }
    
    func testIsEphemeral() {
        XCTAssertFalse(sut.isEphemeral)
    }
    
    func testTouchingEdgeWise() {
        // Test a case where two semi-complete faces are touching, sharing a
        // common edge:
        //  .___.___.___.___.
        //  !___!_3_!_3_!___!
        //  !___!___!___!___!
        //
        // Result should be a grid with the following configuration:
        //  .___.___.___.___.
        //  !___║_3_║_3_║___!
        //  !___!___.___!___!
        //
        // The shared edge for the two faces is marked, and all opposing edges
        // (remaining edges of both faces that do not share a vertex with the
        // shared edge) are marked as part of the solution as well.
        //
        // Also, any edges from other faces touching the shared edge are disabled,
        // as they are not part of the solution.
        let gridGen = LoopySquareGridGen(width: 4, height: 2)
        gridGen.setHint(x: 1, y: 0, hint: 3)
        gridGen.setHint(x: 2, y: 0, hint: 3)
        
        let result = sut.apply(to: gridGen.generate(), delegate)
        
        let edgeStatesForFace: (Int) -> [Edge.State] = {
            result.edges(forFace: $0).map(result.edgeState(forEdge:))
        }
        // Top-left
        XCTAssertEqual(edgeStatesForFace(0)[0], .normal)
        XCTAssertEqual(edgeStatesForFace(0)[1], .marked)
        XCTAssertEqual(edgeStatesForFace(0)[2], .normal)
        XCTAssertEqual(edgeStatesForFace(0)[3], .normal)
        // `3` (top-center-left)
        XCTAssertEqual(edgeStatesForFace(1)[0], .normal)
        XCTAssertEqual(edgeStatesForFace(1)[1], .marked)
        XCTAssertEqual(edgeStatesForFace(1)[2], .normal)
        XCTAssertEqual(edgeStatesForFace(1)[3], .marked)
        // `3` (top-center-right)
        XCTAssertEqual(edgeStatesForFace(2)[0], .normal)
        XCTAssertEqual(edgeStatesForFace(2)[1], .marked)
        XCTAssertEqual(edgeStatesForFace(2)[2], .normal)
        XCTAssertEqual(edgeStatesForFace(2)[3], .marked)
        // Top-right
        XCTAssertEqual(edgeStatesForFace(3)[0], .normal)
        XCTAssertEqual(edgeStatesForFace(3)[1], .normal)
        XCTAssertEqual(edgeStatesForFace(3)[2], .normal)
        XCTAssertEqual(edgeStatesForFace(3)[3], .marked)
        // Bottom-left
        XCTAssertEqual(edgeStatesForFace(4)[0], .normal)
        XCTAssertEqual(edgeStatesForFace(4)[1], .normal)
        XCTAssertEqual(edgeStatesForFace(4)[2], .normal)
        XCTAssertEqual(edgeStatesForFace(4)[3], .normal)
        // Bottom-center-left
        XCTAssertEqual(edgeStatesForFace(5)[0], .normal)
        XCTAssertEqual(edgeStatesForFace(5)[1], .disabled)
        XCTAssertEqual(edgeStatesForFace(5)[2], .normal)
        XCTAssertEqual(edgeStatesForFace(5)[3], .normal)
        // Bottom-center-right
        XCTAssertEqual(edgeStatesForFace(6)[0], .normal)
        XCTAssertEqual(edgeStatesForFace(6)[1], .normal)
        XCTAssertEqual(edgeStatesForFace(6)[2], .normal)
        XCTAssertEqual(edgeStatesForFace(6)[3], .disabled)
        // Bottom-right
        XCTAssertEqual(edgeStatesForFace(7)[0], .normal)
        XCTAssertEqual(edgeStatesForFace(7)[1], .normal)
        XCTAssertEqual(edgeStatesForFace(7)[2], .normal)
        XCTAssertEqual(edgeStatesForFace(7)[3], .normal)
    }
    
    func testSharingVertex() {
        // Test a case where two semi-complete faces share a common vertex:
        // •───•───•
        // │ 3 │   │
        // •───•───•
        // |   │ 3 │
        // •───•───•
        //
        // Result should be all edges not sharing the common vertex to be marked
        // as part of the solution:
        // •═══•───•
        // ║ 3 │   │
        // •───•───•
        // |   │ 3 ║
        // •───•═══•
        let gridGen = LoopySquareGridGen(width: 2, height: 2)
        gridGen.setHint(x: 0, y: 0, hint: 3)
        gridGen.setHint(x: 1, y: 1, hint: 3)
        
        let result = sut.apply(to: gridGen.generate(), delegate)
        
        let edgeStatesForFace: (Int) -> [Edge.State] = {
            result.edges(forFace: $0).map(result.edgeState(forEdge:))
        }
        // Top-left `3`
        XCTAssertEqual(edgeStatesForFace(0)[0], .marked)
        XCTAssertEqual(edgeStatesForFace(0)[1], .normal)
        XCTAssertEqual(edgeStatesForFace(0)[2], .normal)
        XCTAssertEqual(edgeStatesForFace(0)[3], .marked)
        // Top-right
        XCTAssertEqual(edgeStatesForFace(1)[0], .normal)
        XCTAssertEqual(edgeStatesForFace(1)[1], .normal)
        XCTAssertEqual(edgeStatesForFace(1)[2], .normal)
        XCTAssertEqual(edgeStatesForFace(1)[3], .normal)
        // Bottom-left
        XCTAssertEqual(edgeStatesForFace(2)[0], .normal)
        XCTAssertEqual(edgeStatesForFace(2)[1], .normal)
        XCTAssertEqual(edgeStatesForFace(2)[2], .normal)
        XCTAssertEqual(edgeStatesForFace(2)[3], .normal)
        // Bottom-right `3`
        XCTAssertEqual(edgeStatesForFace(3)[0], .normal)
        XCTAssertEqual(edgeStatesForFace(3)[1], .marked)
        XCTAssertEqual(edgeStatesForFace(3)[2], .marked)
        XCTAssertEqual(edgeStatesForFace(3)[3], .normal)
    }
}
