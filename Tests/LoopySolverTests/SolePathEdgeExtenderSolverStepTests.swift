import XCTest
@testable import LoopySolver

class SolePathEdgeExtenderSolverStepTests: XCTestCase {
    var sut: SolePathEdgeExtenderSolverStep!
    
    override func setUp() {
        super.setUp()
        
        sut = SolePathEdgeExtenderSolverStep()
    }
    
    func testApplyOnTrivial() {
        // Create a grid with a loopy line that ends in a corner:
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
        let controller = LoopyGridController(grid: gridGen.generate())
        controller.setEdge(state: .disabled, forFace: 0, edgeIndex: 1)
        controller.setEdge(state: .marked, forFace: 0, edgeIndex: 3)
        
        let result = sut.apply(to: controller.grid)
        
        let edgeStatesForFace: (Int) -> [Edge.State] = {
            result.edges(forFace: $0).map(result.edgeState(forEdge:))
        }
        // Top-left
        XCTAssertEqual(edgeStatesForFace(0)[0], .marked)
        XCTAssertEqual(edgeStatesForFace(0)[1], .disabled)
        XCTAssertEqual(edgeStatesForFace(0)[2], .normal)
        XCTAssertEqual(edgeStatesForFace(0)[3], .marked)
        // Top-right
        XCTAssertEqual(edgeStatesForFace(1)[0], .marked)
        XCTAssertEqual(edgeStatesForFace(1)[1], .marked)
        XCTAssertEqual(edgeStatesForFace(1)[2], .normal)
        XCTAssertEqual(edgeStatesForFace(1)[3], .disabled)
        // Bottom-left
        XCTAssertEqual(edgeStatesForFace(2)[0], .normal)
        XCTAssertEqual(edgeStatesForFace(2)[1], .normal)
        XCTAssertEqual(edgeStatesForFace(2)[2], .normal)
        XCTAssertEqual(edgeStatesForFace(2)[3], .normal)
        // Bottom-right
        XCTAssertEqual(edgeStatesForFace(3)[0], .normal)
        XCTAssertEqual(edgeStatesForFace(3)[1], .normal)
        XCTAssertEqual(edgeStatesForFace(3)[2], .normal)
        XCTAssertEqual(edgeStatesForFace(3)[3], .normal)
    }
}
