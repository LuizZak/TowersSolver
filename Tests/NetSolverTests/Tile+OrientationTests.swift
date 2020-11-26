import XCTest
@testable import NetSolver

class Tile_OrientationTests: XCTestCase {
    func testOrientationsForKindLine() {
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .I, excludingPorts: []),
            [.north, .west, .east, .south])
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .I, excludingPorts: [.top]),
            [.east, .west])
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .I, excludingPorts: [.right]),
            [.north, .south])
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .I, excludingPorts: [.bottom]),
            [.east, .west])
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .I, excludingPorts: [.left]),
            [.north, .south])
    }
    
    func testOrientationsForKindCorner() {
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .L, excludingPorts: []),
            [.north, .west, .east, .south])
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .L, excludingPorts: [.top]),
            [.east, .south])
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .L, excludingPorts: [.right]),
            [.south, .west])
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .L, excludingPorts: [.bottom]),
            [.west, .north])
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .L, excludingPorts: [.left]),
            [.north, .east])
    }
    
    func testOrientationsForKindT() {
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .T, excludingPorts: []),
            [.north, .west, .east, .south])
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .T, excludingPorts: [.top]),
            [.south])
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .T, excludingPorts: [.right]),
            [.west])
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .T, excludingPorts: [.bottom]),
            [.north])
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .T, excludingPorts: [.left]),
            [.east])
    }
    
    func testOrientationsForKindEndPiece() {
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .endPoint, excludingPorts: []),
            [.north, .west, .east, .south])
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .endPoint, excludingPorts: [.top]),
            [.west, .east, .south])
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .endPoint, excludingPorts: [.right]),
            [.north, .south, .west])
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .endPoint, excludingPorts: [.bottom]),
            [.east, .west, .north])
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .endPoint, excludingPorts: [.left]),
            [.south, .north, .east])
    }
    
    func testOrientationsForKind() {
        XCTAssertTrue(
            Tile.orientationsForKind(kind: .I, excludingPorts: [.top, .left]).isEmpty)
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .L, excludingPorts: [.top, .left]),
            [.east])
        XCTAssertTrue(
            Tile.orientationsForKind(kind: .T, excludingPorts: [.top, .left]).isEmpty)
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .L, excludingPorts: [.bottom]),
            [.west, .north])
        XCTAssertTrue(
            Tile.orientationsForKind(kind: .endPoint, excludingPorts: [.top, .left, .right, .bottom]).isEmpty)
    }
    
    func testLeftRotated() {
        XCTAssertEqual(Tile.Orientation.north.leftRotated, .west)
        XCTAssertEqual(Tile.Orientation.east.leftRotated, .north)
        XCTAssertEqual(Tile.Orientation.south.leftRotated, .east)
        XCTAssertEqual(Tile.Orientation.west.leftRotated, .south)
    }
    
    func testRightRotated() {
        XCTAssertEqual(Tile.Orientation.north.rightRotated, .east)
        XCTAssertEqual(Tile.Orientation.east.rightRotated, .south)
        XCTAssertEqual(Tile.Orientation.south.rightRotated, .west)
        XCTAssertEqual(Tile.Orientation.west.rightRotated, .north)
    }
    
    func testRotateLeft() {
        var sut = Tile.Orientation.north
        
        sut.rotateLeft()
        XCTAssertEqual(sut, .west)
        sut.rotateLeft()
        XCTAssertEqual(sut, .south)
        sut.rotateLeft()
        XCTAssertEqual(sut, .east)
        sut.rotateLeft()
        XCTAssertEqual(sut, .north)
    }
    
    func testRotateRight() {
        var sut = Tile.Orientation.north
        
        sut.rotateRight()
        XCTAssertEqual(sut, .east)
        sut.rotateRight()
        XCTAssertEqual(sut, .south)
        sut.rotateRight()
        XCTAssertEqual(sut, .west)
        sut.rotateRight()
        XCTAssertEqual(sut, .north)
    }
}
