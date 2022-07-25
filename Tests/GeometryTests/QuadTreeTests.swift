import XCTest

@testable import Geometry

class QuadTreeTests: XCTestCase {
    typealias Quad = QuadTree<Cell>

    var quad: Quad!
    var bounds: FloatRectangle!

    override func setUp() {
        bounds = FloatRectangle(x: 0, y: 0, width: 10, height: 10)
        quad = Quad(bounds: bounds)
    }

    public func testCreateQuadtree() {
        XCTAssertEqual(quad.bounds, bounds)
        XCTAssertEqual(quad.values, [])
    }

    public func testAddValue() {
        let value = Cell(bounds: FloatRectangle(x: 2.5, y: 2.5, width: 5, height: 5))

        quad.addValue(value)

        XCTAssertEqual(quad.values[0], value)
    }

    public func testMaxElements() {
        let value = Cell(bounds: FloatRectangle(x: 1, y: 1, width: 2, height: 2))
        quad.addValue(value)
        quad.addValue(value)
        quad.maxElements = 2

        // Split!
        quad.addValue(value)

        XCTAssertEqual(quad.values.count, 2)
        XCTAssertNotNil(quad.quadrants)
    }

    public func testAddToSubtreeOnlyIfItemFitsCompletely() {
        let value = Cell(bounds: FloatRectangle(x: 2, y: 2, width: 5, height: 5))
        quad.addValue(value)
        quad.maxElements = 1

        // Split, but don't add
        quad.addValue(value)

        XCTAssertEqual(quad.values.count, 2)
        XCTAssertNotNil(quad.quadrants)
    }

    struct Cell: QuadTreeValue {
        var bounds: FloatRectangle
    }
}
