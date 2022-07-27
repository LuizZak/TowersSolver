import XCTest

@testable import SignpostSolver

class GridTests: XCTestCase {
    func testEffectiveNumberForTile_connectedToStart() {
        // Game available at:
        // https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/signpost.html#3x3:1deecaaag9a
        let gen = SignpostGridGenerator(rows: 3, columns: 3)
        gen.loadFromGameID("1deecaaag9a")
        gen.grid[column: 0, row: 0].connectionState = .connectedTo(Coordinates(column: 1, row: 1))
        gen.grid[column: 1, row: 1].connectionState = .connectedTo(Coordinates(column: 1, row: 0))
        let sut = gen.grid

        let result = sut.effectiveNumberForTile(column: 1, row: 0)

        XCTAssertEqual(result, 3)
    }

    func testEffectiveNumberForTile_connectedToEnd() {
        // Game available at:
        // https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/signpost.html#3x3:1deecaaag9a
        let gen = SignpostGridGenerator(rows: 3, columns: 3)
        gen.loadFromGameID("1deecaaag9a")
        gen.grid[column: 2, row: 0].connectionState = .connectedTo(Coordinates(column: 2, row: 2))
        gen.grid[column: 2, row: 1].connectionState = .connectedTo(Coordinates(column: 2, row: 0))
        let sut = gen.grid

        let result = sut.effectiveNumberForTile(column: 2, row: 1)

        XCTAssertEqual(result, 7)
    }
}
