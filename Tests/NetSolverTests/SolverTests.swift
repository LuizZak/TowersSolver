import XCTest
import NetSolver

class SolverTests: XCTestCase {
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
        
        printGrid(sut.grid)
    }
    
    func testSolve_5x5_trivial() {
        // Game available at:
        // https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/net.html#5x5:85b2225e8bc17be6be5546284
        let gridGen = NetGridGenerator(rows: 5, columns: 5)
        gridGen.loadFromGameID("85b2225e8bc17be6be5546284")
        let sut = Solver(grid: gridGen.grid)
        
        XCTAssertTrue(sut.solve())
        
        printGrid(sut.grid)
    }
    
    func testSolve_7x7_trivial() {
        // Game available at:
        // https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/net.html#7x7:84387c8c5e8b859ade369c88dab9c5bb18b86be4878647b41
        let gridGen = NetGridGenerator(rows: 7, columns: 7)
        gridGen.loadFromGameID("84387c8c5e8b859ade369c88dab9c5bb18b86be4878647b41")
        let sut = Solver(grid: gridGen.grid)
        sut.maxGuesses = 0
        
        XCTAssertTrue(sut.solve())
        
        printGrid(sut.grid)
    }
    
    func testSolve_13x11_complex() {
        // Game available at:
        // https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/net.html#13x11:2e213351914861b57bb82e2a1587aca9dde5b7d268471a111e141151deb5c7e547b77dc7bd7752593d987344b31515124b613ee258daed7d8a3752de217171e2d92c978187881e1
        let gridGen = NetGridGenerator(rows: 11, columns: 13)
        gridGen.loadFromGameID("""
            2e213351914861b57bb82e2a1587aca9dde5\
            b7d268471a111e141151deb5c7e547b77dc7\
            bd7752593d987344b31515124b613ee258da\
            ed7d8a3752de217171e2d92c978187881e1
            """)
        let sut = Solver(grid: gridGen.grid)
        sut.maxGuesses = 0
        
        XCTAssertTrue(sut.solve())
        
        printGrid(sut.grid)
    }
}

private extension SolverTests {
    func printGrid(_ grid: Grid) {
        let target = TestConsolePrintTarget()
        let gridPrinter = NetGridPrinter(bufferForGridWidth: grid.columns, height: grid.rows)
        gridPrinter.target = target
        gridPrinter.printGrid(grid: grid)
        
        print(target.buffer)
    }
}
