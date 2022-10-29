import NetSolver
import XCTest

class SolverTests: XCTestCase {
    func testSolve_4x4_trivial() {
        // Game available at:
        // https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/net.html#4x4:48225b3556d73a64
        let gridGen = NetGridGenerator(columns: 4, rows: 4)
        gridGen.loadFromGameID("48225b3556d73a64")
        let sut = Solver(grid: gridGen.grid)

        XCTAssertEqual(sut.solve(), .solved)

        let controller = NetGridController(grid: sut.grid)
        // Row 0
        XCTAssertEqual(
            controller.tileKinds(forRow: 0),
            [.endPoint, .endPoint, .endPoint, .endPoint]
        )
        XCTAssertEqual(
            controller.tileOrientations(forRow: 0),
            [.south, .south, .south, .south]
        )
        // Row 1
        XCTAssertEqual(
            controller.tileKinds(forRow: 1),
            [.I, .T, .L, .I]
        )
        XCTAssertEqual(
            controller.tileOrientations(forRow: 1),
            [.north, .east, .west, .north]
        )
        // Row 2
        XCTAssertEqual(
            controller.tileKinds(forRow: 2),
            [.I, .L, .T, .T]
        )
        XCTAssertEqual(
            controller.tileOrientations(forRow: 2),
            [.north, .north, .south, .west]
        )
        // Row 3
        XCTAssertEqual(
            controller.tileKinds(forRow: 3),
            [.L, .I, .L, .endPoint]
        )
        XCTAssertEqual(
            controller.tileOrientations(forRow: 3),
            [.north, .east, .west, .north]
        )

        printGrid(sut.grid)
    }

    func testSolve_5x5_trivial() {
        // Game available at:
        // https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/net.html#5x5:85b2225e8bc17be6be5546284
        let gridGen = NetGridGenerator(columns: 5, rows: 5)
        gridGen.loadFromGameID("85b2225e8bc17be6be5546284")
        let sut = Solver(grid: gridGen.grid)

        XCTAssertEqual(sut.solve(), .solved)

        printGrid(sut.grid)
    }

    func testSolve_7x7_trivial() {
        // Game available at:
        // https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/net.html#7x7:84387c8c5e8b859ade369c88dab9c5bb18b86be4878647b41
        let gridGen = NetGridGenerator(columns: 7, rows: 7)
        gridGen.loadFromGameID("84387c8c5e8b859ade369c88dab9c5bb18b86be4878647b41")
        let sut = Solver(grid: gridGen.grid)
        sut.maxGuesses = 0

        XCTAssertEqual(sut.solve(), .solved)

        printGrid(sut.grid)
    }

    func testSolve_13x11_complex() {
        // Game available at:
        // https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/net.html#13x11:2e213351914861b57bb82e2a1587aca9dde5b7d268471a111e141151deb5c7e547b77dc7bd7752593d987344b31515124b613ee258daed7d8a3752de217171e2d92c978187881e1
        let gridGen = NetGridGenerator(columns: 13, rows: 11)
        gridGen.loadFromGameID(
            """
            2e213351914861b57bb82e2a1587aca9dde5\
            b7d268471a111e141151deb5c7e547b77dc7\
            bd7752593d987344b31515124b613ee258da\
            ed7d8a3752de217171e2d92c978187881e1
            """
        )
        let sut = Solver(grid: gridGen.grid)
        sut.maxGuesses = 0

        XCTAssertEqual(sut.solve(), .solved)

        printGrid(sut.grid)
    }

    func testSolve_5x5_wrapping_trivial() {
        // Game available at:
        // https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/net.html#5x5w:9db42c3ade3c2ba4e81a4468b
        let gridGen = NetGridGenerator(columns: 5, rows: 5, wrapping: true)
        gridGen.loadFromGameID("9db42c3ade3c2ba4e81a4468b")
        let sut = Solver(grid: gridGen.grid)
        sut.maxGuesses = 1

        XCTAssertEqual(sut.solve(), .solved)

        printGrid(sut.grid)
    }

    func testSolve_7x7_wrapping() {
        // Game available at:
        // https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/net.html#7x7w:64e843a1eb85a18e4ae7a7d8a7eb2a2dbb6171a997441a429
        let gridGen = NetGridGenerator(columns: 7, rows: 7, wrapping: true)
        gridGen.loadFromGameID("64e843a1eb85a18e4ae7a7d8a7eb2a2dbb6171a997441a429")
        let sut = Solver(grid: gridGen.grid)
        sut.maxGuesses = 0

        XCTAssertEqual(sut.solve(), .solved)

        printGrid(sut.grid)
    }

    func testSolve_13x11_wrapping() {
        // Game available at:
        // https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/net.html#13x11w:25b15d9884739de82e6251678646aa61c59d7d31bc218daa848244d3a2bb7cea4c4e3bb778eb2616c977675d7d6761ee41de3a698dae7d3a888497ccc581bba48b82b2e641b3448
        let gridGen = NetGridGenerator(columns: 13, rows: 11, wrapping: true)
        gridGen.loadFromGameID(
            """
            25b15d9884739de82e6251678646aa61c59d\
            7d31bc218daa848244d3a2bb7cea4c4e3bb7\
            78eb2616c977675d7d6761ee41de3a698dae\
            7d3a888497ccc581bba48b82b2e641b3448
            """)
        let sut = Solver(grid: gridGen.grid)
        sut.maxGuesses = 10

        XCTAssertEqual(sut.solve(), .solved)

        printGrid(sut.grid)
    }
}

extension SolverTests {
    fileprivate func printGrid(_ grid: Grid) {
        let target = TestConsolePrintTarget()
        let gridPrinter = NetGridPrinter(bufferForGridWidth: grid.columns, height: grid.rows)
        gridPrinter.target = target
        gridPrinter.printGrid(grid: grid)

        print(target.buffer)
    }
}
