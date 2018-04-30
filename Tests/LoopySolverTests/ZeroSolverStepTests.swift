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
        let gridGen = LoopySquareGridGen(width: 2, height: 2)
        gridGen.setHint(x: 0, y: 0, hint: 0)
        gridGen.setHint(x: 1, y: 0, hint: 1)
        gridGen.setHint(x: 0, y: 1, hint: 2)
        gridGen.setHint(x: 1, y: 1, hint: 3)
        let field = gridGen.generate()
        
        let result = sut.apply(to: field)
        
        let edgesForFace: (Int) -> [Edge] = {
            result.edgeIds(forFace: $0).edges(in: result)
        }
        // `0`
        XCTAssertEqual(edgesForFace(0)[0].state, .disabled)
        XCTAssertEqual(edgesForFace(0)[1].state, .disabled)
        XCTAssertEqual(edgesForFace(0)[2].state, .disabled)
        XCTAssertEqual(edgesForFace(0)[3].state, .disabled)
        // `1`
        XCTAssertEqual(edgesForFace(1)[0].state, .normal)
        XCTAssertEqual(edgesForFace(1)[1].state, .normal)
        XCTAssertEqual(edgesForFace(1)[2].state, .normal)
        XCTAssertEqual(edgesForFace(1)[3].state, .disabled)
        // `2`
        XCTAssertEqual(edgesForFace(2)[0].state, .disabled)
        XCTAssertEqual(edgesForFace(2)[1].state, .normal)
        XCTAssertEqual(edgesForFace(2)[2].state, .normal)
        XCTAssertEqual(edgesForFace(2)[3].state, .normal)
        // `3`
        XCTAssertEqual(edgesForFace(3)[0].state, .normal)
        XCTAssertEqual(edgesForFace(3)[1].state, .normal)
        XCTAssertEqual(edgesForFace(3)[2].state, .normal)
        XCTAssertEqual(edgesForFace(3)[3].state, .normal)
    }
}
