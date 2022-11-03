import XCTest
import Console

@testable import PatternSolver

class PatternGridPrinterTests: XCTestCase {
    private var target: TestConsolePrintTarget!

    override func setUp() {
        super.setUp()

        target = TestConsolePrintTarget()
    }

    func testPrintGrid_5x5() throws {
        // Game available at:
        // https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/pattern.html#5x5:1/2/1.1/2.2/2.2/4/1.2/1/2/3
        let gen = try PatternGridGenerator(gameId: "5x5:1/2/1.1/2.2/2.2/4/1.2/1/2/3")
        gen.setTileState(column: 1, row: 0, .dark)
        gen.setTileState(column: 2, row: 0, .dark)
        gen.setTileState(column: 3, row: 0, .dark)
        gen.setTileState(column: 1, row: 1, .dark)
        gen.setTileState(column: 2, row: 1, .light)
        gen.setTileState(column: 1, row: 2, .dark)
        gen.setTileState(column: 2, row: 2, .dark)
        let sut = PatternGridPrinter(bufferForGrid: gen.grid)
        sut.target = target
        sut.printGrid(grid: gen.grid)

        XCTAssertEqual(
            target.buffer,
            """
                          1   2   2
                  1   2   1   2   2
                ╭───▗▄▄▄▄▄▄▄▄▄▄▄▖───╮
              4 │???▐███████████▌???│
                ├───▐███▛▀▀▀▀▀▀▀▘───┤
            1 2 │???▐███▌   │???│???│
                ├───▐███▙▄▄▄▖───┼───┤
              1 │???▐███████▌???│???│
                ├───▝▀▀▀▀▀▀▀▘───┼───┤
              2 │???│???│???│???│???│
                ├───┼───┼───┼───┼───┤
              3 │???│???│???│???│???│
                ╰───┴───┴───┴───┴───╯


            """
        )
    }

    func testPrintGrid_5x5_fullBox() throws {
        // Game available at:
        // https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/pattern.html#5x5:1/2/1.1/2.2/2.2/4/1.2/1/2/3
        let gen = try PatternGridGenerator(gameId: "5x5:1/2/1.1/2.2/2.2/4/1.2/1/2/3")
        gen.setTileState(column: 1, row: 0, .dark)
        gen.setTileState(column: 2, row: 0, .dark)
        gen.setTileState(column: 3, row: 0, .dark)
        gen.setTileState(column: 0, row: 1, .light)
        gen.setTileState(column: 1, row: 1, .dark)
        gen.setTileState(column: 2, row: 1, .dark)
        gen.setTileState(column: 3, row: 1, .dark)
        gen.setTileState(column: 1, row: 2, .dark)
        gen.setTileState(column: 2, row: 2, .dark)
        gen.setTileState(column: 4, row: 2, .dark)
        gen.setTileState(column: 3, row: 3, .dark)
        gen.setTileState(column: 1, row: 4, .dark)
        gen.setTileState(column: 2, row: 4, .dark)
        let sut = PatternGridPrinter(bufferForGrid: gen.grid)
        sut.target = target
        sut.printGrid(grid: gen.grid)

        XCTAssertEqual(
            target.buffer,
            """
                          1   2   2
                  1   2   1   2   2
                ╭───▗▄▄▄▄▄▄▄▄▄▄▄▖───╮
              4 │???▐███████████▌???│
                ├───▐███████████▌───┤
            1 2 │   ▐███████████▌???│
                ├───▐███████▛▀▀▀▚▄▄▄▖
              1 │???▐███████▌???▐███▌
                ├───▝▀▀▀▀▀▀▀▚▄▄▄▞▀▀▀▘
              2 │???│???│???▐███▌???│
                ├───▗▄▄▄▄▄▄▄▞▀▀▀▘───┤
              3 │???▐███████▌???│???│
                ╰───▝▀▀▀▀▀▀▀▘───┴───╯


            """
        )
    }
}

internal class TestConsolePrintTarget: ConsolePrintTarget {
    var supportsTerminalColors: Bool {
        return false
    }

    var buffer: String = ""

    func print(_ values: [Any], separator: String, terminator: String) {
        let total = values.map { String(describing: $0) }.joined(separator: separator)

        Swift.print(total, terminator: terminator, to: &buffer)
    }
}
