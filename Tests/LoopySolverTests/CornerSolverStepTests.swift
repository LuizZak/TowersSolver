import XCTest
@testable import LoopySolver

class CornerSolverStepTests: XCTestCase {
    var sut: CornerSolverStep!
    
    override func setUp() {
        super.setUp()
        
        sut = CornerSolverStep()
    }
    
    func testApplyOnTrivial() {
        // Create a simple 3x3 square grid like so:
        //  .___.___.___.
        //  !_3_!___!_0_!
        //  !___!___!___!
        //  !_1_!___!_2_!
        //
        // The expected result should have the two outer edges of the `3` cell
        // marked as part of the solution, and the outer corners of `0` and `1`
        // marked as not part of the solution.
        let gridGen = LoopySquareGridGen(width: 3, height: 3)
        gridGen.setHint(x: 0, y: 0, hint: 3)
        gridGen.setHint(x: 2, y: 0, hint: 0)
        gridGen.setHint(x: 0, y: 2, hint: 1)
        gridGen.setHint(x: 2, y: 2, hint: 2)
        let field = gridGen.generate()
        
        let result = sut.apply(to: field)
        
        // Check outer two edges of `3` cell where marked, while the inner edges
        // where not
        XCTAssertEqual(result.edgeIds(forFace: 0)[0].edge(in: result).state, .marked)
        XCTAssertEqual(result.edgeIds(forFace: 0)[1].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 0)[2].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 0)[3].edge(in: result).state, .marked)
        // `0`
        XCTAssertEqual(result.edgeIds(forFace: 2)[0].edge(in: result).state, .disabled)
        XCTAssertEqual(result.edgeIds(forFace: 2)[1].edge(in: result).state, .disabled)
        XCTAssertEqual(result.edgeIds(forFace: 2)[2].edge(in: result).state, .disabled)
        XCTAssertEqual(result.edgeIds(forFace: 2)[3].edge(in: result).state, .disabled)
        // `1`
        XCTAssertEqual(result.edgeIds(forFace: 6)[0].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 6)[1].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 6)[2].edge(in: result).state, .disabled)
        XCTAssertEqual(result.edgeIds(forFace: 6)[3].edge(in: result).state, .disabled)
        // `2`
        XCTAssertEqual(result.edgeIds(forFace: 8)[0].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 8)[1].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 8)[2].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 8)[3].edge(in: result).state, .normal)
    }
    
    func testApplyOnTwoInCorner() {
        // Create a simple 2x2 square grid like so:
        //  .___.___.
        //  !_2_!___!
        //  !___!___!
        //
        // The expected result should have the top-left face `2` has forced the
        // marking of the top-right vertical and bottom-left horizontal edges.
        let gridGen = LoopySquareGridGen(width: 2, height: 2)
        gridGen.setHint(x: 0, y: 0, hint: 2)
        let field = gridGen.generate()
        
        let result = sut.apply(to: field)
        
        // `2`
        XCTAssertEqual(result.edgeIds(forFace: 0)[0].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 0)[1].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 0)[2].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 0)[3].edge(in: result).state, .normal)
        // top-right
        XCTAssertEqual(result.edgeIds(forFace: 1)[0].edge(in: result).state, .marked)
        XCTAssertEqual(result.edgeIds(forFace: 1)[1].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 1)[2].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 1)[3].edge(in: result).state, .normal)
        // bottom-left
        XCTAssertEqual(result.edgeIds(forFace: 2)[0].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 2)[1].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 2)[2].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 2)[3].edge(in: result).state, .marked)
        // bottom-right
        XCTAssertEqual(result.edgeIds(forFace: 3)[0].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 3)[1].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 3)[2].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 3)[3].edge(in: result).state, .normal)
    }
    
    func testApplyOnTwoInCornerWithThreeOnDiagonal() {
        // Create a simple 2x2 square grid like so:
        //  .___.___.
        //  !_2_!___!
        //  !___!_3_!
        //
        // The expected result should have the top-left `2` face has the outer
        // edges marked as part of the solution, since an attempted traversal through
        // the inner faces would be abruptly stopped by the diagnotal `3`, which
        // would require capturing the line (since continuing on around the `2`
        // cell through the center would result in the `3` losing two edges (the
        // bottom-center vertical and right-center horizontal), and it would no
        // longer have enough edges to be completed.
        let gridGen = LoopySquareGridGen(width: 2, height: 2)
        gridGen.setHint(x: 0, y: 0, hint: 2)
        gridGen.setHint(x: 1, y: 1, hint: 3)
        let field = gridGen.generate()
        
        let result = sut.apply(to: field)
        
        // `2`
        XCTAssertEqual(result.edgeIds(forFace: 0)[0].edge(in: result).state, .marked)
        XCTAssertEqual(result.edgeIds(forFace: 0)[1].edge(in: result).state, .disabled)
        XCTAssertEqual(result.edgeIds(forFace: 0)[2].edge(in: result).state, .disabled)
        XCTAssertEqual(result.edgeIds(forFace: 0)[3].edge(in: result).state, .marked)
        // top-right
        XCTAssertEqual(result.edgeIds(forFace: 1)[0].edge(in: result).state, .marked)
        XCTAssertEqual(result.edgeIds(forFace: 1)[1].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 1)[2].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 1)[3].edge(in: result).state, .disabled)
        // bottom-left
        XCTAssertEqual(result.edgeIds(forFace: 2)[0].edge(in: result).state, .disabled)
        XCTAssertEqual(result.edgeIds(forFace: 2)[1].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 2)[2].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 2)[3].edge(in: result).state, .marked)
        // `3`
        XCTAssertEqual(result.edgeIds(forFace: 3)[0].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 3)[1].edge(in: result).state, .marked)
        XCTAssertEqual(result.edgeIds(forFace: 3)[2].edge(in: result).state, .marked)
        XCTAssertEqual(result.edgeIds(forFace: 3)[3].edge(in: result).state, .normal)
    }
    
    func testApplyOnTwoInCornerWithThreeOnSideDoesNotTrigger() {
        // Create a simple 2x2 square grid like so:
        //  .___.___.
        //  !_2_!_3_!
        //  !___!___!
        //
        // No deductions should be made about which of the edges of the `2` face
        // are part of the solution.
        let gridGen = LoopySquareGridGen(width: 2, height: 2)
        gridGen.setHint(x: 0, y: 0, hint: 2)
        gridGen.setHint(x: 1, y: 0, hint: 3)
        let field = gridGen.generate()
        
        let result = sut.apply(to: field)
        
        // `2`
        XCTAssertEqual(result.edgeIds(forFace: 0)[0].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 0)[1].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 0)[2].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 0)[3].edge(in: result).state, .normal)
        // `3`
        XCTAssertEqual(result.edgeIds(forFace: 1)[0].edge(in: result).state, .marked)
        XCTAssertEqual(result.edgeIds(forFace: 1)[1].edge(in: result).state, .marked)
        XCTAssertEqual(result.edgeIds(forFace: 1)[2].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 1)[3].edge(in: result).state, .normal)
        // bottom-left
        XCTAssertEqual(result.edgeIds(forFace: 2)[0].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 2)[1].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 2)[2].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 2)[3].edge(in: result).state, .marked)
        // bottom-right
        XCTAssertEqual(result.edgeIds(forFace: 3)[0].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 3)[1].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 3)[2].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 3)[3].edge(in: result).state, .normal)
    }
}
