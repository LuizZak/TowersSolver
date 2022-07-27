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
            │ • ↑ │ • ← │ • * │
            ╰─────┴─────┴─────╯


            """
        )
    }

    func testPrintGrid_3x3_unsolved_connections() {
        // Game available at:
        // https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/signpost.html#3x3:1deecaaag9a
        let gen = SignpostGridGenerator(rows: 3, columns: 3)
        gen.loadFromGameID("1deecaaag9a")
        gen.grid[column: 1, row: 0].connectionState = .connectedTo(Coordinates(column: 1, row: 2))
        gen.grid[column: 0, row: 2].connectionState = .connectedTo(Coordinates(column: 0, row: 1))
        let sut = SignpostGridPrinter(bufferWidth: 20, bufferHeight: 11)
        sut.target = target
        sut.printGrid(grid: gen.grid)

        XCTAssertEqual(
            target.buffer,
            """
            ╭─────┬─────┬─────╮
            │ 1   │ a   │     │
            │   ↘ │ • ↓ │ • ↓ │
            ├─────┼─────┼─────┤
            │ b+1 │     │     │
            │   → │ • ↑ │ • ↑ │
            ├─────┼─────┼─────┤
            │ b   │ a+1 │ 9   │
            │ • ↑ │   ← │ • * │
            ╰─────┴─────┴─────╯


            """
        )
    }

    func testPrintGrid_3x3_unsolved_connections_skipsNumberedSequences() {
        // Game available at:
        // https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/signpost.html#3x3:1deecaaag9a
        let gen = SignpostGridGenerator(rows: 3, columns: 3)
        gen.loadFromGameID("1deecaaag9a")
        gen.grid[column: 0, row: 0].connectionState = .connectedTo(Coordinates(column: 1, row: 1))
        gen.grid[column: 0, row: 2].connectionState = .connectedTo(Coordinates(column: 0, row: 1))
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
            │ a+1 │ 2   │     │
            │   → │   ↑ │ • ↑ │
            ├─────┼─────┼─────┤
            │ a   │     │ 9   │
            │ • ↑ │ • ← │ • * │
            ╰─────┴─────┴─────╯


            """
        )
    }

    func testPrintGrid_3x3_unsolved_connectionsWithNumbers_forwards() {
        // Game available at:
        // https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/signpost.html#3x3:1deecaaag9a
        let gen = SignpostGridGenerator(rows: 3, columns: 3)
        gen.loadFromGameID("1deecaaag9a")
        gen.grid[column: 0, row: 0].connectionState = .connectedTo(Coordinates(column: 1, row: 1))
        gen.grid[column: 1, row: 1].connectionState = .connectedTo(Coordinates(column: 1, row: 0))
        let sut = SignpostGridPrinter(bufferWidth: 20, bufferHeight: 11)
        sut.target = target
        sut.printGrid(grid: gen.grid)

        XCTAssertEqual(
            target.buffer,
            """
            ╭─────┬─────┬─────╮
            │ 1   │ 3   │     │
            │   ↘ │   ↓ │ • ↓ │
            ├─────┼─────┼─────┤
            │     │ 2   │     │
            │ • → │   ↑ │ • ↑ │
            ├─────┼─────┼─────┤
            │     │     │ 9   │
            │ • ↑ │ • ← │ • * │
            ╰─────┴─────┴─────╯


            """
        )
    }

    func testPrintGrid_3x3_unsolved_connectionsWithNumbers_backwards() {
        // Game available at:
        // https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/signpost.html#3x3:1deecaaag9a
        let gen = SignpostGridGenerator(rows: 3, columns: 3)
        gen.loadFromGameID("1deecaaag9a")
        gen.grid[column: 2, row: 0].connectionState = .connectedTo(Coordinates(column: 2, row: 2))
        gen.grid[column: 2, row: 1].connectionState = .connectedTo(Coordinates(column: 2, row: 0))
        let sut = SignpostGridPrinter(bufferWidth: 20, bufferHeight: 11)
        sut.target = target
        sut.printGrid(grid: gen.grid)

        XCTAssertEqual(
            target.buffer,
            """
            ╭─────┬─────┬─────╮
            │ 1   │     │ 8   │
            │   ↘ │ • ↓ │   ↓ │
            ├─────┼─────┼─────┤
            │     │     │ 7   │
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
