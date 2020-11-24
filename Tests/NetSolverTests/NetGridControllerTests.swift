import XCTest
@testable import NetSolver

class NetGridControllerTests: XCTestCase {
    func testOrientationsForRow() {
        var grid = Grid(rows: 4, columns: 1)
        grid.tiles[0][0].orientation = .north
        grid.tiles[0][1].orientation = .east
        grid.tiles[0][2].orientation = .south
        grid.tiles[0][3].orientation = .west
        let controller = NetGridController(grid: grid)
        
        XCTAssertEqual(controller.tileOrientations(forRow: 0), [.north, .east, .south, .west])
    }
    
    func testShuffle() {
        var rng = MersenneTwister(seed: 300)
        var grid = Grid(rows: 4, columns: 4)
        grid.tiles[0][0].isLocked = true
        grid.tiles[3][3].isLocked = true
        let controller = NetGridController(grid: grid)
        
        controller.shuffle(using: &rng)
        
        XCTAssertEqual(controller.tileOrientations(forRow: 0), [.north, .north, .east, .south])
        XCTAssertEqual(controller.tileOrientations(forRow: 1), [.south, .west, .west, .west])
        XCTAssertEqual(controller.tileOrientations(forRow: 2), [.east, .east, .south, .east])
        XCTAssertEqual(controller.tileOrientations(forRow: 3), [.north, .west, .north, .north])
    }
    
    func testShuffleRotateLockedTilesFalse() {
        var grid = Grid(rows: 4, columns: 4)
        grid.tiles[0][0].isLocked = true
        grid.tiles[3][3].isLocked = true
        let controller = NetGridController(grid: grid)
        
        controller.shuffle(rotateLockedTiles: false)
        
        XCTAssertEqual(controller.tileOrientations(forRow: 0)[0], .north)
        XCTAssertEqual(controller.tileOrientations(forRow: 3)[3], .north)
    }
    
    func testShuffleRotateLockedTilesTrue() {
        var rng = MersenneTwister(seed: 89167249)
        var grid = Grid(rows: 4, columns: 4)
        grid.tiles[0][0].isLocked = true
        grid.tiles[3][3].isLocked = true
        let controller = NetGridController(grid: grid)
        
        controller.shuffle(using: &rng, rotateLockedTiles: true)
        
        XCTAssertEqual(controller.tileOrientations(forRow: 0), [.west, .west, .south, .west])
        XCTAssertEqual(controller.tileOrientations(forRow: 1), [.north, .north, .north, .south])
        XCTAssertEqual(controller.tileOrientations(forRow: 2), [.south, .east, .west, .west])
        XCTAssertEqual(controller.tileOrientations(forRow: 3), [.west, .east, .north, .south])
    }
}
