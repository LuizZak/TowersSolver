import XCTest
@testable import LoopySolver

class ZeroSolverStepTests: XCTestCase {
    var sut: ZeroSolverStep!
    
    override func setUp() {
        super.setUp()
        
        sut = ZeroSolverStep()
    }
    
    func testApplyOnTrivial() {
        // Create a simple 2x2 square grid like so:
        //   _______
        //  |_0_|_1_|
        //  |_2_|_3_|
        //
        // Result should be a grid with all surrounding edges of `0` being disabled.
        let gridGen = LoopySquareGrid(width: 2, height: 2)
        gridGen.setHint(x: 0, y: 0, hint: 0)
        gridGen.setHint(x: 1, y: 0, hint: 1)
        gridGen.setHint(x: 0, y: 1, hint: 2)
        gridGen.setHint(x: 1, y: 1, hint: 3)
        let grid = gridGen.generate()
        
        let result = sut.apply(to: grid)
        
        // `0`
        XCTAssertEqual(result.edgeIds(forFace: 0)[0].edge(in: result).state, .disabled)
        XCTAssertEqual(result.edgeIds(forFace: 0)[1].edge(in: result).state, .disabled)
        XCTAssertEqual(result.edgeIds(forFace: 0)[2].edge(in: result).state, .disabled)
        XCTAssertEqual(result.edgeIds(forFace: 0)[3].edge(in: result).state, .disabled)
        // `1`
        XCTAssertEqual(result.edgeIds(forFace: 1)[0].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 1)[1].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 1)[2].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 1)[3].edge(in: result).state, .disabled)
        // `2`
        XCTAssertEqual(result.edgeIds(forFace: 2)[0].edge(in: result).state, .disabled)
        XCTAssertEqual(result.edgeIds(forFace: 2)[1].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 2)[2].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 2)[3].edge(in: result).state, .normal)
        // `3`
        XCTAssertEqual(result.edgeIds(forFace: 3)[0].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 3)[1].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 3)[2].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 3)[3].edge(in: result).state, .normal)
    }
}
