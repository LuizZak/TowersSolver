//
//  PolygonTests.swift
//  GeometryTests
//
//  Created by Luiz Silva on 02/01/2018.
//

import XCTest
@testable import Geometry

class PolygonTests: XCTestCase {
    
    func testContains() {
        // Envelope shaped polygon, roughly looks like this:
        //
        // |\/|
        // |__|
        //
        let vecs = [
            Vertex(x: 0, y: 0),
            Vertex(x: 10, y: 10),
            Vertex(x: 20, y: 0),
            Vertex(x: 20, y: 20),
            Vertex(x: 0, y: 20),
        ]
        let poly = Geometry.Polygon(vertices: vecs)
        
        XCTAssert(poly.contains(Vertex(x: 0.1, y: 0.1)))
        XCTAssert(poly.contains(Vertex(x: 3, y: 3)))
        XCTAssert(poly.contains(Vertex(x: 3, y: 15)))
        XCTAssert(poly.contains(Vertex(x: 15, y: 7)))
        XCTAssertFalse(poly.contains(Vertex(x: 0, y: 0)))
        XCTAssertFalse(poly.contains(Vertex(x: 10, y: 0)))
        XCTAssertFalse(poly.contains(Vertex(x: 20, y: 20)))
    }
    
    func testBounds() {
        let vecs = [
            Vertex(x: 0, y: -1),
            Vertex(x: 10, y: 10),
            Vertex(x: 20, y: 0),
            Vertex(x: 20, y: 20),
            Vertex(x: 0, y: 20),
            ]
        let poly = Geometry.Polygon(vertices: vecs)
        
        XCTAssertEqual(0, poly.bounds.left)
        XCTAssertEqual(20, poly.bounds.right)
        XCTAssertEqual(20, poly.bounds.bottom)
        XCTAssertEqual(-1, poly.bounds.top)
    }
    
    func testBoundsUpdateAfterChangingVertices() {
        let vecs = [
            Vertex(x: 0, y: -1),
            Vertex(x: 10, y: 10),
            Vertex(x: 20, y: 0),
            Vertex(x: 20, y: 20),
            Vertex(x: 0, y: 20),
            ]
        var poly = Geometry.Polygon(vertices: vecs)
        
        poly.vertices = [
            Vertex(x: 0, y: -10),
            Vertex(x: 10, y: 10),
            Vertex(x: 20, y: 0),
            Vertex(x: 20, y: 200),
            Vertex(x: 0, y: 20),
        ]
        
        XCTAssertEqual(0, poly.bounds.left)
        XCTAssertEqual(20, poly.bounds.right)
        XCTAssertEqual(200, poly.bounds.bottom)
        XCTAssertEqual(-10, poly.bounds.top)
    }
}
