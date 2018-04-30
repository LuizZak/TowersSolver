import XCTest
@testable import LoopySolver

class CornerEntrySolverStepTests: XCTestCase {
    var sut: CornerEntrySolverStep!
    
    override func setUp() {
        super.setUp()
        
        sut = CornerEntrySolverStep()
    }
    
    func testApplyOnTrivial() {
        // Create a simple 2x2 square grid like so:
        // . _ . _ .
        // ! _ ! _ ║
        // ! _ ! 1 !
        //
        // Result should be a grid with the left, bottom, and right edges of the
        // `1` face all disabled.
        let gridGen = LoopySquareGridGen(width: 2, height: 2)
        gridGen.setHint(x: 1, y: 1, hint: 1)
        var field = gridGen.generate()
        field.edges[5].state = .marked
        
        let result = sut.apply(to: field)
        
        let edgesForFace: (Int) -> [Edge] = {
            result.edgeIds(forFace: $0).edges(in: result)
        }
        // `1` face
        XCTAssertEqual(edgesForFace(3)[0].state, .normal)
        XCTAssertEqual(edgesForFace(3)[1].state, .disabled)
        XCTAssertEqual(edgesForFace(3)[2].state, .disabled)
        XCTAssertEqual(edgesForFace(3)[3].state, .disabled)
    }
    
    func testApplyOnFaceWithDisabledEdge() {
        // Create a simple 2x3 square grid like so:
        // . _ . _ .
        // ! _ !   ║
        // ! _ ! 1 !
        // . _ ! _ .
        //
        // Result should be a grid with the bottom and left edges of the `1` face
        // disabled.
        let gridGen = LoopySquareGridGen(width: 2, height: 3)
        gridGen.setHint(x: 1, y: 1, hint: 1)
        var field = gridGen.generate()
        field.edges[5].state = .marked
        field.edges[6].state = .disabled
        
        let result = sut.apply(to: field)
        
        let edgesForFace: (Int) -> [Edge] = {
            result.edgeIds(forFace: $0).edges(in: result)
        }
        // `1` face
        XCTAssertEqual(edgesForFace(3)[0].state, .disabled)
        XCTAssertEqual(edgesForFace(3)[1].state, .normal)
        XCTAssertEqual(edgesForFace(3)[2].state, .disabled)
        XCTAssertEqual(edgesForFace(3)[3].state, .disabled)
    }
    
    func testApplyOnFaceWithLoopback() {
        // Create a simple 2x3 square grid like so:
        // . _ . _ .
        // ! _ ! _ ║
        // !   ! 1 !  <- bottom edge of `1` cell is disabled, as well.
        // .   ! _ !
        //
        // Result should be a grid with the bottom, left and right edges of the
        // `1` face disabled.
        let gridGen = LoopySquareGridGen(width: 2, height: 3)
        gridGen.setHint(x: 1, y: 1, hint: 1)
        var field = gridGen.generate()
        field.edges[5].state = .marked
        field.edges[8].state = .disabled
        field.edges[11].state = .disabled
        field.edges[13].state = .disabled
        
        let result = sut.apply(to: field)
        
        let edgesForFace: (Int) -> [Edge] = {
            result.edgeIds(forFace: $0).edges(in: result)
        }
        // `1` face
        XCTAssertEqual(edgesForFace(3)[0].state, .normal)
        XCTAssertEqual(edgesForFace(3)[1].state, .disabled)
        XCTAssertEqual(edgesForFace(3)[2].state, .disabled)
        XCTAssertEqual(edgesForFace(3)[3].state, .disabled)
    }
    
    func testApplyOnSemiCompleteFace() {
        // Create a simple 3x2 square grid like so:
        // . _ . _ . _ .
        // ! _ ! _ ║ _ !
        // ! _ ! 3 ! _ !
        //
        // Result should be a grid with the left and bottom edges of the `3` face
        // all marked as part of the solution, and the edge to the bottom-right
        // of the marked edge should be disabled, since the semi-complete face
        // highjacked the line path.
        let gridGen = LoopySquareGridGen(width: 3, height: 2)
        gridGen.setHint(x: 1, y: 1, hint: 3)
        var field = gridGen.generate()
        field.edges[5].state = .marked
        
        let result = sut.apply(to: field)
        
        let edgesForFace: (Int) -> [Edge] = {
            result.edgeIds(forFace: $0).edges(in: result)
        }
        
        // Top-center face
        XCTAssertEqual(edgesForFace(1)[0].state, .normal)
        XCTAssertEqual(edgesForFace(1)[1].state, .marked)
        XCTAssertEqual(edgesForFace(1)[2].state, .normal)
        XCTAssertEqual(edgesForFace(1)[3].state, .normal)
        // `3` face
        XCTAssertEqual(edgesForFace(4)[0].state, .normal)
        XCTAssertEqual(edgesForFace(4)[1].state, .normal)
        XCTAssertEqual(edgesForFace(4)[2].state, .marked)
        XCTAssertEqual(edgesForFace(4)[3].state, .marked)
        // Bottom-right face
        XCTAssertEqual(edgesForFace(5)[0].state, .disabled)
        XCTAssertEqual(edgesForFace(5)[1].state, .normal)
        XCTAssertEqual(edgesForFace(5)[2].state, .normal)
        XCTAssertEqual(edgesForFace(5)[3].state, .normal)
        
        LoopyFieldPrinter(bufferWidth: 14, bufferHeight: 5).printField(field: result)
    }
}
