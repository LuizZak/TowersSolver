import XCTest
@testable import LoopySolver

class TwoEdgesPerVertexSolverStepTests: XCTestCase {
    var sut: TwoEdgesPerVertexSolverStep!
    
    override func setUp() {
        super.setUp()
        
        sut = TwoEdgesPerVertexSolverStep()
    }
    
    func testApplyOnTrivial() {
        // On a 2x2 square grid, mark the two center vertical edges as part of
        // the solution.
        // The remaining edges connected to that center vertex should both be
        // disabled.
        let gridGen = LoopySquareGridGen(width: 2, height: 2)
        let controller = LoopyFieldController(field: gridGen.generate())
        controller.setEdge(state: .marked, forFace: 0, edgeIndex: 1)
        controller.setEdge(state: .marked, forFace: 2, edgeIndex: 1)
        
        let result = sut.apply(to: controller.field)
        
        let edgesForFace: (Int) -> [Edge] = {
            result.edgeIds(forFace: $0).edges(in: result)
        }
        // Top-left
        XCTAssertEqual(edgesForFace(0)[0].state, .normal)
        XCTAssertEqual(edgesForFace(0)[1].state, .marked)
        XCTAssertEqual(edgesForFace(0)[2].state, .disabled)
        XCTAssertEqual(edgesForFace(0)[3].state, .normal)
        // Top-right
        XCTAssertEqual(edgesForFace(1)[0].state, .normal)
        XCTAssertEqual(edgesForFace(1)[1].state, .normal)
        XCTAssertEqual(edgesForFace(1)[2].state, .disabled)
        XCTAssertEqual(edgesForFace(1)[3].state, .marked)
        // Bottom-left
        XCTAssertEqual(edgesForFace(2)[0].state, .disabled)
        XCTAssertEqual(edgesForFace(2)[1].state, .marked)
        XCTAssertEqual(edgesForFace(2)[2].state, .normal)
        XCTAssertEqual(edgesForFace(2)[3].state, .normal)
        // Bottom-right
        XCTAssertEqual(edgesForFace(3)[0].state, .disabled)
        XCTAssertEqual(edgesForFace(3)[1].state, .normal)
        XCTAssertEqual(edgesForFace(3)[2].state, .normal)
        XCTAssertEqual(edgesForFace(3)[3].state, .marked)
    }
}
