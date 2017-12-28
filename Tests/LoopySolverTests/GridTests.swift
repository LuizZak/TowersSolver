//
//  LoopySolverTests.swift
//  TowersSolver
//
//  Created by Luiz Fernando Silva on 26/12/17.
//

import XCTest
@testable import LoopySolver

class GridTests: XCTestCase {
    
    static var allTests = [
        ("testGridHorizontalInitialState", testGridHorizontalInitialState),
        ("testGridVerticalInitialState", testGridVerticalInitialState),
        ("testGridEdgeHintsInitialState", testGridEdgeHintsInitialState),
        ("testHintForCell", testHintForCell),
        ("testSetHintForCell", testSetHintForCell),
        ("testSetHints", testSetHints),
        ("testCellAt", testCellAt),
        ("testCellAtAfterSetHint", testCellAtAfterSetHint),
        ("testEdgesOfCell", testEdgesOfCell),
        ("testSetEdgeValueTop", testSetEdgeValueTop),
        ("testSetEdgeValueBottom", testSetEdgeValueBottom),
        ("testSetEdgeValueLeft", testSetEdgeValueLeft),
        ("testSetEdgeValueRight", testSetEdgeValueRight),
        ("testSetEdgeValueBottomRightCorner", testSetEdgeValueBottomRightCorner),
        ("testNormalizeTopEdge", testNormalizeTopEdge),
        ("testNormalizeRightEdge", testNormalizeRightEdge),
        ("testNormalizeBottomEdge", testNormalizeBottomEdge),
        ("testNormalizeLeftEdge", testNormalizeLeftEdge),
        ("testNormalizeRightEdgeOnRightmostCell", testNormalizeRightEdgeOnRightmostCell),
        ("testNormalizeBottomEdgeOnBottommostCell", testNormalizeBottomEdgeOnBottommostCell),
        ("testIsNormalized", testIsNormalized),
        ("testEdgeEquatable", testEdgeEquatable),
        ("testEdgeEquatableNormalized", testEdgeEquatableNormalized),
        ("testEdgeHashable", testEdgeHashable),
        ("testEdgeHashableNormalized", testEdgeHashableNormalized)
    ]
    
    var grid: Grid!
    var width: Int = 5
    var height: Int = 6
    
    override func setUp() {
        super.setUp()
        
        grid = Grid(width: width, height: height)
    }
    
    func testGridHorizontalInitialState() {
        XCTAssertEqual(height + 1, grid.horizontalEdges.count)
        XCTAssert(grid.horizontalEdges.flatMap { $0 }.all { $0 == .normal })
    }
    
    func testGridVerticalInitialState() {
        XCTAssertEqual(width + 1, grid.verticalEdges.count)
        XCTAssert(grid.verticalEdges.flatMap { $0 }.all { $0 == .normal })
    }
    
    func testGridEdgeHintsInitialState() {
        // Total count
        XCTAssertEqual(width * height, grid.edgesHints.flatMap { $0 }.count)
        
        // Height/width count
        XCTAssertEqual(height, grid.edgesHints.count)
        XCTAssert(grid.edgesHints.all { $0.count == width })
        
        // They all start as nil
        XCTAssert(grid.edgesHints.flatMap { $0 }.all { $0 == nil })
    }
    
    func testHintForCell() {
        let hint = grid.hintForCell(atX: 0, y: 0)
        
        XCTAssertEqual(hint, nil)
    }
    
    func testSetHintForCell() {
        let hint = 1
        grid.setHint(hint, forCellAtX: 0, y: 0)
        
        XCTAssertEqual(hint, grid.hintForCell(atX: 0, y: 0))
    }
    
    func testSetHints() {
        let n: Int? = nil
        grid.setHints([
                n, n, 1, n, n,
                n, n, 1, n, n,
                n, n, 1, n, n,
                n, n, 1, n, n,
                n, n, 1, n, n,
                n, n, 1, n, n
            ])
        
        XCTAssertNil(grid.hintForCell(atX: 0, y: 0))
        XCTAssertEqual(1, grid.hintForCell(atX: 2, y: 0))
        XCTAssertEqual(1, grid.hintForCell(atX: 2, y: 1))
        XCTAssertEqual(1, grid.hintForCell(atX: 2, y: 2))
        XCTAssertEqual(1, grid.hintForCell(atX: 2, y: 3))
        XCTAssertEqual(1, grid.hintForCell(atX: 2, y: 4))
        XCTAssertEqual(1, grid.hintForCell(atX: 2, y: 5))
    }
    
    func testCellAt() {
        let cell = grid.cell(atX: 0, y: 0)
        
        XCTAssertEqual(cell.hint, nil)
        XCTAssertEqual(cell.topEdge, .normal)
        XCTAssertEqual(cell.rightEdge, .normal)
        XCTAssertEqual(cell.bottomEdge, .normal)
        XCTAssertEqual(cell.leftEdge, .normal)
    }
    
    func testCellAtAfterSetHint() {
        let hint = 1
        grid.setHint(hint, forCellAtX: 0, y: 0)
        let cell = grid.cell(atX: 0, y: 0)
        
        XCTAssertEqual(cell.hint, 1)
        XCTAssertEqual(cell.topEdge, .normal)
        XCTAssertEqual(cell.rightEdge, .normal)
        XCTAssertEqual(cell.bottomEdge, .normal)
        XCTAssertEqual(cell.leftEdge, .normal)
    }
    
    func testEdgesOfCell() {
        let edges = grid.edgesOfCell(x: 0, y: 0)
        
        XCTAssertEqual(edges.top, .normal)
        XCTAssertEqual(edges.right, .normal)
        XCTAssertEqual(edges.bottom, .normal)
        XCTAssertEqual(edges.left, .normal)
    }
    
    func testSetEdgeValueTop() {
        let edge = EdgeState.marked
        
        grid.setEdgeValue(edge, onEdgeCardinal: .top, forCellAtX: 0, y: 0)
        
        XCTAssertEqual(edge, grid.horizontalEdges[0][0])
    }
    
    func testSetEdgeValueBottom() {
        let edge = EdgeState.marked
        
        grid.setEdgeValue(edge, onEdgeCardinal: .bottom, forCellAtX: 0, y: 0)
        
        XCTAssertEqual(edge, grid.horizontalEdges[1][0])
    }
    
    func testSetEdgeValueLeft() {
        let edge = EdgeState.marked
        
        grid.setEdgeValue(edge, onEdgeCardinal: .left, forCellAtX: 0, y: 0)
        
        XCTAssertEqual(edge, grid.verticalEdges[0][0])
    }
    
    func testSetEdgeValueRight() {
        let edge = EdgeState.marked
        
        grid.setEdgeValue(edge, onEdgeCardinal: .right, forCellAtX: 0, y: 0)
        
        XCTAssertEqual(edge, grid.verticalEdges[1][0])
    }
    
    func testSetEdgeValueBottomRightCorner() {
        let edge = EdgeState.marked
        
        grid.setEdgeValue(edge, onEdgeCardinal: .right,
                          forCellAtX: width - 1, y: height - 1)
        grid.setEdgeValue(edge, onEdgeCardinal: .bottom,
                          forCellAtX: width - 1, y: height - 1)
        
        XCTAssertEqual(edge, grid.horizontalEdges[height][width - 1])
        XCTAssertEqual(edge, grid.verticalEdges[width][height - 1])
    }
    
    func testNormalizeTopEdge() {
        let edge = Edge(x: 0, y: 0, cardinal: .top)
        let normalized = edge.normalized(onGridWidth: 1, height: 1)
        
        XCTAssertEqual(normalized.x, 0)
        XCTAssertEqual(normalized.y, 0)
        XCTAssertEqual(normalized.cardinal, .top)
    }
    
    func testNormalizeRightEdge() {
        let edge = Edge(x: 0, y: 0, cardinal: .right)
        let normalized = edge.normalized(onGridWidth: 1, height: 1)
        
        XCTAssertEqual(normalized.x, 1)
        XCTAssertEqual(normalized.y, 0)
        XCTAssertEqual(normalized.cardinal, .left)
    }
    
    func testNormalizeBottomEdge() {
        let edge = Edge(x: 0, y: 0, cardinal: .bottom)
        let normalized = edge.normalized(onGridWidth: 1, height: 1)
        
        XCTAssertEqual(normalized.x, 0)
        XCTAssertEqual(normalized.y, 1)
        XCTAssertEqual(normalized.cardinal, .top)
    }
    
    func testNormalizeLeftEdge() {
        let edge = Edge(x: 0, y: 0, cardinal: .left)
        let normalized = edge.normalized(onGridWidth: 1, height: 1)
        
        XCTAssertEqual(normalized.x, 0)
        XCTAssertEqual(normalized.y, 0)
        XCTAssertEqual(normalized.cardinal, .left)
    }
    
    func testNormalizeRightEdgeOnRightmostCell() {
        let edge = Edge(x: 1, y: 0, cardinal: .right)
        let normalized = edge.normalized(onGridWidth: 1, height: 1)
        
        XCTAssertEqual(normalized.x, 1)
        XCTAssertEqual(normalized.y, 0)
        XCTAssertEqual(normalized.cardinal, .right)
    }
    
    func testNormalizeBottomEdgeOnBottommostCell() {
        let edge = Edge(x: 0, y: 1, cardinal: .bottom)
        let normalized = edge.normalized(onGridWidth: 1, height: 1)
        
        XCTAssertEqual(normalized.x, 0)
        XCTAssertEqual(normalized.y, 1)
        XCTAssertEqual(normalized.cardinal, .bottom)
    }
    
    func testIsNormalized() {
        let gridWidth = 1
        let gridHeight = 1
        
        XCTAssert(Edge(x: 0, y: 0, cardinal: .top).isNormalized(onGridWidth: gridWidth, height: gridHeight))
        XCTAssert(Edge(x: 0, y: 0, cardinal: .left).isNormalized(onGridWidth: gridWidth, height: gridHeight))
        
        XCTAssertFalse(Edge(x: 0, y: 0, cardinal: .right).isNormalized(onGridWidth: gridWidth, height: gridHeight))
        XCTAssertFalse(Edge(x: 0, y: 0, cardinal: .bottom).isNormalized(onGridWidth: gridWidth, height: gridHeight))
        
        XCTAssert(Edge(x: gridWidth, y: gridHeight, cardinal: .right).isNormalized(onGridWidth: gridWidth, height: gridHeight))
        XCTAssert(Edge(x: gridWidth, y: gridHeight, cardinal: .bottom).isNormalized(onGridWidth: gridWidth, height: gridHeight))
    }
    
    func testEdgeEquatable() {
        let edge1 = Edge(x: 0, y: 1, cardinal: .bottom)
        let edge2 = Edge(x: 0, y: 1, cardinal: .bottom)
        let edge3 = Edge(x: 0, y: 0, cardinal: .right)
        let edge4 = Edge(x: 0, y: 0, cardinal: .left)
        
        XCTAssertEqual(edge1, edge2)
        XCTAssertNotEqual(edge2, edge3)
        XCTAssertNotEqual(edge3, edge4)
    }
    
    func testEdgeEquatableNormalized() {
        let edge1 = Edge(x: 0, y: 0, cardinal: .right)
        let edge2 = Edge(x: 1, y: 0, cardinal: .left)
        
        let edge3 = Edge(x: 0, y: 0, cardinal: .bottom)
        let edge4 = Edge(x: 0, y: 1, cardinal: .top)
        
        XCTAssertEqual(edge1, edge2)
        XCTAssertEqual(edge3, edge4)
    }
    
    func testEdgeHashable() {
        let edge1 = Edge(x: 0, y: 1, cardinal: .bottom)
        let edge2 = Edge(x: 0, y: 1, cardinal: .bottom)
        let edge3 = Edge(x: 0, y: 0, cardinal: .right)
        let edge4 = Edge(x: 0, y: 0, cardinal: .left)
        
        XCTAssertEqual(edge1.hashValue, edge2.hashValue)
        XCTAssertNotEqual(edge2.hashValue, edge3.hashValue)
        XCTAssertNotEqual(edge3.hashValue, edge4.hashValue)
    }
    
    func testEdgeHashableNormalized() {
        let edge1 = Edge(x: 0, y: 0, cardinal: .right)
        let edge2 = Edge(x: 1, y: 0, cardinal: .left)
        
        let edge3 = Edge(x: 0, y: 0, cardinal: .bottom)
        let edge4 = Edge(x: 0, y: 1, cardinal: .top)
        
        XCTAssertEqual(edge1.hashValue, edge2.hashValue)
        XCTAssertEqual(edge3.hashValue, edge4.hashValue)
    }
    
    func testVerticesForCell() {
        let vertices = grid.verticesFor(cellAtX: 0, y: 0)
        
        XCTAssertEqual(vertices[0], Vertex(x: 0, y: 0))
        XCTAssertEqual(vertices[1], Vertex(x: 1, y: 0))
        XCTAssertEqual(vertices[2], Vertex(x: 1, y: 1))
        XCTAssertEqual(vertices[3], Vertex(x: 0, y: 1))
    }
    
    func testCellsSharingVertex() {
        let cells = grid.cellsSharing(vertex: Vertex(x: 1, y: 1))
        
        XCTAssertEqual(cells[0], grid.cell(atX: 0, y: 0))
        XCTAssertEqual(cells[1], grid.cell(atX: 1, y: 0))
        XCTAssertEqual(cells[2], grid.cell(atX: 1, y: 1))
        XCTAssertEqual(cells[3], grid.cell(atX: 0, y: 1))
    }
    
    /*
    func testEdgesForVertex() {
        let edges = grid.edgesForVertex(Vertex(x: 1, y: 1))
        
        XCTAssertEqual(edges[0], Edge(x: 1, y: 0, cardinal: .left))
        XCTAssertEqual(edges[1], Edge(x: 1, y: 1, cardinal: .top))
        XCTAssertEqual(edges[2], Edge(x: 1, y: 2, cardinal: .left))
        XCTAssertEqual(edges[3], Edge(x: 1, y: 2, cardinal: .left))
    }
    */
}

extension Sequence {
    func any(where compute: (Iterator.Element) -> Bool) -> Bool {
        for item in self {
            if compute(item) {
                return true
            }
        }
        
        return false
    }
    
    func all(_ compute: (Iterator.Element) -> Bool) -> Bool {
        for item in self {
            if !compute(item) {
                return false
            }
        }
        
        return true
    }
}
