import XCTest
import Geometry
import LoopySolver

class GraphUtilsTests: XCTestCase {
    func testSinglePathEdgesInGraphFromEdge() {
        // Create a graph that looks roughly like this:
        //  .__.
        //  !__!__.
        //  !
        //
        var graph = LoopyGrid()
        graph.addVertex(Vertex(x: 0, y: 0)) // 0
        graph.addVertex(Vertex(x: 1, y: 0)) // 1
        graph.addVertex(Vertex(x: 1, y: 1)) // 2
        graph.addVertex(Vertex(x: 1, y: 0)) // 3
        graph.addVertex(Vertex(x: 2, y: 1)) // 4
        graph.addVertex(Vertex(x: 0, y: 2)) // 5
        graph.createEdge(from: 0, to: 1)
        graph.createEdge(from: 1, to: 2)
        graph.createEdge(from: 2, to: 3)
        graph.createEdge(from: 3, to: 0)
        graph.createEdge(from: 2, to: 4)
        graph.createEdge(from: 3, to: 5)
        
        // Test the top-most horizontal edge
        let result1 = GraphUtils.singlePathEdges(in: graph, fromEdge: Edge(start: 0, end: 1))
        XCTAssertEqual(result1.count, 3)
        XCTAssert(result1.contains(Edge(start: 0, end: 1)))
        XCTAssert(result1.contains(Edge(start: 1, end: 2)))
        XCTAssert(result1.contains(Edge(start: 3, end: 0)))
        
        // Test the central horizontal edge
        let result2 = GraphUtils.singlePathEdges(in: graph, fromEdge: Edge(start: 2, end: 3))
        XCTAssertEqual(result2.count, 1)
        XCTAssert(result2.contains(Edge(start: 2, end: 3)))
    }
    
    func testSinglePathEdgesInGraphFromEdgeExcludingDisabledEdges() {
        // Create a graph that looks roughly like this:
        //  .__.
        //  !__!__.
        //  !  ^ this vertical edge is disabled.
        //
        var graph = LoopyGrid()
        graph.addVertex(Vertex(x: 0, y: 0)) // 0
        graph.addVertex(Vertex(x: 1, y: 0)) // 1
        graph.addVertex(Vertex(x: 1, y: 1)) // 2
        graph.addVertex(Vertex(x: 1, y: 0)) // 3
        graph.addVertex(Vertex(x: 2, y: 1)) // 4
        graph.addVertex(Vertex(x: 0, y: 2)) // 5
        graph.createEdge(from: 0, to: 1)
        graph.createEdge(from: 1, to: 2)
        graph.createEdge(from: 2, to: 3)
        graph.createEdge(from: 3, to: 0)
        graph.createEdge(from: 2, to: 4)
        graph.createEdge(from: 3, to: 5)
        graph.edges[1].state = .disabled
        
        // Test top-most vertical edge
        let result1 = GraphUtils.singlePathEdges(in: graph,
                                                 fromEdge: Edge(start: 0, end: 1),
                                                 excludeDisabled: true)
        XCTAssertEqual(result1.count, 2)
        XCTAssert(result1.contains(Edge(start: 0, end: 1)))
        XCTAssert(result1.contains(Edge(start: 3, end: 0)))
        
        let result2 = GraphUtils.singlePathEdges(in: graph,
                                                 fromEdge: Edge(start: 0, end: 1),
                                                 excludeDisabled: false)
        XCTAssertEqual(result2.count, 3)
        XCTAssert(result2.contains(Edge(start: 0, end: 1)))
        XCTAssert(result2.contains(Edge(start: 1, end: 2, state: .disabled)))
        XCTAssert(result2.contains(Edge(start: 3, end: 0)))
        
        // Test right-most horizontal edge
        let result3 = GraphUtils.singlePathEdges(in: graph,
                                                 fromEdge: Edge(start: 2, end: 4),
                                                 excludeDisabled: true)
        XCTAssertEqual(result3.count, 2)
        XCTAssert(result3.contains(Edge(start: 2, end: 4)))
        XCTAssert(result3.contains(Edge(start: 2, end: 3)))
        
        let result4 = GraphUtils.singlePathEdges(in: graph,
                                                 fromEdge: Edge(start: 2, end: 4),
                                                 excludeDisabled: false)
        XCTAssertEqual(result4.count, 1)
        XCTAssert(result3.contains(Edge(start: 2, end: 4)))
    }
}
