import XCTest

@testable import NetSolver

class Tile_OrientationTests: XCTestCase {
    func testOrientationsForKindIncludingPorts_lineTile() {
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .I, includingPorts: []),
            [.north, .east, .south, .west]
        )
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .I, includingPorts: [.top]),
            [.north, .south]
        )
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .I, includingPorts: [.right]),
            [.east, .west]
        )
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .I, includingPorts: [.bottom]),
            [.north, .south]
        )
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .I, includingPorts: [.left]),
            [.east, .west]
        )
    }

    func testOrientationsForKindIncludingPorts_cornerTile() {
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .L, includingPorts: []),
            [.north, .east, .south, .west]
        )
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .L, includingPorts: [.top]),
            [.north, .west]
        )
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .L, includingPorts: [.right]),
            [.north, .east]
        )
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .L, includingPorts: [.bottom]),
            [.east, .south]
        )
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .L, includingPorts: [.left]),
            [.south, .west]
        )
    }

    func testOrientationsForKindIncludingPorts_tripleTile() {
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .T, includingPorts: []),
            [.north, .east, .south, .west]
        )
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .T, includingPorts: [.top]),
            [.west, .north, .east]
        )
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .T, includingPorts: [.right]),
            [.north, .east, .south]
        )
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .T, includingPorts: [.bottom]),
            [.east, .south, .west]
        )
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .T, includingPorts: [.left]),
            [.south, .west, .north]
        )
    }

    func testOrientationsForKindIncludingPorts_endPoint() {
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .endPoint, includingPorts: []),
            [.north, .east, .south, .west]
        )
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .endPoint, includingPorts: [.top]),
            [.north]
        )
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .endPoint, includingPorts: [.right]),
            [.east]
        )
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .endPoint, includingPorts: [.bottom]),
            [.south]
        )
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .endPoint, includingPorts: [.left]),
            [.west]
        )
    }

    func testOrientationsForKindIncludingPorts() {
        XCTAssertTrue(
            Tile.orientationsForKind(kind: .I, includingPorts: [.top, .left]).isEmpty
        )
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .L, includingPorts: [.top, .left]),
            [.west]
        )
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .T, includingPorts: [.top, .left]),
            [.west, .north]
        )
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .L, includingPorts: [.bottom]),
            [.east, .south]
        )
        XCTAssertTrue(
            Tile.orientationsForKind(
                kind: .endPoint,
                includingPorts: [.top, .left, .right, .bottom]
            ).isEmpty
        )
    }

    func testOrientationsForKindExcludingPorts_lineTile() {
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .I, excludingPorts: []),
            [.north, .west, .east, .south]
        )
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .I, excludingPorts: [.top]),
            [.east, .west]
        )
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .I, excludingPorts: [.right]),
            [.north, .south]
        )
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .I, excludingPorts: [.bottom]),
            [.east, .west]
        )
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .I, excludingPorts: [.left]),
            [.north, .south]
        )
    }

    func testOrientationsForKindExcludingPorts_cornerTile() {
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .L, excludingPorts: []),
            [.north, .west, .east, .south]
        )
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .L, excludingPorts: [.top]),
            [.east, .south]
        )
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .L, excludingPorts: [.right]),
            [.south, .west]
        )
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .L, excludingPorts: [.bottom]),
            [.west, .north]
        )
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .L, excludingPorts: [.left]),
            [.north, .east]
        )
    }

    func testOrientationsForKindExcludingPorts_tripleTile() {
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .T, excludingPorts: []),
            [.north, .west, .east, .south]
        )
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .T, excludingPorts: [.top]),
            [.south]
        )
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .T, excludingPorts: [.right]),
            [.west]
        )
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .T, excludingPorts: [.bottom]),
            [.north]
        )
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .T, excludingPorts: [.left]),
            [.east]
        )
    }

    func testOrientationsForKindExcludingPorts_endPoint() {
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .endPoint, excludingPorts: []),
            [.north, .west, .east, .south]
        )
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .endPoint, excludingPorts: [.top]),
            [.west, .east, .south]
        )
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .endPoint, excludingPorts: [.right]),
            [.north, .south, .west]
        )
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .endPoint, excludingPorts: [.bottom]),
            [.east, .west, .north]
        )
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .endPoint, excludingPorts: [.left]),
            [.south, .north, .east]
        )
    }

    func testOrientationsForKindExcludingPorts() {
        XCTAssertTrue(
            Tile.orientationsForKind(kind: .I, excludingPorts: [.top, .left]).isEmpty
        )
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .L, excludingPorts: [.top, .left]),
            [.east]
        )
        XCTAssertTrue(
            Tile.orientationsForKind(kind: .T, excludingPorts: [.top, .left]).isEmpty
        )
        XCTAssertEqual(
            Tile.orientationsForKind(kind: .L, excludingPorts: [.bottom]),
            [.west, .north]
        )
        XCTAssertTrue(
            Tile.orientationsForKind(
                kind: .endPoint,
                excludingPorts: [.top, .left, .right, .bottom]
            ).isEmpty
        )
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

    func testNormalizedByPortSetOnTileKind_lineTile() {
        let set = Set(Tile.Orientation.allCases)

        XCTAssertEqual(set.normalizedByPortSet(onTileKind: .I), [.north, .east])
    }

    func testNormalizedByPortSetOnTileKind_lineTile_southWest() {
        let set: Set<Tile.Orientation> = [.south, .west]

        XCTAssertEqual(set.normalizedByPortSet(onTileKind: .I), [.south, .west])
    }

    func testNormalizedByPortSetOnTileKind_cornerTile() {
        let set = Set(Tile.Orientation.allCases)

        XCTAssertEqual(set.normalizedByPortSet(onTileKind: .L), [.north, .east, .south, .west])
    }

    func testNormalizedByPortSetOnTileKind_tripleTile() {
        let set = Set(Tile.Orientation.allCases)

        XCTAssertEqual(set.normalizedByPortSet(onTileKind: .T), [.north, .east, .south, .west])
    }

    func testNormalizedByPortSetOnTileKind_endPoint() {
        let set = Set(Tile.Orientation.allCases)

        XCTAssertEqual(
            set.normalizedByPortSet(onTileKind: .endPoint),
            [.north, .east, .south, .west]
        )
    }

    func testDescription() {
        XCTAssertEqual(Tile.Orientation.north.description, "north")
        XCTAssertEqual(Tile.Orientation.east.description, "east")
        XCTAssertEqual(Tile.Orientation.south.description, "south")
        XCTAssertEqual(Tile.Orientation.west.description, "west")
    }
}
