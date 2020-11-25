import XCTest
@testable import NetSolver

class Tile_OrientationTests: XCTestCase {
    func testOrientationsForKindLine() {
        XCTAssertEqual(
            Set(Tile.orientationsForKind(kind: .I, excludingPorts: [])),
            Set([.north, .west, .east, .south]))
        XCTAssertEqual(
            Set(Tile.orientationsForKind(kind: .I, excludingPorts: [.top])),
            Set([.east, .west]))
        XCTAssertEqual(
            Set(Tile.orientationsForKind(kind: .I, excludingPorts: [.right])),
            Set([.north, .south]))
        XCTAssertEqual(
            Set(Tile.orientationsForKind(kind: .I, excludingPorts: [.bottom])),
            Set([.east, .west]))
        XCTAssertEqual(
            Set(Tile.orientationsForKind(kind: .I, excludingPorts: [.left])),
            Set([.north, .south]))
    }
    
    func testOrientationsForKindCorner() {
        XCTAssertEqual(
            Set(Tile.orientationsForKind(kind: .L, excludingPorts: [])),
            Set([.north, .west, .east, .south]))
        XCTAssertEqual(
            Set(Tile.orientationsForKind(kind: .L, excludingPorts: [.top])),
            Set([.east, .south]))
        XCTAssertEqual(
            Set(Tile.orientationsForKind(kind: .L, excludingPorts: [.right])),
            Set([.south, .west]))
        XCTAssertEqual(
            Set(Tile.orientationsForKind(kind: .L, excludingPorts: [.bottom])),
            Set([.west, .north]))
        XCTAssertEqual(
            Set(Tile.orientationsForKind(kind: .L, excludingPorts: [.left])),
            Set([.north, .east]))
    }
    
    func testOrientationsForKindT() {
        XCTAssertEqual(
            Set(Tile.orientationsForKind(kind: .T, excludingPorts: [])),
            Set([.north, .west, .east, .south]))
        XCTAssertEqual(
            Set(Tile.orientationsForKind(kind: .T, excludingPorts: [.top])),
            Set([.south]))
        XCTAssertEqual(
            Set(Tile.orientationsForKind(kind: .T, excludingPorts: [.right])),
            Set([.west]))
        XCTAssertEqual(
            Set(Tile.orientationsForKind(kind: .T, excludingPorts: [.bottom])),
            Set([.north]))
        XCTAssertEqual(
            Set(Tile.orientationsForKind(kind: .T, excludingPorts: [.left])),
            Set([.east]))
    }
    
    func testOrientationsForKindEndPiece() {
        XCTAssertEqual(
            Set(Tile.orientationsForKind(kind: .endPoint, excludingPorts: [])),
            Set([.north, .west, .east, .south]))
        XCTAssertEqual(
            Set(Tile.orientationsForKind(kind: .endPoint, excludingPorts: [.top])),
            Set([.west, .east, .south]))
        XCTAssertEqual(
            Set(Tile.orientationsForKind(kind: .endPoint, excludingPorts: [.right])),
            Set([.north, .south, .west]))
        XCTAssertEqual(
            Set(Tile.orientationsForKind(kind: .endPoint, excludingPorts: [.bottom])),
            Set([.east, .west, .north]))
        XCTAssertEqual(
            Set(Tile.orientationsForKind(kind: .endPoint, excludingPorts: [.left])),
            Set([.south, .north, .east]))
    }
    
    func testOrientationsForKind() {
        XCTAssertTrue(
            Set(Tile.orientationsForKind(kind: .I, excludingPorts: [.top, .left])).isEmpty)
        XCTAssertEqual(
            Set(Tile.orientationsForKind(kind: .L, excludingPorts: [.top, .left])),
            Set([.east]))
        XCTAssertTrue(
            Set(Tile.orientationsForKind(kind: .T, excludingPorts: [.top, .left])).isEmpty)
        XCTAssertEqual(
            Set(Tile.orientationsForKind(kind: .L, excludingPorts: [.bottom])),
            Set([.west, .north]))
        XCTAssertTrue(
            Set(Tile.orientationsForKind(kind: .endPoint, excludingPorts: [.top, .left, .right, .bottom])).isEmpty)
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
