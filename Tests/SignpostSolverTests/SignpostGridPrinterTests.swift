import XCTest
import Console

@testable import SignpostSolver

class SignpostGridPrinterTests: XCTestCase {
    private var target: TestConsolePrintTarget!

    override func setUp() {
        super.setUp()

        target = TestConsolePrintTarget()
    }

    func testPrintGrid_3x3_unsolved() {
        // Game available at:
        // https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/signpost.html#3x3:1deecaaag9a
        let gen = SignpostGridGenerator(rows: 3, columns: 3)
        gen.loadFromGameID("1deecaaag9a")
        let sut = SignpostGridPrinter(bufferWidth: 20, bufferHeight: 11)
        sut.target = target
        sut.printGrid(grid: gen.grid)

        XCTAssertEqual(
            target.buffer,
            """
            ╭─────┬─────┬─────╮
            │ 1   │     │     │
            │   ↘ │ • ↓ │ • ↓ │
            ├─────┼─────┼─────┤
            │     │     │     │
            │ • → │ • ↑ │ • ↑ │
            ├─────┼─────┼─────┤
            │     │     │ 9   │
            │ • ↑ │ • ← │   * │
            ╰─────┴─────┴─────╯


            """
        )
    }

    func testPrintGrid_3x3_solved() {
        // Game available at:
        // https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/signpost.html#3x3:1d3e8e6c2a7a5a4g9a
        let gen = SignpostGridGenerator(rows: 3, columns: 3)
        gen.loadFromGameID("1d3e8e6c2a7a5a4g9a")
        let sut = SignpostGridPrinter(bufferWidth: 20, bufferHeight: 11)
        sut.target = target
        sut.printGrid(grid: gen.grid)

        XCTAssertEqual(
            target.buffer,
            """
            ╭─────┬─────┬─────╮
            │ 1   │ 3   │ 8   │
            │   ↘ │   ↓ │   ↓ │
            ├─────┼─────┼─────┤
            │ 6   │ 2   │ 7   │
            │   → │   ↑ │   ↑ │
            ├─────┼─────┼─────┤
            │ 5   │ 4   │ 9   │
            │   ↑ │   ← │   * │
            ╰─────┴─────┴─────╯


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
