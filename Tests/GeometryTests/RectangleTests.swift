//
//  RectangleTests.swift
//  GeometryTests
//
//  Created by Luiz Silva on 29/12/2017.
//

import XCTest

@testable import Geometry

class RectangleTests: XCTestCase {
    func testRectangleIntersects() {
        let rect1 = FloatRectangle(x: 0, y: 0, width: 10, height: 10)
        let rect2 = FloatRectangle(x: 5, y: 5, width: 10, height: 10)
        let rect3 = FloatRectangle(x: 4, y: 10, width: 10, height: 10)
        let rect4 = FloatRectangle(x: 3, y: 11, width: 10, height: 10)

        XCTAssert(rect1.intersects(with: rect2))
        XCTAssert(rect1.intersects(with: rect3))
        XCTAssertFalse(rect1.intersects(with: rect4))
    }

    func testRectangleContainsVector() {
        let rect1 = FloatRectangle(x: 2, y: 2, width: 4, height: 4)

        XCTAssert(rect1.contains(Vertex(x: 3, y: 3)))
        XCTAssertFalse(rect1.contains(Vertex(x: 0, y: 3)))
        XCTAssertFalse(rect1.contains(Vertex(x: 3, y: 0)))
    }

    func testRectangleContainsRect() {
        let rect1 = FloatRectangle(x: 2, y: 2, width: 4, height: 4)
        let rect2 = FloatRectangle(x: 0, y: 0, width: 10, height: 10)

        XCTAssert(rect2.contains(rect: rect1))
        XCTAssertFalse(rect1.contains(rect: rect2))
        XCTAssert(rect1.contains(rect: rect1))
    }

    func testRectangleBoundsOf() {
        let rect = FloatRectangle(boundsFor: [
            Vertex(x: 0, y: -1),
            Vertex(x: 10, y: 0),
            Vertex(x: -3, y: 11),
            Vertex(x: 15, y: 7),
        ])

        XCTAssertEqual(-3, rect.left)
        XCTAssertEqual(15, rect.right)
        XCTAssertEqual(-1, rect.top)
        XCTAssertEqual(11, rect.bottom)
        XCTAssertEqual(18, rect.width)
        XCTAssertEqual(12, rect.height)
    }
}
