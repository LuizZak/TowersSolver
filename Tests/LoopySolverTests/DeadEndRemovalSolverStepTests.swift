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
        field.withEdge(0) { $0.state = .disabled }
        
        let result = sut.apply(to: field)
        
        let edgeStatesForFace: (Int) -> [Edge.State] = {
            result.edges(forFace: $0).map(result.edgeState(forEdge:))
        }
        // left square
        XCTAssertEqual(edgeStatesForFace(0)[0], .disabled)
        XCTAssertEqual(edgeStatesForFace(0)[1], .normal)
        XCTAssertEqual(edgeStatesForFace(0)[2], .disabled)
        XCTAssertEqual(edgeStatesForFace(0)[3], .disabled)
        // right square
        XCTAssertEqual(edgeStatesForFace(1)[0], .normal)
        XCTAssertEqual(edgeStatesForFace(1)[1], .normal)
        XCTAssertEqual(edgeStatesForFace(1)[2], .normal)
        XCTAssertEqual(edgeStatesForFace(1)[3], .normal)
    }
}
