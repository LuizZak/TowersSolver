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
        let grid = gridGen.generate()
        
        let result = sut.apply(to: grid)
        
        let edgeStatesForFace: (Int) -> [Edge.State] = {
            result.edges(forFace: $0).map(result.edgeState(forEdge:))
        }
        // `0`
        XCTAssertEqual(edgeStatesForFace(0)[0], .disabled)
        XCTAssertEqual(edgeStatesForFace(0)[1], .disabled)
        XCTAssertEqual(edgeStatesForFace(0)[2], .disabled)
        XCTAssertEqual(edgeStatesForFace(0)[3], .disabled)
        // `1`
        XCTAssertEqual(edgeStatesForFace(1)[0], .normal)
        XCTAssertEqual(edgeStatesForFace(1)[1], .normal)
        XCTAssertEqual(edgeStatesForFace(1)[2], .normal)
        XCTAssertEqual(edgeStatesForFace(1)[3], .disabled)
        // `2`
        XCTAssertEqual(edgeStatesForFace(2)[0], .disabled)
        XCTAssertEqual(edgeStatesForFace(2)[1], .normal)
        XCTAssertEqual(edgeStatesForFace(2)[2], .normal)
        XCTAssertEqual(edgeStatesForFace(2)[3], .normal)
        // `3`
        XCTAssertEqual(edgeStatesForFace(3)[0], .normal)
        XCTAssertEqual(edgeStatesForFace(3)[1], .normal)
        XCTAssertEqual(edgeStatesForFace(3)[2], .normal)
        XCTAssertEqual(edgeStatesForFace(3)[3], .normal)
    }
}
