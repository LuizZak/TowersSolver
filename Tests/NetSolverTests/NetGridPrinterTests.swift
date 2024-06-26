import Console
import NetSolver
import XCTest

class NetGridPrinterTests: XCTestCase {
    private var target: StringBufferConsolePrintTarget!

    override func setUp() {
        super.setUp()

        target = StringBufferConsolePrintTarget()
    }

    func testPrintGrid5x5() {
        // Game available at:
        // https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/net.html#5x5:4d63229e74cebbc553e521822
        let gen = NetGridGenerator(columns: 5, rows: 5)
        gen.loadFromGameID("4d63229e74cebbc553e521822")
        let sut = NetGridPrinter(bufferWidth: 42, bufferHeight: 22)
        sut.target = target
        sut.printGrid(grid: gen.grid)

        XCTAssertEqual(
            target.buffer,
            """
            ╭───────┬───────┬───┬───┬───┬───┬───┬───╮
            │       │       │   │   │   │   │   │   │
            ├───■   ├───┬───┼───╯   │   ╰───┤   ■   │
            │       │   │   │       │       │       │
            ├───┬───┼───┴───┼───┬───┼───┬───┼───────┤
            │   │   │       │   │   │   │   │       │
            │   ■   │   ╭───┼───┤   ├───┴───┼───■   │
            │       │   │   │   │   │       │       │
            ├───────┼───┼───┼───┼───┼───┬───┼───────┤
            │       │   │   │   │   │   │   │       │
            ├───╮   ├───┤   │   ■───┤   ├───┼───╮   │
            │   │   │   │   │   │   │   │   │   │   │
            ├───┴───┼───┴───┼───┼───┼───┼───┼───┴───┤
            │       │       │   │   │   │   │       │
            ├───────┼───────┤   ╰───┼───┤   ├───────┤
            │       │       │       │   │   │       │
            ├───┬───┼───────┼───────┼───┼───┼───┬───┤
            │   │   │       │       │   │   │   │   │
            │   ■   │   ■───┤   ■   │   ■   │   ■   │
            │       │       │   │   │       │       │
            ╰───────┴───────┴───┴───┴───────┴───────╯


            """
        )
    }
}
