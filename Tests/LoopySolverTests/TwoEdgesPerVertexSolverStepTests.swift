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
        
        // Top-left
        XCTAssertEqual(result.edgeIds(forFace: 0)[0].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 0)[1].edge(in: result).state, .marked)
        XCTAssertEqual(result.edgeIds(forFace: 0)[2].edge(in: result).state, .disabled)
        XCTAssertEqual(result.edgeIds(forFace: 0)[3].edge(in: result).state, .normal)
        // Top-right
        XCTAssertEqual(result.edgeIds(forFace: 1)[0].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 1)[1].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 1)[2].edge(in: result).state, .disabled)
        XCTAssertEqual(result.edgeIds(forFace: 1)[3].edge(in: result).state, .marked)
        // Bottom-left
        XCTAssertEqual(result.edgeIds(forFace: 2)[0].edge(in: result).state, .disabled)
        XCTAssertEqual(result.edgeIds(forFace: 2)[1].edge(in: result).state, .marked)
        XCTAssertEqual(result.edgeIds(forFace: 2)[2].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 2)[3].edge(in: result).state, .normal)
        // Bottom-right
        XCTAssertEqual(result.edgeIds(forFace: 3)[0].edge(in: result).state, .disabled)
        XCTAssertEqual(result.edgeIds(forFace: 3)[1].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 3)[2].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 3)[3].edge(in: result).state, .marked)
    }
}
