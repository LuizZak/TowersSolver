import XCTest

@testable import LightUpSolver

class LightUpGridGeneratorTests: XCTestCase {
    func testInitFromGameId() throws {
        let s = LightUpTile(state: .space(.empty))
        let b = LightUpTile(state: .wall())

        // Game available at:
        // https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/lightup.html#5x5:f4aBc3c3aBf
        let sut = try LightUpGridGenerator(gameId: "5x5:f4aBc3c3aBf")

        let result = sut.grid

        XCTAssertEqual(result.columns, 5)
        XCTAssertEqual(result.rows, 5)
        XCTAssertEqual(result.tiles, [
            [s, s, s, s, s],
            [s, 4, s, 3, s],
            [s, s, 3, s, s],
            [s, b, s, b, s],
            [s, s, s, s, s],
        ])
    }
}
