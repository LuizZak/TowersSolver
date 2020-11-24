import XCTest
@testable import NetSolver

class Tile_PortTets: XCTestCase {
    func testPorts_lineTile() {
        assertPortsForTile(Tile(kind: .I, orientation: .north),
                           match: [.top, .bottom])
        assertPortsForTile(Tile(kind: .I, orientation: .east),
                           match: [.left, .right])
        assertPortsForTile(Tile(kind: .I, orientation: .south),
                           match: [.top, .bottom])
        assertPortsForTile(Tile(kind: .I, orientation: .west),
                           match: [.left, .right])
    }
    
    func testPorts_cornerTile() {
        assertPortsForTile(Tile(kind: .L, orientation: .north),
                           match: [.top, .right])
        assertPortsForTile(Tile(kind: .L, orientation: .east),
                           match: [.right, .bottom])
        assertPortsForTile(Tile(kind: .L, orientation: .south),
                           match: [.bottom, .left])
        assertPortsForTile(Tile(kind: .L, orientation: .west),
                           match: [.left, .top])
    }
    
    func testPorts_tripleTile() {
        assertPortsForTile(Tile(kind: .T, orientation: .north),
                           match: [.left, .top, .right])
        assertPortsForTile(Tile(kind: .T, orientation: .east),
                           match: [.top, .right, .bottom])
        assertPortsForTile(Tile(kind: .T, orientation: .south),
                           match: [.right, .bottom, .left])
        assertPortsForTile(Tile(kind: .T, orientation: .west),
                           match: [.bottom, .left, .top])
    }
    
    func testPorts_endPoint() {
        assertPortsForTile(Tile(kind: .endPoint, orientation: .north),
                           match: [.top])
        assertPortsForTile(Tile(kind: .endPoint, orientation: .east),
                           match: [.right])
        assertPortsForTile(Tile(kind: .endPoint, orientation: .south),
                           match: [.bottom])
        assertPortsForTile(Tile(kind: .endPoint, orientation: .west),
                           match: [.left])
    }
    
    func testPortsForTile_lineTile() {
        assertPortsForTile(kind: .I, orientation: .north,
                           match: [.top, .bottom])
        assertPortsForTile(kind: .I, orientation: .east,
                           match: [.left, .right])
        assertPortsForTile(kind: .I, orientation: .south,
                           match: [.top, .bottom])
        assertPortsForTile(kind: .I, orientation: .west,
                           match: [.left, .right])
    }
    
    func testPortsForTile_cornerTile() {
        assertPortsForTile(kind: .L, orientation: .north,
                           match: [.top, .right])
        assertPortsForTile(kind: .L, orientation: .east,
                           match: [.right, .bottom])
        assertPortsForTile(kind: .L, orientation: .south,
                           match: [.bottom, .left])
        assertPortsForTile(kind: .L, orientation: .west,
                           match: [.left, .top])
    }
    
    func testPortsForTile_tripleTile() {
        assertPortsForTile(kind: .T, orientation: .north,
                           match: [.left, .top, .right])
        assertPortsForTile(kind: .T, orientation: .east,
                           match: [.top, .right, .bottom])
        assertPortsForTile(kind: .T, orientation: .south,
                           match: [.right, .bottom, .left])
        assertPortsForTile(kind: .T, orientation: .west,
                           match: [.bottom, .left, .top])
    }
    
    func testPortsForTile_endPoint() {
        assertPortsForTile(kind: .endPoint, orientation: .north,
                           match: [.top])
        assertPortsForTile(kind: .endPoint, orientation: .east,
                           match: [.right])
        assertPortsForTile(kind: .endPoint, orientation: .south,
                           match: [.bottom])
        assertPortsForTile(kind: .endPoint, orientation: .west,
                           match: [.left])
    }
    
    func testTileForPorts_endPoint() throws {
        try assertTileForPorts([.top], matchesKind: .endPoint, orientation: .north)
        try assertTileForPorts([.right], matchesKind: .endPoint, orientation: .east)
        try assertTileForPorts([.bottom], matchesKind: .endPoint, orientation: .south)
        try assertTileForPorts([.left], matchesKind: .endPoint, orientation: .west)
    }
    
    func testTileForPorts_lineTile() throws {
        try assertTileForPorts([.top, .bottom], matchesKind: .I, orientation: .north)
        try assertTileForPorts([.left, .right], matchesKind: .I, orientation: .east)
        try assertTileForPorts([.bottom, .top], matchesKind: .I, orientation: .north)
        try assertTileForPorts([.right, .left], matchesKind: .I, orientation: .east)
    }
    
    func testTileForPorts_cornerTile() throws {
        try assertTileForPorts([.top, .right], matchesKind: .L, orientation: .north)
        try assertTileForPorts([.right, .bottom], matchesKind: .L, orientation: .east)
        try assertTileForPorts([.bottom, .left], matchesKind: .L, orientation: .south)
        try assertTileForPorts([.left, .top], matchesKind: .L, orientation: .west)
    }
    
    func testTileForPorts_cornerTile_inverted() throws {
        try assertTileForPorts([.right, .top], matchesKind: .L, orientation: .north)
        try assertTileForPorts([.bottom, .right], matchesKind: .L, orientation: .east)
        try assertTileForPorts([.left, .bottom], matchesKind: .L, orientation: .south)
        try assertTileForPorts([.top, .left], matchesKind: .L, orientation: .west)
    }
    
    func testTileForPorts_tripleTile() throws {
        try assertTileForPorts([.left, .top, .right], matchesKind: .T, orientation: .north)
        try assertTileForPorts([.top, .right, .bottom], matchesKind: .T, orientation: .east)
        try assertTileForPorts([.right, .bottom, .left], matchesKind: .T, orientation: .south)
        try assertTileForPorts([.bottom, .left, .top], matchesKind: .T, orientation: .west)
    }
    
    func testTileForPorts_tripleTile_inverted() throws {
        try assertTileForPorts([.right, .top, .left], matchesKind: .T, orientation: .north)
        try assertTileForPorts([.bottom, .right, .top], matchesKind: .T, orientation: .east)
        try assertTileForPorts([.left, .bottom, .right], matchesKind: .T, orientation: .south)
        try assertTileForPorts([.top, .left, .bottom], matchesKind: .T, orientation: .west)
    }
    
    func testTileForPorts_failCases() {
        assertTileForPortsNil([])
        assertTileForPortsNil([.top, .left, .right, .bottom])
    }
}

// MARK: - Assertion functions
private extension Tile_PortTets {
    func assertPortsForTile(_ tile: Tile,
                            match expected: Set<EdgePort>,
                            line: UInt = #line) {
        
        let ports = tile.ports
        
        XCTAssertEqual(Set(ports), expected, line: line)
    }
    
    func assertPortsForTile(kind: Tile.Kind,
                            orientation: Tile.Orientation,
                            match expected: Set<EdgePort>,
                            line: UInt = #line) {
        
        let ports = Tile.portsForTile(kind: kind, orientation: orientation)
        
        XCTAssertEqual(Set(ports), expected, line: line)
    }
    
    func assertTileForPorts(_ ports: [EdgePort],
                            matchesKind kind: Tile.Kind,
                            orientation: Tile.Orientation,
                            line: UInt = #line) throws {
        
        let tile = try XCTUnwrap(Tile.tileForPorts(ports))
        
        XCTAssertEqual(tile.kind, kind, line: line)
        XCTAssertEqual(tile.orientation, orientation, line: line)
    }
    
    func assertTileForPortsNil(_ ports: [EdgePort],
                               line: UInt = #line){
        
        XCTAssertNil(Tile.tileForPorts(ports), line: line)
    }
}
