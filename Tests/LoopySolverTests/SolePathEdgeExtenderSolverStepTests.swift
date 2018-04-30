import XCTest
@testable import LoopySolver

class SolePathEdgeExtenderSolverStepTests: XCTestCase {
    var sut: SolePathEdgeExtenderSolverStep!
    
    override func setUp() {
        super.setUp()
        
        sut = SolePathEdgeExtenderSolverStep()
    }
    
    func testApplyOnTrivial() {
        // Create a field with a loopy line that ends in a corner:
        //
        // .  .  .
        // !  x  .  (assuming 'x' is the mid vertical column disabled)
        // .  .  .
        //
        // Result should be a line that extends around the corner such that it
        // ends in a vertex with more than one choise of path:
        //
        // .__.__.
        // !  x  !
        // .  .  .
        //
        let gridGen = LoopySquareGridGen(width: 2, height: 2)
        let controller = LoopyFieldController(field: gridGen.generate())
        controller.setEdge(state: .disabled, forFace: 0, edgeIndex: 1)
        controller.setEdge(state: .marked, forFace: 0, edgeIndex: 3)
        
        let result = sut.apply(to: controller.field)
        
        let edgesForFace: (Int) -> [Edge] = {
            result.edgeIds(forFace: $0).edges(in: result)
        }
        // Top-left
        XCTAssertEqual(edgesForFace(0)[0].state, .marked)
        XCTAssertEqual(edgesForFace(0)[1].state, .disabled)
        XCTAssertEqual(edgesForFace(0)[2].state, .normal)
        XCTAssertEqual(edgesForFace(0)[3].state, .marked)
        // Top-right
        XCTAssertEqual(edgesForFace(1)[0].state, .marked)
        XCTAssertEqual(edgesForFace(1)[1].state, .marked)
        XCTAssertEqual(edgesForFace(1)[2].state, .normal)
        XCTAssertEqual(edgesForFace(1)[3].state, .disabled)
        // Bottom-left
        XCTAssertEqual(edgesForFace(2)[0].state, .normal)
        XCTAssertEqual(edgesForFace(2)[1].state, .normal)
        XCTAssertEqual(edgesForFace(2)[2].state, .normal)
        XCTAssertEqual(edgesForFace(2)[3].state, .normal)
        // Bottom-right
        XCTAssertEqual(edgesForFace(3)[0].state, .normal)
        XCTAssertEqual(edgesForFace(3)[1].state, .normal)
        XCTAssertEqual(edgesForFace(3)[2].state, .normal)
        XCTAssertEqual(edgesForFace(3)[3].state, .normal)
    }
}
