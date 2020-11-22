import XCTest
@testable import NetSolver

class Tile_PortTets: XCTestCase {
    func testPortsLine() {
        assertPortsForTile(Tile(kind: .I, orientation: .north),
                           match: [.top, .bottom])
        assertPortsForTile(Tile(kind: .I, orientation: .east),
                           match: [.left, .right])
        assertPortsForTile(Tile(kind: .I, orientation: .south),
                           match: [.top, .bottom])
        assertPortsForTile(Tile(kind: .I, orientation: .west),
                           match: [.left, .right])
    }
    
    func testPortsCorner() {
        assertPortsForTile(Tile(kind: .L, orientation: .north),
                           match: [.top, .right])
        assertPortsForTile(Tile(kind: .L, orientation: .east),
                           match: [.right, .bottom])
        assertPortsForTile(Tile(kind: .L, orientation: .south),
                           match: [.bottom, .left])
        assertPortsForTile(Tile(kind: .L, orientation: .west),
                           match: [.left, .top])
    }
    
    func testPortsT() {
        assertPortsForTile(Tile(kind: .T, orientation: .north),
                           match: [.left, .top, .right])
        assertPortsForTile(Tile(kind: .T, orientation: .east),
                           match: [.top, .right, .bottom])
        assertPortsForTile(Tile(kind: .T, orientation: .south),
                           match: [.right, .bottom, .left])
        assertPortsForTile(Tile(kind: .T, orientation: .west),
                           match: [.bottom, .left, .top])
    }
    
    func testPortsEndPiece() {
        assertPortsForTile(Tile(kind: .endPiece, orientation: .north),
                           match: [.top])
        assertPortsForTile(Tile(kind: .endPiece, orientation: .east),
                           match: [.right])
        assertPortsForTile(Tile(kind: .endPiece, orientation: .south),
                           match: [.bottom])
        assertPortsForTile(Tile(kind: .endPiece, orientation: .west),
                           match: [.left])
    }
    
    func testPortsForTileLine() {
        assertPortsForTile(kind: .I, orientation: .north,
                           match: [.top, .bottom])
        assertPortsForTile(kind: .I, orientation: .east,
                           match: [.left, .right])
        assertPortsForTile(kind: .I, orientation: .south,
                           match: [.top, .bottom])
        assertPortsForTile(kind: .I, orientation: .west,
                           match: [.left, .right])
    }
    
    func testPortsForTileCorner() {
        assertPortsForTile(kind: .L, orientation: .north,
                           match: [.top, .right])
        assertPortsForTile(kind: .L, orientation: .east,
                           match: [.right, .bottom])
        assertPortsForTile(kind: .L, orientation: .south,
                           match: [.bottom, .left])
        assertPortsForTile(kind: .L, orientation: .west,
                           match: [.left, .top])
    }
    
    func testPortsForTileT() {
        assertPortsForTile(kind: .T, orientation: .north,
                           match: [.left, .top, .right])
        assertPortsForTile(kind: .T, orientation: .east,
                           match: [.top, .right, .bottom])
        assertPortsForTile(kind: .T, orientation: .south,
                           match: [.right, .bottom, .left])
        assertPortsForTile(kind: .T, orientation: .west,
                           match: [.bottom, .left, .top])
    }
    
    func testPortsForTilePiece() {
        assertPortsForTile(kind: .endPiece, orientation: .north,
                           match: [.top])
        assertPortsForTile(kind: .endPiece, orientation: .east,
                           match: [.right])
        assertPortsForTile(kind: .endPiece, orientation: .south,
                           match: [.bottom])
        assertPortsForTile(kind: .endPiece, orientation: .west,
                           match: [.left])
    }
}

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
}
