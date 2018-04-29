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
        let gridGen = LoopySquareGrid(width: 2, height: 2)
        gridGen.setHint(x: 1, y: 1, hint: 1)
        var grid = gridGen.generate()
        grid.edges[5].state = .marked
        
        let result = sut.apply(to: grid)
        
        // `1` face
        XCTAssertEqual(result.edgeIds(forFace: 3)[0].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 3)[1].edge(in: result).state, .disabled)
        XCTAssertEqual(result.edgeIds(forFace: 3)[2].edge(in: result).state, .disabled)
        XCTAssertEqual(result.edgeIds(forFace: 3)[3].edge(in: result).state, .disabled)
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
        let gridGen = LoopySquareGrid(width: 2, height: 3)
        gridGen.setHint(x: 1, y: 1, hint: 1)
        var grid = gridGen.generate()
        grid.edges[5].state = .marked
        grid.edges[6].state = .disabled
        
        let result = sut.apply(to: grid)
        
        // `1` face
        XCTAssertEqual(result.edgeIds(forFace: 3)[0].edge(in: result).state, .disabled)
        XCTAssertEqual(result.edgeIds(forFace: 3)[1].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 3)[2].edge(in: result).state, .disabled)
        XCTAssertEqual(result.edgeIds(forFace: 3)[3].edge(in: result).state, .disabled)
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
        let gridGen = LoopySquareGrid(width: 2, height: 3)
        gridGen.setHint(x: 1, y: 1, hint: 1)
        var grid = gridGen.generate()
        grid.edges[5].state = .marked
        grid.edges[8].state = .disabled
        grid.edges[11].state = .disabled
        grid.edges[13].state = .disabled
        
        let result = sut.apply(to: grid)
        
        // `1` face
        XCTAssertEqual(result.edgeIds(forFace: 3)[0].edge(in: result).state, .normal)
        XCTAssertEqual(result.edgeIds(forFace: 3)[1].edge(in: result).state, .disabled)
        XCTAssertEqual(result.edgeIds(forFace: 3)[2].edge(in: result).state, .disabled)
        XCTAssertEqual(result.edgeIds(forFace: 3)[3].edge(in: result).state, .disabled)
    }
}
