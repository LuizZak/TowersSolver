import XCTest
@testable import NetSolver

class NetGridControllerTests: XCTestCase {
    func testOrientationsForRow() {
        var grid = Grid(rows: 1, columns: 4)
        grid.tiles[0][0].orientation = .north
        grid.tiles[0][1].orientation = .east
        grid.tiles[0][2].orientation = .south
        grid.tiles[0][3].orientation = .west
        let sut = NetGridController(grid: grid)
        
        XCTAssertEqual(sut.tileOrientations(forRow: 0), [.north, .east, .south, .west])
    }
    
    func testShuffle() {
        var rng = MersenneTwister(seed: 300)
        var grid = Grid(rows: 4, columns: 4)
        grid.tiles[0][0].isLocked = true
        grid.tiles[3][3].isLocked = true
        let sut = NetGridController(grid: grid)
        
        sut.shuffle(using: &rng)
        
        XCTAssertEqual(sut.tileOrientations(forRow: 0), [.north, .north, .east, .south])
        XCTAssertEqual(sut.tileOrientations(forRow: 1), [.south, .west, .west, .west])
        XCTAssertEqual(sut.tileOrientations(forRow: 2), [.east, .east, .south, .east])
        XCTAssertEqual(sut.tileOrientations(forRow: 3), [.north, .west, .north, .north])
    }
    
    func testShuffleRotateLockedTilesFalse() {
        var grid = Grid(rows: 4, columns: 4)
        grid.tiles[0][0].isLocked = true
        grid.tiles[3][3].isLocked = true
        let sut = NetGridController(grid: grid)
        
        sut.shuffle(rotateLockedTiles: false)
        
        XCTAssertEqual(sut.tileOrientations(forRow: 0)[0], .north)
        XCTAssertEqual(sut.tileOrientations(forRow: 3)[3], .north)
    }
    
    func testShuffleRotateLockedTilesTrue() {
        var rng = MersenneTwister(seed: 89167249)
        var grid = Grid(rows: 4, columns: 4)
        grid.tiles[0][0].isLocked = true
        grid.tiles[3][3].isLocked = true
        let sut = NetGridController(grid: grid)
        
        sut.shuffle(using: &rng, rotateLockedTiles: true)
        
        XCTAssertEqual(sut.tileOrientations(forRow: 0), [.west, .west, .south, .west])
        XCTAssertEqual(sut.tileOrientations(forRow: 1), [.north, .north, .north, .south])
        XCTAssertEqual(sut.tileOrientations(forRow: 2), [.south, .east, .west, .west])
        XCTAssertEqual(sut.tileOrientations(forRow: 3), [.west, .east, .north, .south])
    }
    
    func testCanRotateTile() {
        let grid = Grid(rows: 1, columns: 1)
        let sut = NetGridController(grid: grid)
        
        XCTAssertTrue(sut.canRotateTile(atColumn: 0, row: 0))
    }
    
    func testCanRotateTile_isLockedTile() {
        var grid = Grid(rows: 1, columns: 1)
        grid[row: 0, column: 0].isLocked = true
        let sut = NetGridController(grid: grid)
        
        XCTAssertFalse(sut.canRotateTile(atColumn: 0, row: 0))
    }
    
    func testRotateTile_clockwise() {
        let grid = Grid(rows: 1, columns: 1)
        let sut = NetGridController(grid: grid)
        
        sut.rotateTile(atColumn: 0, row: 0, direction: .clockwise)
        
        XCTAssertEqual(sut.grid[row: 0, column: 0].orientation, .east)
    }
    
    func testRotateTile_counterClockwise() {
        let grid = Grid(rows: 1, columns: 1)
        let sut = NetGridController(grid: grid)
        
        sut.rotateTile(atColumn: 0, row: 0, direction: .counterClockwise)
        
        XCTAssertEqual(sut.grid[row: 0, column: 0].orientation, .west)
    }
    
    func testRotateTile_ignoreLockedTile_true() {
        var grid = Grid(rows: 1, columns: 1)
        grid[row: 0, column: 0].isLocked = true
        let sut = NetGridController(grid: grid)
        
        sut.rotateTile(atColumn: 0, row: 0, direction: .clockwise, ignoreIfLocked: true)
        
        XCTAssertEqual(sut.grid[row: 0, column: 0].orientation, .north)
    }
    
    func testRotateTile_ignoreLockedTile_false() {
        var grid = Grid(rows: 1, columns: 1)
        grid[row: 0, column: 0].isLocked = true
        let sut = NetGridController(grid: grid)
        
        sut.rotateTile(atColumn: 0, row: 0, direction: .clockwise, ignoreIfLocked: false)
        
        XCTAssertEqual(sut.grid[row: 0, column: 0].orientation, .east)
    }
    
    func testSetTileOrientation() {
        let grid = Grid(rows: 1, columns: 1)
        let sut = NetGridController(grid: grid)
        
        sut.setTileOrientation(atColumn: 0, row: 0, orientation: .south)
        
        XCTAssertEqual(sut.grid[row: 0, column: 0].orientation, .south)
    }
    
    func testGameId() {
        // Game available at:
        // https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/net.html#4x4:48225b3556d73a64
        let gridGen = NetGridGenerator(rows: 4, columns: 4)
        gridGen.loadFromGameID("48225b3556d73a64")
        let sut = NetGridController(grid: gridGen.grid)
        
        XCTAssertEqual(sut.gameId(), "4x4:48225b3556d73a64")
    }
    
    func testGameId_wrappingTrue() {
        // Game available at:
        // https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/net.html#4x4:48225b3556d73a64
        let gridGen = NetGridGenerator(rows: 4, columns: 4)
        gridGen.loadFromGameID("48225b3556d73a64")
        var grid = gridGen.grid
        grid.wrapping = true
        let sut = NetGridController(grid: grid)
        
        XCTAssertEqual(sut.gameId(), "4x4w:48225b3556d73a64")
    }
    
    func testIsSolved_4x4_unsolved() {
        // Game available at:
        // https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/net.html#4x4:48225b3556d73a64
        let gridGen = NetGridGenerator(rows: 4, columns: 4)
        gridGen.loadFromGameID("48225b3556d73a64")
        let sut = NetGridController(grid: gridGen.grid)
        
        XCTAssertFalse(sut.isSolved)
    }
    
    func testIsSolved_4x4_solved() {
        // Game available at:
        // https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/net.html#4x4:8888ab6aa3de3562
        let gridGen = NetGridGenerator(rows: 4, columns: 4)
        gridGen.loadFromGameID("8888ab6aa3de3562")
        let sut = NetGridController(grid: gridGen.grid)
        
        XCTAssertTrue(sut.isSolved)
    }
    
    func testIsSolved_nonWrapping() {
        let grid = TestGridBuilder(columns: 2, rows: 2)
            .setTile(0, 0, kind: .L, orientation: .south)
            .setTile(1, 0, kind: .L, orientation: .east)
            .setTile(0, 1, kind: .endPoint, orientation: .north)
            .setTile(1, 1, kind: .endPoint, orientation: .north)
            .setWrapping(false)
            .build()
        let sut = NetGridController(grid: grid)
        
        XCTAssertFalse(sut.isSolved)
    }
    
    func testIsSolved_wrapping() {
        let grid = TestGridBuilder(columns: 2, rows: 2)
            .setTile(0, 0, kind: .L, orientation: .south)
            .setTile(1, 0, kind: .L, orientation: .east)
            .setTile(0, 1, kind: .endPoint, orientation: .north)
            .setTile(1, 1, kind: .endPoint, orientation: .north)
            .setWrapping(true)
            .build()
        let sut = NetGridController(grid: grid)
        
        XCTAssertTrue(sut.isSolved)
    }
    
    func testIsSolved_loopingGrid_returnsFalse() {
        let grid = TestGridBuilder(columns: 2, rows: 2)
            .setTile(0, 0, kind: .L, orientation: .east)
            .setTile(1, 0, kind: .L, orientation: .south)
            .setTile(0, 1, kind: .L, orientation: .north)
            .setTile(1, 1, kind: .L, orientation: .west)
            .build()
        let sut = NetGridController(grid: grid)
        
        XCTAssertFalse(sut.isSolved)
    }
    
    func testIsInvalid_nonLockedGrid() {
        let grid = TestGridBuilder(columns: 1, rows: 1)
            .build()
        let sut = NetGridController(grid: grid)
        
        XCTAssertFalse(sut.isInvalid)
    }
    
    func testIsInvalid_nonLockedGrid_loop() {
        let grid = TestGridBuilder(columns: 2, rows: 2)
            .setTile(0, 0, kind: .L, orientation: .east, locked: false)
            .setTile(1, 0, kind: .L, orientation: .south, locked: true)
            .setTile(0, 1, kind: .L, orientation: .north, locked: true)
            .setTile(1, 1, kind: .L, orientation: .west, locked: true)
            .build()
        let sut = NetGridController(grid: grid)
        
        XCTAssertFalse(sut.isInvalid)
    }
    
    func testIsInvalid_lockedGrid_loop() {
        let grid = TestGridBuilder(columns: 2, rows: 2)
            .setTile(0, 0, kind: .L, orientation: .east, locked: true)
            .setTile(1, 0, kind: .L, orientation: .south, locked: true)
            .setTile(0, 1, kind: .L, orientation: .north, locked: true)
            .setTile(1, 1, kind: .L, orientation: .west, locked: true)
            .build()
        let sut = NetGridController(grid: grid)
        
        XCTAssertTrue(sut.isInvalid)
    }
}
