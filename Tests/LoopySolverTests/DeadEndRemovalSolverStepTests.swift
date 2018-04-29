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
        let gridGen = LoopySquareGrid(width: 2, height: 1)
        var grid = gridGen.generate()
        grid.edges[0].state = .disabled
        
        let result = sut.apply(to: grid)
        
        // left square
        XCTAssertEqual(result.edgeIds(forFace: 0)[0].edge(in: result).state, .disabled)
        XCTAssertEqual(result.edgeIds(forFace: 0)[1].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 0)[2].edge(in: result).state, .disabled)
        XCTAssertEqual(result.edgeIds(forFace: 0)[3].edge(in: result).state, .disabled)
        // right square
        XCTAssertEqual(result.edgeIds(forFace: 1)[0].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 1)[1].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 1)[2].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 1)[3].edge(in: result).state, .normal)
    }
}
