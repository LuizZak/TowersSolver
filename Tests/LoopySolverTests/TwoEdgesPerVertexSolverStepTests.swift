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
        
        let edgeStatesForFace: (Int) -> [Edge.State] = {
            result.edges(forFace: $0).map(result.edgeState(forEdge:))
        }
        // Top-left
        XCTAssertEqual(edgeStatesForFace(0)[0], .normal)
        XCTAssertEqual(edgeStatesForFace(0)[1], .marked)
        XCTAssertEqual(edgeStatesForFace(0)[2], .disabled)
        XCTAssertEqual(edgeStatesForFace(0)[3], .normal)
        // Top-right
        XCTAssertEqual(edgeStatesForFace(1)[0], .normal)
        XCTAssertEqual(edgeStatesForFace(1)[1], .normal)
        XCTAssertEqual(edgeStatesForFace(1)[2], .disabled)
        XCTAssertEqual(edgeStatesForFace(1)[3], .marked)
        // Bottom-left
        XCTAssertEqual(edgeStatesForFace(2)[0], .disabled)
        XCTAssertEqual(edgeStatesForFace(2)[1], .marked)
        XCTAssertEqual(edgeStatesForFace(2)[2], .normal)
        XCTAssertEqual(edgeStatesForFace(2)[3], .normal)
        // Bottom-right
        XCTAssertEqual(edgeStatesForFace(3)[0], .disabled)
        XCTAssertEqual(edgeStatesForFace(3)[1], .normal)
        XCTAssertEqual(edgeStatesForFace(3)[2], .normal)
        XCTAssertEqual(edgeStatesForFace(3)[3], .marked)
    }
}
