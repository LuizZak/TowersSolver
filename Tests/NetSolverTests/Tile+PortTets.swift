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
    
    func testFromPorts_endPoint() throws {
        try assertTileFromPorts([.top], matchesKind: .endPoint, orientation: .north)
        try assertTileFromPorts([.right], matchesKind: .endPoint, orientation: .east)
        try assertTileFromPorts([.bottom], matchesKind: .endPoint, orientation: .south)
        try assertTileFromPorts([.left], matchesKind: .endPoint, orientation: .west)
    }
    
    func testFromPorts_lineTile() throws {
        try assertTileFromPorts([.top, .bottom], matchesKind: .I, orientation: .north)
        try assertTileFromPorts([.left, .right], matchesKind: .I, orientation: .east)
        try assertTileFromPorts([.bottom, .top], matchesKind: .I, orientation: .north)
        try assertTileFromPorts([.right, .left], matchesKind: .I, orientation: .east)
    }
    
    func testFromPorts_cornerTile() throws {
        try assertTileFromPorts([.top, .right], matchesKind: .L, orientation: .north)
        try assertTileFromPorts([.right, .bottom], matchesKind: .L, orientation: .east)
        try assertTileFromPorts([.bottom, .left], matchesKind: .L, orientation: .south)
        try assertTileFromPorts([.left, .top], matchesKind: .L, orientation: .west)
    }
    
    func testFromPorts_cornerTile_inverted() throws {
        try assertTileFromPorts([.right, .top], matchesKind: .L, orientation: .north)
        try assertTileFromPorts([.bottom, .right], matchesKind: .L, orientation: .east)
        try assertTileFromPorts([.left, .bottom], matchesKind: .L, orientation: .south)
        try assertTileFromPorts([.top, .left], matchesKind: .L, orientation: .west)
    }
    
    func testFromPorts_tripleTile() throws {
        try assertTileFromPorts([.left, .top, .right], matchesKind: .T, orientation: .north)
        try assertTileFromPorts([.top, .right, .bottom], matchesKind: .T, orientation: .east)
        try assertTileFromPorts([.right, .bottom, .left], matchesKind: .T, orientation: .south)
        try assertTileFromPorts([.bottom, .left, .top], matchesKind: .T, orientation: .west)
    }
    
    func testFromPorts_tripleTile_inverted() throws {
        try assertTileFromPorts([.right, .top, .left], matchesKind: .T, orientation: .north)
        try assertTileFromPorts([.bottom, .right, .top], matchesKind: .T, orientation: .east)
        try assertTileFromPorts([.left, .bottom, .right], matchesKind: .T, orientation: .south)
        try assertTileFromPorts([.top, .left, .bottom], matchesKind: .T, orientation: .west)
    }
    
    func testFromPorts_failCases() {
        assertTileFromPortsIsNil([])
        assertTileFromPortsIsNil([.top, .left, .right, .bottom])
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
    
    func assertTileFromPorts(_ ports: [EdgePort],
                             matchesKind kind: Tile.Kind,
                             orientation: Tile.Orientation,
                             line: UInt = #line) throws {
        
        let tile = try XCTUnwrap(Tile.fromPorts(ports))
        
        XCTAssertEqual(tile.kind, kind, line: line)
        XCTAssertEqual(tile.orientation, orientation, line: line)
    }
    
    func assertTileFromPortsIsNil(_ ports: [EdgePort],
                                  line: UInt = #line){
        
        XCTAssertNil(Tile.fromPorts(ports), line: line)
    }
}
