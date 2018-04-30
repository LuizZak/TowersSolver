import XCTest
@testable import LoopySolver

class ExactEdgeCountSolverStepTests: XCTestCase {
    var sut: ExactEdgeCountSolverStep!
    
    override func setUp() {
        super.setUp()
        
        sut = ExactEdgeCountSolverStep()
    }
    
    func testApplyOnTrivial() {
        // Create a simple 2x2 square grid like so:
        //  .   .___.
        //  ._2_!_3_!
        //
        // Result should be a grid with the center and bottom-left edges marked.
        let gridGen = LoopySquareGridGen(width: 2, height: 1)
        gridGen.setHint(x: 0, y: 0, hint: 2)
        gridGen.setHint(x: 1, y: 0, hint: 3)
        var field = gridGen.generate()
        field.edges[0].state = .disabled
        field.edges[3].state = .disabled
        
        let result = sut.apply(to: field)
        
        let edgesForFace: (Int) -> [Edge] = {
            result.edgeIds(forFace: $0).edges(in: result)
        }
        // left square
        XCTAssertEqual(edgesForFace(0)[0].state, .disabled)
        XCTAssertEqual(edgesForFace(0)[1].state, .marked)
        XCTAssertEqual(edgesForFace(0)[2].state, .marked)
        XCTAssertEqual(edgesForFace(0)[3].state, .disabled)
        // right square
        XCTAssertEqual(edgesForFace(1)[0].state, .normal)
        XCTAssertEqual(edgesForFace(1)[1].state, .normal)
        XCTAssertEqual(edgesForFace(1)[2].state, .normal)
        XCTAssertEqual(edgesForFace(1)[3].state, .marked)
    }
    
    func testApplyOnMarkedEdges() {
        // Create a simple 2x2 square grid with marked edges like so:
        //  .   .___.
        //  . 2 !_3_!
        //
        // Result should be a grid with the left-most edge of the `3` cell disabled.
        let gridGen = LoopySquareGridGen(width: 2, height: 1)
        gridGen.setHint(x: 0, y: 0, hint: 2)
        gridGen.setHint(x: 1, y: 0, hint: 3)
        var field = gridGen.generate()
        field.edges[4].state = .marked
        field.edges[5].state = .marked
        field.edges[6].state = .marked
        
        let result = sut.apply(to: field)
        
        let edgesForFace: (Int) -> [Edge] = {
            result.edgeIds(forFace: $0).edges(in: result)
        }
        // left square
        XCTAssertEqual(edgesForFace(0)[0].state, .normal)
        XCTAssertEqual(edgesForFace(0)[1].state, .disabled)
        XCTAssertEqual(edgesForFace(0)[2].state, .normal)
        XCTAssertEqual(edgesForFace(0)[3].state, .normal)
        // right square
        XCTAssertEqual(edgesForFace(1)[0].state, .marked)
        XCTAssertEqual(edgesForFace(1)[1].state, .marked)
        XCTAssertEqual(edgesForFace(1)[2].state, .marked)
        XCTAssertEqual(edgesForFace(1)[3].state, .disabled)
    }
}
