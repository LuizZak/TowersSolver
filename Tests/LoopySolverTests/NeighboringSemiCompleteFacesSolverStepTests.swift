import XCTest
@testable import LoopySolver

class NeighboringSemiCompleteFacesSolverStepTests: XCTestCase {
    var sut: NeighboringSemiCompleteFacesSolverStep!
    
    override func setUp() {
        super.setUp()
        
        sut = NeighboringSemiCompleteFacesSolverStep()
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
        
        let result = sut.apply(to: gridGen.generate())
        
        let edgesForFace: (Int) -> [Edge] = {
            result.edgeIds(forFace: $0).edges(in: result)
        }
        // Top-left
        XCTAssertEqual(edgesForFace(0)[0].state, .normal)
        XCTAssertEqual(edgesForFace(0)[1].state, .marked)
        XCTAssertEqual(edgesForFace(0)[2].state, .normal)
        XCTAssertEqual(edgesForFace(0)[3].state, .normal)
        // `3` (top-center-left)
        XCTAssertEqual(edgesForFace(1)[0].state, .normal)
        XCTAssertEqual(edgesForFace(1)[1].state, .marked)
        XCTAssertEqual(edgesForFace(1)[2].state, .normal)
        XCTAssertEqual(edgesForFace(1)[3].state, .marked)
        // `3` (top-center-right)
        XCTAssertEqual(edgesForFace(2)[0].state, .normal)
        XCTAssertEqual(edgesForFace(2)[1].state, .marked)
        XCTAssertEqual(edgesForFace(2)[2].state, .normal)
        XCTAssertEqual(edgesForFace(2)[3].state, .marked)
        // Top-right
        XCTAssertEqual(edgesForFace(3)[0].state, .normal)
        XCTAssertEqual(edgesForFace(3)[1].state, .normal)
        XCTAssertEqual(edgesForFace(3)[2].state, .normal)
        XCTAssertEqual(edgesForFace(3)[3].state, .marked)
        // Bottom-left
        XCTAssertEqual(edgesForFace(4)[0].state, .normal)
        XCTAssertEqual(edgesForFace(4)[1].state, .normal)
        XCTAssertEqual(edgesForFace(4)[2].state, .normal)
        XCTAssertEqual(edgesForFace(4)[3].state, .normal)
        // Bottom-center-left
        XCTAssertEqual(edgesForFace(5)[0].state, .normal)
        XCTAssertEqual(edgesForFace(5)[1].state, .disabled)
        XCTAssertEqual(edgesForFace(5)[2].state, .normal)
        XCTAssertEqual(edgesForFace(5)[3].state, .normal)
        // Bottom-center-right
        XCTAssertEqual(edgesForFace(6)[0].state, .normal)
        XCTAssertEqual(edgesForFace(6)[1].state, .normal)
        XCTAssertEqual(edgesForFace(6)[2].state, .normal)
        XCTAssertEqual(edgesForFace(6)[3].state, .disabled)
        // Bottom-right
        XCTAssertEqual(edgesForFace(7)[0].state, .normal)
        XCTAssertEqual(edgesForFace(7)[1].state, .normal)
        XCTAssertEqual(edgesForFace(7)[2].state, .normal)
        XCTAssertEqual(edgesForFace(7)[3].state, .normal)
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
        
        let result = sut.apply(to: gridGen.generate())
        
        let edgesForFace: (Int) -> [Edge] = {
            result.edgeIds(forFace: $0).edges(in: result)
        }
        // Top-left `3`
        XCTAssertEqual(edgesForFace(0)[0].state, .marked)
        XCTAssertEqual(edgesForFace(0)[1].state, .normal)
        XCTAssertEqual(edgesForFace(0)[2].state, .normal)
        XCTAssertEqual(edgesForFace(0)[3].state, .marked)
        // Top-right
        XCTAssertEqual(edgesForFace(1)[0].state, .normal)
        XCTAssertEqual(edgesForFace(1)[1].state, .normal)
        XCTAssertEqual(edgesForFace(1)[2].state, .normal)
        XCTAssertEqual(edgesForFace(1)[3].state, .normal)
        // Bottom-left
        XCTAssertEqual(edgesForFace(2)[0].state, .normal)
        XCTAssertEqual(edgesForFace(2)[1].state, .normal)
        XCTAssertEqual(edgesForFace(2)[2].state, .normal)
        XCTAssertEqual(edgesForFace(2)[3].state, .normal)
        // Bottom-right `3`
        XCTAssertEqual(edgesForFace(3)[0].state, .normal)
        XCTAssertEqual(edgesForFace(3)[1].state, .marked)
        XCTAssertEqual(edgesForFace(3)[2].state, .marked)
        XCTAssertEqual(edgesForFace(3)[3].state, .normal)
    }
}
