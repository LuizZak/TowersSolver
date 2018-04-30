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
        var grid = gridGen.generate()
        grid.edges[0].state = .disabled
        grid.edges[3].state = .disabled
        
        let result = sut.apply(to: grid)
        
        // left square
        XCTAssertEqual(result.edgeIds(forFace: 0)[0].edge(in: result).state, .disabled)
        XCTAssertEqual(result.edgeIds(forFace: 0)[1].edge(in: result).state, .marked)
        XCTAssertEqual(result.edgeIds(forFace: 0)[2].edge(in: result).state, .marked)
        XCTAssertEqual(result.edgeIds(forFace: 0)[3].edge(in: result).state, .disabled)
        // right square
        XCTAssertEqual(result.edgeIds(forFace: 1)[0].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 1)[1].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 1)[2].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 1)[3].edge(in: result).state, .marked)
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
        var grid = gridGen.generate()
        grid.edges[4].state = .marked
        grid.edges[5].state = .marked
        grid.edges[6].state = .marked
        
        let result = sut.apply(to: grid)
        
        // left square
        XCTAssertEqual(result.edgeIds(forFace: 0)[0].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 0)[1].edge(in: result).state, .disabled)
        XCTAssertEqual(result.edgeIds(forFace: 0)[2].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 0)[3].edge(in: result).state, .normal)
        // right square
        XCTAssertEqual(result.edgeIds(forFace: 1)[0].edge(in: result).state, .marked)
        XCTAssertEqual(result.edgeIds(forFace: 1)[1].edge(in: result).state, .marked)
        XCTAssertEqual(result.edgeIds(forFace: 1)[2].edge(in: result).state, .marked)
        XCTAssertEqual(result.edgeIds(forFace: 1)[3].edge(in: result).state, .disabled)
    }
}
