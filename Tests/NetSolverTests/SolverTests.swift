import XCTest
import NetSolver

class NetSolverTests: XCTestCase {
    func testSolve_4x4_trivial() {
        // Game available at:
        // https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/net.html#4x4:48225b3556d73a64
        let gridGen = NetGridGenerator(rows: 4, columns: 4)
        gridGen.loadFromGameID("48225b3556d73a64")
        let sut = Solver(grid: gridGen.grid)
        
        XCTAssertTrue(sut.solve())
        
        let controller = NetGridController(grid: sut.grid)
        // Row 0
        XCTAssertEqual(controller.tileKinds(forRow: 0),
                       [.endPoint, .endPoint, .endPoint, .endPoint])
        XCTAssertEqual(controller.tileOrientations(forRow: 0),
                       [.south, .south, .south, .south])
        // Row 1
        XCTAssertEqual(controller.tileKinds(forRow: 1),
                       [.I, .T, .L, .I])
        XCTAssertEqual(controller.tileOrientations(forRow: 1),
                       [.north, .east, .west, .north])
        // Row 2
        XCTAssertEqual(controller.tileKinds(forRow: 2),
                       [.I, .L, .T, .T])
        XCTAssertEqual(controller.tileOrientations(forRow: 2),
                       [.north, .north, .south, .west])
        // Row 3
        XCTAssertEqual(controller.tileKinds(forRow: 3),
                       [.L, .I, .L, .endPoint])
        XCTAssertEqual(controller.tileOrientations(forRow: 3),
                       [.north, .east, .west, .north])
        
        let target = TestConsolePrintTarget()
        let gridPrinter = NetGridPrinter(bufferForGridWidth: 4, height: 4)
        gridPrinter.target = target
        gridPrinter.printGrid(grid: sut.grid)
        
        print(target.buffer)
    }
}
