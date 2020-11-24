import XCTest
@testable import NetSolver

class NetGridGeneratorTests: XCTestCase {
    func testLoadFromGameID() {
        let sut = NetGridGenerator(rows: 5, columns: 5)
        sut.loadFromGameID("91424547aadcaec8ded14c8e3")
        let controller = NetGridController(grid: sut.grid)
        
        // Row 0
        XCTAssertEqual(controller.tileOrientations(forRow: 0),
                       [.east, .east, .west, .north, .west])
        XCTAssertEqual(controller.tileKinds(forRow: 0),
                       [.L, .endPoint, .endPoint, .endPoint, .endPoint])
        // Row 1
        XCTAssertEqual(controller.tileOrientations(forRow: 1),
                       [.east, .west, .north, .north, .north])
        XCTAssertEqual(controller.tileKinds(forRow: 1),
                       [.I, .endPoint, .T, .I, .I])
        // Row 2
        XCTAssertEqual(controller.tileOrientations(forRow: 2),
                       [.south, .south, .north, .west, .south])
        XCTAssertEqual(controller.tileKinds(forRow: 2),
                       [.T, .L, .I, .T, .L])
        // Row 3
        XCTAssertEqual(controller.tileOrientations(forRow: 3),
                       [.south, .south, .west, .south, .east])
        XCTAssertEqual(controller.tileKinds(forRow: 3),
                       [.endPoint, .T, .T, .T, .endPoint])
        // Row 4
        XCTAssertEqual(controller.tileOrientations(forRow: 4),
                       [.west, .south, .south, .west, .north])
        XCTAssertEqual(controller.tileKinds(forRow: 4),
                       [.endPoint, .L, .endPoint, .T, .L])
    }
    
    // TODO: Add support for barriers
    func testLoadFromGameID_skipsBarriers() {
        let sut = NetGridGenerator(rows: 5, columns: 5)
        sut.loadFromGameID("91424h547aavdcahevc8ded1h4c8e3")
        let controller = NetGridController(grid: sut.grid)
        
        // Row 0
        XCTAssertEqual(controller.tileOrientations(forRow: 0),
                       [.east, .east, .west, .north, .west])
        XCTAssertEqual(controller.tileKinds(forRow: 0),
                       [.L, .endPoint, .endPoint, .endPoint, .endPoint])
        // Row 1
        XCTAssertEqual(controller.tileOrientations(forRow: 1),
                       [.east, .west, .north, .north, .north])
        XCTAssertEqual(controller.tileKinds(forRow: 1),
                       [.I, .endPoint, .T, .I, .I])
        // Row 2
        XCTAssertEqual(controller.tileOrientations(forRow: 2),
                       [.south, .south, .north, .west, .south])
        XCTAssertEqual(controller.tileKinds(forRow: 2),
                       [.T, .L, .I, .T, .L])
        // Row 3
        XCTAssertEqual(controller.tileOrientations(forRow: 3),
                       [.south, .south, .west, .south, .east])
        XCTAssertEqual(controller.tileKinds(forRow: 3),
                       [.endPoint, .T, .T, .T, .endPoint])
        // Row 4
        XCTAssertEqual(controller.tileOrientations(forRow: 4),
                       [.west, .south, .south, .west, .north])
        XCTAssertEqual(controller.tileKinds(forRow: 4),
                       [.endPoint, .L, .endPoint, .T, .L])
    }
    
    func testEdgePortsFromEncoded_zero() {
        assertEdgePortsFromEncoded(0, expected: [])
    }
    
    func testEdgePortsFromEncoded_singular() {
        assertEdgePortsFromEncoded(EncodedTileConstants.upBitcode,
                                   expected: [.top])
        assertEdgePortsFromEncoded(EncodedTileConstants.leftBitcode,
                                   expected: [.left])
        assertEdgePortsFromEncoded(EncodedTileConstants.rightBitcode,
                                   expected: [.right])
        assertEdgePortsFromEncoded(EncodedTileConstants.downBitcode,
                                   expected: [.bottom])
    }
    
    func testEdgePortsFromEncoded_composedTwo() {
        assertEdgePortsFromEncoded(
            EncodedTileConstants.upBitcode | EncodedTileConstants.rightBitcode,
            expected: [.top, .right]
        )
        assertEdgePortsFromEncoded(
            EncodedTileConstants.rightBitcode | EncodedTileConstants.downBitcode,
            expected: [.right, .bottom]
        )
        assertEdgePortsFromEncoded(
            EncodedTileConstants.downBitcode | EncodedTileConstants.leftBitcode,
            expected: [.bottom, .left]
        )
        assertEdgePortsFromEncoded(
            EncodedTileConstants.leftBitcode | EncodedTileConstants.upBitcode,
            expected: [.left, .top]
        )
    }
    
    func testEdgePortsFromEncoded_composedThree() {
        assertEdgePortsFromEncoded(
            EncodedTileConstants.leftBitcode | EncodedTileConstants.upBitcode | EncodedTileConstants.rightBitcode,
            expected: [.left, .top, .right]
        )
        assertEdgePortsFromEncoded(
            EncodedTileConstants.upBitcode | EncodedTileConstants.rightBitcode | EncodedTileConstants.downBitcode,
            expected: [.top, .right, .bottom]
        )
        assertEdgePortsFromEncoded(
            EncodedTileConstants.rightBitcode | EncodedTileConstants.downBitcode | EncodedTileConstants.leftBitcode,
            expected: [.right, .bottom, .left]
        )
        assertEdgePortsFromEncoded(
            EncodedTileConstants.downBitcode | EncodedTileConstants.leftBitcode | EncodedTileConstants.upBitcode,
            expected: [.bottom, .left, .top]
        )
    }
    
    func testEdgePortsFromEncoded_composedFour() {
        assertEdgePortsFromEncoded(
            EncodedTileConstants.leftBitcode
                | EncodedTileConstants.upBitcode
                | EncodedTileConstants.rightBitcode
                | EncodedTileConstants.downBitcode,
            expected: [.left, .top, .right, .bottom]
        )
    }
    
    func testTileFromEncoded_endPoint() throws {
        try assertTileFromEncoded(EncodedTileConstants.upBitcode,
                                  matchesKind: .endPoint, orientation: .north)
        try assertTileFromEncoded(EncodedTileConstants.rightBitcode,
                                  matchesKind: .endPoint, orientation: .east)
        try assertTileFromEncoded(EncodedTileConstants.downBitcode,
                                  matchesKind: .endPoint, orientation: .south)
        try assertTileFromEncoded(EncodedTileConstants.leftBitcode,
                                  matchesKind: .endPoint, orientation: .west)
    }
    
    func testTileFromEncoded_lineTile() throws {
        try assertTileFromEncoded(EncodedTileConstants.upBitcode | EncodedTileConstants.downBitcode,
                                  matchesKind: .I, orientation: .north)
        try assertTileFromEncoded(EncodedTileConstants.leftBitcode | EncodedTileConstants.rightBitcode,
                                  matchesKind: .I, orientation: .east)
    }
    
    func testTileFromEncoded_cornerTile() throws {
        try assertTileFromEncoded(EncodedTileConstants.upBitcode | EncodedTileConstants.rightBitcode,
                                  matchesKind: .L, orientation: .north)
        try assertTileFromEncoded(EncodedTileConstants.rightBitcode | EncodedTileConstants.downBitcode,
                                  matchesKind: .L, orientation: .east)
        try assertTileFromEncoded(EncodedTileConstants.downBitcode | EncodedTileConstants.leftBitcode,
                                  matchesKind: .L, orientation: .south)
        try assertTileFromEncoded(EncodedTileConstants.leftBitcode | EncodedTileConstants.upBitcode,
                                  matchesKind: .L, orientation: .west)
    }
    
    func testTileFromEncoded_tripleTile() throws {
        try assertTileFromEncoded(EncodedTileConstants.leftBitcode | EncodedTileConstants.upBitcode | EncodedTileConstants.rightBitcode,
                                  matchesKind: .T, orientation: .north)
        try assertTileFromEncoded(EncodedTileConstants.upBitcode | EncodedTileConstants.rightBitcode | EncodedTileConstants.downBitcode,
                                  matchesKind: .T, orientation: .east)
        try assertTileFromEncoded(EncodedTileConstants.rightBitcode | EncodedTileConstants.downBitcode | EncodedTileConstants.leftBitcode,
                                  matchesKind: .T, orientation: .south)
        try assertTileFromEncoded(EncodedTileConstants.downBitcode | EncodedTileConstants.leftBitcode | EncodedTileConstants.upBitcode,
                                  matchesKind: .T, orientation: .west)
    }
}

// MARK: - Assertion functions
private extension NetGridGeneratorTests {
    func assertTileFromEncoded(_ value: Int,
                               matchesKind kind: Tile.Kind,
                               orientation: Tile.Orientation,
                               line: UInt = #line) throws {
        
        let tile = try XCTUnwrap(NetGridGenerator.tileFromEncoded(value))
        
        XCTAssertEqual(tile.kind, kind, line: line)
        XCTAssertEqual(tile.orientation, orientation, line: line)
    }
    
    func assertEdgePortsFromEncoded(_ value: Int,
                                    expected: Set<EdgePort>,
                                    line: UInt = #line) {
        
        let ports = NetGridGenerator.edgePortsFromEncoded(value)
        
        XCTAssertEqual(Set(ports), expected, line: line)
    }
}
