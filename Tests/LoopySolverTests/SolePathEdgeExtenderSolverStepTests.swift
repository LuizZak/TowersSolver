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
        let gridGen = LoopySquareGrid(width: 2, height: 2)
        let controller = LoopyGridController(grid: gridGen.generate())
        controller.setEdge(state: .disabled, forFace: 0, edgeIndex: 1)
        controller.setEdge(state: .marked, forFace: 0, edgeIndex: 3)
        
        let result = sut.apply(to: controller.grid)
        
        // Top-left
        XCTAssertEqual(result.edgeIds(forFace: 0)[0].edge(in: result).state, .marked)
        XCTAssertEqual(result.edgeIds(forFace: 0)[1].edge(in: result).state, .disabled)
        XCTAssertEqual(result.edgeIds(forFace: 0)[2].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 0)[3].edge(in: result).state, .marked)
        // Top-right
        XCTAssertEqual(result.edgeIds(forFace: 1)[0].edge(in: result).state, .marked)
        XCTAssertEqual(result.edgeIds(forFace: 1)[1].edge(in: result).state, .marked)
        XCTAssertEqual(result.edgeIds(forFace: 1)[2].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 1)[3].edge(in: result).state, .disabled)
        // Bottom-left
        XCTAssertEqual(result.edgeIds(forFace: 2)[0].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 2)[1].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 2)[2].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 2)[3].edge(in: result).state, .normal)
        // Bottom-right
        XCTAssertEqual(result.edgeIds(forFace: 3)[0].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 3)[1].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 3)[2].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 3)[3].edge(in: result).state, .normal)
    }
}
