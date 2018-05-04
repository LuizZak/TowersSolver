import XCTest
@testable import LoopySolver
import Geometry

class LoopyFieldTests: XCTestCase {
    
    static var allTests: [(String, () -> Void)] = [
        
    ]
    
    var field: LoopyField!
    var width: Int = 5
    var height: Int = 6
    
    override func setUp() {
        super.setUp()
        
        field = LoopyField()
    }
    
    func testAddVertex() {
        field.addVertex(Vertex(x: 0, y: 1))
        
        XCTAssertEqual(field.vertices.count, 1)
        XCTAssertEqual(field.vertices.first, Vertex(x: 0, y: 1))
    }
    
    func testAddFace() {
        field.addVertex(Vertex(x: 0, y: 0))
        field.addVertex(Vertex(x: 1, y: 0))
        field.addVertex(Vertex(x: 1, y: 1))
        field.addVertex(Vertex(x: 0, y: 1))
        
        let faceId = field.createFace(withVertexIndices: [0, 1, 2, 3], hint: 1)
        
        XCTAssertEqual(faceId.value, 0)
        XCTAssertEqual(field.faces.count, 1)
        XCTAssertEqual(field.hintForFace(faceId), 1)
        XCTAssertEqual(field.faces[0].localToGlobalEdges.map { $0.value }, [0, 1, 2, 3])
    }
    
    func testAddFaceCorrectlySetsupEdges() {
        field.addVertex(Vertex(x: 0, y: 0)) // 0
        field.addVertex(Vertex(x: 1, y: 0)) // 1
        field.addVertex(Vertex(x: 2, y: 0)) // 2
        field.addVertex(Vertex(x: 0, y: 1)) // 3
        field.addVertex(Vertex(x: 1, y: 1)) // 4
        field.addVertex(Vertex(x: 2, y: 1)) // 5
        
        field.createFace(withVertexIndices: [0, 1, 4, 3], hint: nil)
        field.createFace(withVertexIndices: [1, 2, 5, 4], hint: nil)
        
        XCTAssertEqual(field.edges.count, 7)
        XCTAssertEqual(field.edges[0], Edge(start: 0, end: 1))
        XCTAssertEqual(field.edges[1], Edge(start: 1, end: 4))
        XCTAssertEqual(field.edges[2], Edge(start: 4, end: 3))
        XCTAssertEqual(field.edges[3], Edge(start: 3, end: 0))
        XCTAssertEqual(field.edges[4], Edge(start: 1, end: 2))
        XCTAssertEqual(field.edges[5], Edge(start: 2, end: 5))
        XCTAssertEqual(field.edges[6], Edge(start: 4, end: 5))
    }
    
    func testAddFaceDoesntDuplicateEdges() {
        // Create two triangle faces forming a box
        field.addVertex(Vertex(x: 0, y: 0))
        field.addVertex(Vertex(x: 1, y: 0))
        field.addVertex(Vertex(x: 1, y: 1))
        field.addVertex(Vertex(x: 0, y: 1))
        field.createFace(withVertexIndices: [0, 1, 2], hint: nil)
        field.createFace(withVertexIndices: [2, 3, 0], hint: nil)
        
        XCTAssertEqual(field.edges.count, 5)
        XCTAssertEqual(field.edges[0], Edge(start: 0, end: 1))
        XCTAssertEqual(field.edges[1], Edge(start: 1, end: 2))
        XCTAssertEqual(field.edges[2], Edge(start: 2, end: 0))
        XCTAssertEqual(field.edges[3], Edge(start: 2, end: 3))
        XCTAssertEqual(field.edges[4], Edge(start: 3, end: 0))
    }
    
    func testFacesSharingVertex() {
        // Create two triangle faces forming a box
        field.addVertex(Vertex(x: 0, y: 0))
        field.addVertex(Vertex(x: 1, y: 0))
        field.addVertex(Vertex(x: 1, y: 1))
        field.addVertex(Vertex(x: 0, y: 1))
        let face1 = field.createFace(withVertexIndices: [0, 1, 2], hint: nil)
        let face2 = field.createFace(withVertexIndices: [2, 3, 0], hint: nil)
        
        XCTAssertEqual(field.facesSharing(vertexIndex: 0), [face1, face2])
        XCTAssertEqual(field.facesSharing(vertexIndex: 1), [face1])
        XCTAssertEqual(field.facesSharing(vertexIndex: 3), [face2])
        XCTAssertEqual(field.faces[0].localToGlobalEdges.map { $0.value }, [0, 1, 2])
        XCTAssertEqual(field.faces[1].localToGlobalEdges.map { $0.value }, [3, 4, 2])
    }
    
    func testIsFaceSolved() {
        field = LoopySquareGridGen(width: 2, height: 2).generate()
        field.withFace(0) { $0.hint = 2 }
        field.withFace(1) { $0.hint = 2 }
        field.withEdge(0) { $0.state = .marked }
        field.withEdge(1) { $0.state = .marked }
        
        XCTAssert(field.isFaceSolved(0))
        XCTAssertFalse(field.isFaceSolved(1))
        XCTAssert(field.isFaceSolved(2))
        XCTAssert(field.isFaceSolved(3))
    }
    
    func testEdgesConnectedTo() {
        // Create two triangle faces forming a box
        field.addVertex(Vertex(x: 0, y: 0))
        field.addVertex(Vertex(x: 1, y: 0))
        field.addVertex(Vertex(x: 1, y: 1))
        field.addVertex(Vertex(x: 0, y: 1))
        field.createFace(withVertexIndices: [0, 1, 2], hint: nil)
        field.createFace(withVertexIndices: [2, 3, 0], hint: nil)
        
        XCTAssertEqual(field.edgesConnected(to: 0), [1, 2, 4])
        XCTAssertEqual(field.edgesConnected(to: 1), [0, 2, 3])
        XCTAssertEqual(field.edgesConnected(to: 2), [1, 0, 3, 4])
        XCTAssertEqual(field.edgesConnected(to: 3), [1, 2, 4])
        XCTAssertEqual(field.edgesConnected(to: 4), [3, 0, 2])
    }
}
