import XCTest
@testable import LoopySolver

class DeadEndRemovalSolverStepTests: XCTestCase {
    var sut: DeadEndRemovalSolverStep!
    
    override func setUp() {
        super.setUp()
        
        sut = DeadEndRemovalSolverStep()
    }
    
    func testApplyOnTrivial() {
        // Create a simple 2x2 square grid like so:
        //  .  .__.
        //  !__!__!
        //
        // Result should be a grid with the left and bottom-left edges disabled:
        //  .  .__.
        //  .  !__!
        //
        let gridGen = LoopySquareGridGen(width: 2, height: 1)
        var field = gridGen.generate()
        field.edges[0].state = .disabled
        
        let result = sut.apply(to: field)
        
        let edgesForFace: (Int) -> [Edge] = {
            result.edgeIds(forFace: $0).edges(in: result)
        }
        // left square
        XCTAssertEqual(edgesForFace(0)[0].state, .disabled)
        XCTAssertEqual(edgesForFace(0)[1].state, .normal)
        XCTAssertEqual(edgesForFace(0)[2].state, .disabled)
        XCTAssertEqual(edgesForFace(0)[3].state, .disabled)
        // right square
        XCTAssertEqual(edgesForFace(1)[0].state, .normal)
        XCTAssertEqual(edgesForFace(1)[1].state, .normal)
        XCTAssertEqual(edgesForFace(1)[2].state, .normal)
        XCTAssertEqual(edgesForFace(1)[3].state, .normal)
    }
}
