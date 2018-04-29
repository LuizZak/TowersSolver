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
        let gridGen = LoopySquareGrid(width: 3, height: 3)
        gridGen.setHint(x: 0, y: 0, hint: 3)
        gridGen.setHint(x: 2, y: 0, hint: 0)
        gridGen.setHint(x: 0, y: 2, hint: 1)
        gridGen.setHint(x: 2, y: 2, hint: 2)
        let grid = gridGen.generate()
        
        let result = sut.apply(to: grid)
        
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
}
