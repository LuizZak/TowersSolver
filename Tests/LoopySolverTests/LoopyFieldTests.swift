import XCTest
@testable import LoopySolver
import Geometry

class LoopyFieldTests: XCTestCase {
    
    static var allTests: [(String, () -> Void)] = [
        
    ]
    
    var grid: LoopyGrid!
    var width: Int = 5
    var height: Int = 6
    
    override func setUp() {
        super.setUp()
        
        grid = LoopyGrid()
    }
    
    func testAddVertex() {
        grid.addVertex(Vertex(x: 0, y: 1))
        
        XCTAssertEqual(grid.vertices.count, 1)
        XCTAssertEqual(grid.vertices.first, Vertex(x: 0, y: 1))
    }
    
    func testVertexIndex() {
        grid.addVertex(Vertex(x: 0, y: 1))
        
        XCTAssertEqual(grid.vertexIndex(x: 0, y: 1), 0)
        XCTAssertNil(grid.vertexIndex(x: 1, y: 1))
    }
    
    func testAddFace() {
        grid.addVertex(Vertex(x: 0, y: 0))
        grid.addVertex(Vertex(x: 1, y: 0))
        grid.addVertex(Vertex(x: 1, y: 1))
        grid.addVertex(Vertex(x: 0, y: 1))
        
        let faceId = grid.createFace(withVertexIndices: [0, 1, 2, 3], hint: 1)
        
        XCTAssertEqual(faceId.value, 0)
        XCTAssertEqual(grid.faces.count, 1)
        XCTAssertEqual(grid.hintForFace(faceId), 1)
        XCTAssertEqual(grid.faces[0].localToGlobalEdges.map { $0.value }, [0, 1, 2, 3])
    }
    
    func testAddFaceCorrectlySetsupEdges() {
        grid.addVertex(Vertex(x: 0, y: 0)) // 0
        grid.addVertex(Vertex(x: 1, y: 0)) // 1
        grid.addVertex(Vertex(x: 2, y: 0)) // 2
        grid.addVertex(Vertex(x: 0, y: 1)) // 3
        grid.addVertex(Vertex(x: 1, y: 1)) // 4
        grid.addVertex(Vertex(x: 2, y: 1)) // 5
        
        grid.createFace(withVertexIndices: [0, 1, 4, 3], hint: nil)
        grid.createFace(withVertexIndices: [1, 2, 5, 4], hint: nil)
        
        XCTAssertEqual(grid.edges.count, 7)
        XCTAssertEqual(grid.edges[0], Edge(start: 0, end: 1))
        XCTAssertEqual(grid.edges[1], Edge(start: 1, end: 4))
        XCTAssertEqual(grid.edges[2], Edge(start: 4, end: 3))
        XCTAssertEqual(grid.edges[3], Edge(start: 3, end: 0))
        XCTAssertEqual(grid.edges[4], Edge(start: 1, end: 2))
        XCTAssertEqual(grid.edges[5], Edge(start: 2, end: 5))
        XCTAssertEqual(grid.edges[6], Edge(start: 4, end: 5))
    }
    
    func testAddFaceDoesntDuplicateEdges() {
        // Create two triangle faces forming a box
        grid.addVertex(Vertex(x: 0, y: 0))
        grid.addVertex(Vertex(x: 1, y: 0))
        grid.addVertex(Vertex(x: 1, y: 1))
        grid.addVertex(Vertex(x: 0, y: 1))
        grid.createFace(withVertexIndices: [0, 1, 2], hint: nil)
        grid.createFace(withVertexIndices: [2, 3, 0], hint: nil)
        
        XCTAssertEqual(grid.edges.count, 5)
        XCTAssertEqual(grid.edges[0], Edge(start: 0, end: 1))
        XCTAssertEqual(grid.edges[1], Edge(start: 1, end: 2))
        XCTAssertEqual(grid.edges[2], Edge(start: 2, end: 0))
        XCTAssertEqual(grid.edges[3], Edge(start: 2, end: 3))
        XCTAssertEqual(grid.edges[4], Edge(start: 3, end: 0))
    }
    
    func testFacesSharingVertex() {
        // Create two triangle faces forming a box
        grid.addVertex(Vertex(x: 0, y: 0))
        grid.addVertex(Vertex(x: 1, y: 0))
        grid.addVertex(Vertex(x: 1, y: 1))
        grid.addVertex(Vertex(x: 0, y: 1))
        let face1 = grid.createFace(withVertexIndices: [0, 1, 2], hint: nil)
        let face2 = grid.createFace(withVertexIndices: [2, 3, 0], hint: nil)
        
        XCTAssertEqual(grid.facesSharing(vertexIndex: 0), [face1, face2])
        XCTAssertEqual(grid.facesSharing(vertexIndex: 1), [face1])
        XCTAssertEqual(grid.facesSharing(vertexIndex: 3), [face2])
        XCTAssertEqual(grid.faces[0].localToGlobalEdges.map { $0.value }, [0, 1, 2])
        XCTAssertEqual(grid.faces[1].localToGlobalEdges.map { $0.value }, [3, 4, 2])
    }
    
    func testIsFaceSolved() {
        grid = LoopySquareGridGen(width: 2, height: 2).generate()
        grid.withFace(0) { $0.hint = 2 }
        grid.withFace(1) { $0.hint = 2 }
        grid.withEdge(0) { $0.state = .marked }
        grid.withEdge(1) { $0.state = .marked }
        
        XCTAssert(grid.isFaceSolved(0))
        XCTAssertFalse(grid.isFaceSolved(1))
        XCTAssert(grid.isFaceSolved(2))
        XCTAssert(grid.isFaceSolved(3))
    }
    
    func testEdgesConnectedTo() {
        // Create two triangle faces forming a box
        grid.addVertex(Vertex(x: 0, y: 0))
        grid.addVertex(Vertex(x: 1, y: 0))
        grid.addVertex(Vertex(x: 1, y: 1))
        grid.addVertex(Vertex(x: 0, y: 1))
        grid.createFace(withVertexIndices: [0, 1, 2], hint: nil)
        grid.createFace(withVertexIndices: [2, 3, 0], hint: nil)
        
        XCTAssertEqual(grid.edgesConnected(to: 0), [1, 2, 4])
        XCTAssertEqual(grid.edgesConnected(to: 1), [0, 2, 3])
        XCTAssertEqual(grid.edgesConnected(to: 2), [1, 0, 3, 4])
        XCTAssertEqual(grid.edgesConnected(to: 3), [1, 2, 4])
        XCTAssertEqual(grid.edgesConnected(to: 4), [3, 0, 2])
    }
}
