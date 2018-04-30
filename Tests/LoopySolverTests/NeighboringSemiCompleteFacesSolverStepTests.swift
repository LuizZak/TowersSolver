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
        
        // Top-left
        XCTAssertEqual(result.edgeIds(forFace: 0)[0].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 0)[1].edge(in: result).state, .marked)
        XCTAssertEqual(result.edgeIds(forFace: 0)[2].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 0)[3].edge(in: result).state, .normal)
        // `3` (top-center-left)
        XCTAssertEqual(result.edgeIds(forFace: 1)[0].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 1)[1].edge(in: result).state, .marked)
        XCTAssertEqual(result.edgeIds(forFace: 1)[2].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 1)[3].edge(in: result).state, .marked)
        // `3` (top-center-right)
        XCTAssertEqual(result.edgeIds(forFace: 2)[0].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 2)[1].edge(in: result).state, .marked)
        XCTAssertEqual(result.edgeIds(forFace: 2)[2].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 2)[3].edge(in: result).state, .marked)
        // Top-right
        XCTAssertEqual(result.edgeIds(forFace: 3)[0].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 3)[1].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 3)[2].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 3)[3].edge(in: result).state, .marked)
        // Bottom-left
        XCTAssertEqual(result.edgeIds(forFace: 4)[0].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 4)[1].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 4)[2].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 4)[3].edge(in: result).state, .normal)
        // Bottom-center-left
        XCTAssertEqual(result.edgeIds(forFace: 5)[0].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 5)[1].edge(in: result).state, .disabled)
        XCTAssertEqual(result.edgeIds(forFace: 5)[2].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 5)[3].edge(in: result).state, .normal)
        // Bottom-center-right
        XCTAssertEqual(result.edgeIds(forFace: 6)[0].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 6)[1].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 6)[2].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 6)[3].edge(in: result).state, .disabled)
        // Bottom-right
        XCTAssertEqual(result.edgeIds(forFace: 7)[0].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 7)[1].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 7)[2].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 7)[3].edge(in: result).state, .normal)
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
        
        // Top-left `3`
        XCTAssertEqual(result.edgeIds(forFace: 0)[0].edge(in: result).state, .marked)
        XCTAssertEqual(result.edgeIds(forFace: 0)[1].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 0)[2].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 0)[3].edge(in: result).state, .marked)
        // Top-right
        XCTAssertEqual(result.edgeIds(forFace: 1)[0].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 1)[1].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 1)[2].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 1)[3].edge(in: result).state, .normal)
        // Bottom-left
        XCTAssertEqual(result.edgeIds(forFace: 2)[0].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 2)[1].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 2)[2].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 2)[3].edge(in: result).state, .normal)
        // Bottom-right `3`
        XCTAssertEqual(result.edgeIds(forFace: 3)[0].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 3)[1].edge(in: result).state, .marked)
        XCTAssertEqual(result.edgeIds(forFace: 3)[2].edge(in: result).state, .marked)
        XCTAssertEqual(result.edgeIds(forFace: 3)[3].edge(in: result).state, .normal)
    }
}
