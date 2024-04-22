import XCTest

@testable import LightUpSolver

class LightUpGridPrinterTests: XCTestCase {
    private var target: TestConsolePrintTarget!

    override func setUp() {
        super.setUp()

        target = TestConsolePrintTarget()
    }

    func testPrintGrid() throws {
        // Game available at:
        // https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/lightup.html#5x5:f4aBc3c3aBf
        var grid = try LightUpGridGenerator(gameId: "5x5:f4aBc3c3aBf").grid
        grid[column: 1, row: 0].state = .space(.marker)
        grid[column: 1, row: 0].state = .space(.light)
        grid[column: 2, row: 0].state = .space(.marker)
        grid[column: 0, row: 1].state = .space(.light)
        grid[column: 2, row: 1].state = .space(.light)
        grid[column: 1, row: 2].state = .space(.light)
        grid[column: 0, row: 2].state = .space(.marker)

        let sut = LightUpGridPrinter(bufferForGrid: grid)
        sut.target = target
        sut.printGrid(grid: grid)

        XCTAssertEqual(
            target.buffer,
            """
            ╭───┬───┬───┬───┬───╮
            │   │ ◌ │ ▪ │   │   │
            ├───▗▄▄▄▖───▗▄▄▄▖───┤
            │ ◌ ▐█4█▌ ◌ ▐███▌   │
            ├───▝▀▀▀▚▄▄▄▞▀▀▀▘───┤
            │ ▪ │ ◌ ▐█3█▌   │   │
            ├───▗▄▄▄▞▀▀▀▚▄▄▄▖───┤
            │   ▐█3█▌   ▐███▌   │
            ├───▝▀▀▀▘───▝▀▀▀▘───┤
            │   │   │   │   │   │
            ╰───┴───┴───┴───┴───╯


            """
        )
    }
}
