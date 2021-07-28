import XCTest
@testable import LoopySolver

class ExactEdgeCountSolverStepTests: XCTestCase {
    var sut: ExactEdgeCountSolverStep!
    var delegate: SolverStepDelegate!
    
    override func setUp() {
        super.setUp()
        
        sut = ExactEdgeCountSolverStep()
        delegate = TestSolverStepDelegate()
    }
    
    func testIsEphemeral() {
        XCTAssertFalse(sut.isEphemeral)
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
        grid.withEdge(0) { $0.state = .disabled }
        grid.withEdge(3) { $0.state = .disabled }
        
        let result = sut.apply(to: grid, delegate)
        
        let edgeStatesForFace: (Int) -> [Edge.State] = {
            result.edges(forFace: $0).map(result.edgeState(forEdge:))
        }
        // left square
        XCTAssertEqual(edgeStatesForFace(0)[0], .disabled)
        XCTAssertEqual(edgeStatesForFace(0)[1], .marked)
        XCTAssertEqual(edgeStatesForFace(0)[2], .marked)
        XCTAssertEqual(edgeStatesForFace(0)[3], .disabled)
        // right square
        XCTAssertEqual(edgeStatesForFace(1)[0], .normal)
        XCTAssertEqual(edgeStatesForFace(1)[1], .normal)
        XCTAssertEqual(edgeStatesForFace(1)[2], .normal)
        XCTAssertEqual(edgeStatesForFace(1)[3], .marked)
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
        grid.withEdge(4) { $0.state = .marked }
        grid.withEdge(5) { $0.state = .marked }
        grid.withEdge(6) { $0.state = .marked }
        
        let result = sut.apply(to: grid, delegate)
        
        let edgeStatesForFace: (Int) -> [Edge.State] = {
            result.edges(forFace: $0).map(result.edgeState(forEdge:))
        }
        // left square
        XCTAssertEqual(edgeStatesForFace(0)[0], .normal)
        XCTAssertEqual(edgeStatesForFace(0)[1], .disabled)
        XCTAssertEqual(edgeStatesForFace(0)[2], .normal)
        XCTAssertEqual(edgeStatesForFace(0)[3], .normal)
        // right square
        XCTAssertEqual(edgeStatesForFace(1)[0], .marked)
        XCTAssertEqual(edgeStatesForFace(1)[1], .marked)
        XCTAssertEqual(edgeStatesForFace(1)[2], .marked)
        XCTAssertEqual(edgeStatesForFace(1)[3], .disabled)
    }
    
    func testApplyOnSemiMarkedEdges() {
        // Create a simple 2x2 square grid with marked edges like so:
        //  .   .___.
        //  . 2 ._3_! <- this right-most edge is marked
        //
        // Result should be a grid with the left-most edge of the `3` cell disabled.
        let gridGen = LoopySquareGridGen(width: 2, height: 1)
        gridGen.setHint(x: 0, y: 0, hint: 2)
        gridGen.setHint(x: 1, y: 0, hint: 3)
        var grid = gridGen.generate()
        grid.withEdge(1) { $0.state = .disabled }
        grid.withEdge(5) { $0.state = .marked }
        
        let result = sut.apply(to: grid, delegate)
        
        let edgeStatesForFace: (Int) -> [Edge.State] = {
            result.edges(forFace: $0).map(result.edgeState(forEdge:))
        }
        // left square
        XCTAssertEqual(edgeStatesForFace(0)[0], .normal)
        XCTAssertEqual(edgeStatesForFace(0)[1], .disabled)
        XCTAssertEqual(edgeStatesForFace(0)[2], .normal)
        XCTAssertEqual(edgeStatesForFace(0)[3], .normal)
        // right square
        XCTAssertEqual(edgeStatesForFace(1)[0], .marked)
        XCTAssertEqual(edgeStatesForFace(1)[1], .marked)
        XCTAssertEqual(edgeStatesForFace(1)[2], .marked)
        XCTAssertEqual(edgeStatesForFace(1)[3], .disabled)
    }
}
