import XCTest
import NetSolver

class EdgePortTests: XCTestCase {
    func testOpposite() {
        XCTAssertEqual(EdgePort.top.opposite, .bottom)
        XCTAssertEqual(EdgePort.left.opposite, .right)
        XCTAssertEqual(EdgePort.bottom.opposite, .top)
        XCTAssertEqual(EdgePort.right.opposite, .left)
    }
    
    func testLeftRotated() {
        XCTAssertEqual(EdgePort.top.leftRotated, .left)
        XCTAssertEqual(EdgePort.right.leftRotated, .top)
        XCTAssertEqual(EdgePort.bottom.leftRotated, .right)
        XCTAssertEqual(EdgePort.left.leftRotated, .bottom)
    }
    
    func testRightRotated() {
        XCTAssertEqual(EdgePort.top.rightRotated, .right)
        XCTAssertEqual(EdgePort.right.rightRotated, .bottom)
        XCTAssertEqual(EdgePort.bottom.rightRotated, .left)
        XCTAssertEqual(EdgePort.left.rightRotated, .top)
    }
    
    func testAsEdgePort() {
        XCTAssertEqual(Tile.Orientation.north.asEdgePort, .top)
        XCTAssertEqual(Tile.Orientation.east.asEdgePort, .right)
        XCTAssertEqual(Tile.Orientation.south.asEdgePort, .bottom)
        XCTAssertEqual(Tile.Orientation.west.asEdgePort, .left)
    }
}
