import XCTest
import LoopySolver

class LoopyFieldControllerTests: XCTestCase {
    func testNonSharedEdges() {
        let field = LoopySquareGridGen(width: 3, height: 3).generate()
        let sut = LoopyFieldController(field: field)
        
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
        let field = LoopySquareGridGen(width: 2, height: 2).generate()
        let sut = LoopyFieldController(field: field)
        
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
    
    func testSemiCompleteFaces() {
        // Create a field with a given configuration:
        // ._________. _________.
        // |         | \   1   /
        // |         |   \   /
        // |    3    | 2  >.
        // |         |   /
        // !_________! /
        //
        var field = LoopyField()
        field.addVertex(Vertex(x: 0, y: 0))
        field.addVertex(Vertex(x: 1, y: 0))
        field.addVertex(Vertex(x: 1, y: 1))
        field.addVertex(Vertex(x: 0, y: 1))
        field.addVertex(Vertex(x: 3, y: 0))
        field.addVertex(Vertex(x: 2, y: 0.5))
        let f1 = field.createFace(withVertexIndices: [0, 1, 2, 3], hint: 3)
        let f2 = field.createFace(withVertexIndices: [1, 5, 2], hint: 2)
        field.createFace(withVertexIndices: [1, 4, 5], hint: 1)
        let sut = LoopyFieldController(field: field)
        
        let faces = sut.semiCompleteFaces()
        
        XCTAssertEqual(faces.count, 2)
        XCTAssert(faces.contains(f1))
        XCTAssert(faces.contains(f2))
    }
}
