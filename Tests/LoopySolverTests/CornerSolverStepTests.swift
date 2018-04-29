import XCTest
@testable import LoopySolver

class CornerSolverStepTests: XCTestCase {
    var sut: CornerSolverStep!
    
    override func setUp() {
        super.setUp()
        
        sut = CornerSolverStep()
    }
    
    func testApplyOnTrivial() {
        // Create a simple 2x2 square grid like so:
        //   _______
        //  |_3_|_0_|
        //  |_1_|_2_|
        //
        // The expected result should have the two outer edges of the `3` cell
        // marked as part of the solution, and the outer corners of `0` and `1`
        // marked as not part of the solution.
        let gridGen = LoopySquareGrid(width: 2, height: 2)
        gridGen.setHint(x: 0, y: 0, hint: 3)
        gridGen.setHint(x: 1, y: 0, hint: 0)
        gridGen.setHint(x: 0, y: 1, hint: 1)
        gridGen.setHint(x: 1, y: 1, hint: 2)
        let grid = gridGen.generate()
        
        let result = sut.apply(to: grid)
        
        // Check outer two edges of `3` cell where marked, while the inner edges
        // where not
        XCTAssertEqual(result.edgeIds(forFace: 0)[0].edge(in: result).state, .marked)
        XCTAssertEqual(result.edgeIds(forFace: 0)[1].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 0)[2].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 0)[3].edge(in: result).state, .marked)
        // `0`
        XCTAssertEqual(result.edgeIds(forFace: 1)[0].edge(in: result).state, .disabled)
        XCTAssertEqual(result.edgeIds(forFace: 1)[1].edge(in: result).state, .disabled)
        XCTAssertEqual(result.edgeIds(forFace: 1)[2].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 1)[3].edge(in: result).state, .normal)
        // `1`
        XCTAssertEqual(result.edgeIds(forFace: 2)[0].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 2)[1].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 2)[2].edge(in: result).state, .disabled)
        XCTAssertEqual(result.edgeIds(forFace: 2)[3].edge(in: result).state, .disabled)
        // `2`
        XCTAssertEqual(result.edgeIds(forFace: 3)[0].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 3)[1].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 3)[2].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 3)[3].edge(in: result).state, .normal)
    }
}
