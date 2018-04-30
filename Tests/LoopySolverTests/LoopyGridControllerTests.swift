import XCTest
import LoopySolver

class LoopyGridControllerTests: XCTestCase {
    func testNonSharedEdges() {
        let grid = LoopySquareGridGen(width: 3, height: 3).generate()
        let sut = LoopyFieldController(field: grid)
        
        // Center face shares all edges with all connecting faces
        XCTAssert(sut.nonSharedEdges(forFace: 4).isEmpty)
        // Corner faces share only two edges
        XCTAssertEqual(sut.nonSharedEdges(forFace: 0), [0, 3])
        // Lateral faces share three edges with neighboring faces
        XCTAssertEqual(sut.nonSharedEdges(forFace: 1), [4])
    }
    
    func testSetEdgeStateForFaceEdgeIndex() {
        // Produce a 2x2 grid that has the all top horizontal edges of the faces
        // disabled
        //
        //  .   .   .
        //  !   !   !
        //  !___!___!
        //
        let grid = LoopySquareGridGen(width: 2, height: 2).generate()
        let sut = LoopyFieldController(field: grid)
        
        sut.setEdge(state: .disabled, forFace: 0, edgeIndex: 0)
        sut.setEdge(state: .disabled, forFace: 1, edgeIndex: 0)
        sut.setEdge(state: .disabled, forFace: 2, edgeIndex: 0)
        sut.setEdge(state: .disabled, forFace: 3, edgeIndex: 0)
        
        let edgeStates = sut.field.edges.map { $0.state }
        
        XCTAssertEqual(
            edgeStates,
            [
                // Top-left edges
                .disabled,
                .normal,
                .disabled,
                .normal,
                // Top-right edges
                .disabled,
                .normal,
                .disabled,
                // Bottom-left edges
                .normal,
                .normal,
                .normal,
                // Bottom-right
                .normal,
                .normal
            ])
    }
}
