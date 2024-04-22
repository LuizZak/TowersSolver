import XCTest

@testable import LightUpSolver

class LightUpSolverTests: XCTestCase {
    let s = LightUpTile(state: .space(.empty))
    let l = LightUpTile(state: .space(.light))
    let b = LightUpTile(state: .wall())

    func testSolve_12x12_easy() throws {
        // Game available at:
        // https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/lightup.html#12x12:cBa1fBb2aBcBd2d3f1cBf0BaBbBaBhBaBBB2c2Ba2b0c1cBBfBBBaBa0o2aBBb0r
        let gameID = "12x12:cBa1fBb2aBcBd2d3f1cBf0BaBbBaBhBaBBB2c2Ba2b0c1cBBfBBBaBa0o2aBBb0r"
        let grid = try LightUpGridGenerator(gameId: gameID).grid
        let sut = LightUpSolver(grid: grid)

        let result = sut.solve()

        XCTAssertEqual(result, .solved)
        XCTAssertEqual(sut.state, .solved)
        assertGridEquals(sut.grid, [
            [l, b, s, s, s, s, s, l, s, s, s, s],
            [s, s, l, s, 0, s, s, 1, b, s, b, s],
            [s, l, 2, 1, b, s, l, s, b, s, b, s],
            [b, 2, s, l, s, s, 2, l, b, s, l, s],
            [s, l, s, s, b, l, b, s, l, s, s, s],
            [1, b, s, s, s, s, l, b, b, s, 0, s],
            [l, s, s, b, l, b, 2, b, s, s, s, l],
            [s, l, 3, l, b, s, l, s, 0, s, s, s],
            [s, s, l, s, s, b, s, l, s, s, s, s],
            [s, b, s, s, b, b, 0, s, l, s, s, s],
            [s, l, s, s, s, b, s, s, s, l, s, s],
            [s, s, s, s, l, 2, l, s, s, 2, l, s],
        ])
    }

    func testSolve_12x12_tricky() throws {
        // Game available at:
        // https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/lightup.html#12x12:bBbBf0f1l1b2Bb1dBk1eB1b2aBi2Bd1cBb1bBfBeBa10b0BBkBaB3bBBcBaBBaB
        let gameID = "12x12:bBbBf0f1l1b2Bb1dBk1eB1b2aBi2Bd1cBb1bBfBeBa10b0BBkBaB3bBBcBaBBaB"
        let grid = try LightUpGridGenerator(gameId: gameID).grid
        let sut = LightUpSolver(grid: grid)

        let result = sut.solve()

        XCTAssertEqual(result, .solved)
        XCTAssertEqual(sut.state, .solved)
        assertGridEquals(sut.grid, [
            [s, 0, s, b, s, l, s, 1, l, s, s, s],
            [l, s, s, s, s, s, s, s, s, 1, l, b],
            [b, l, s, s, s, b, s, s, s, 0, s, b],
            [s, s, l, 1, s, 1, s, l, s, s, s, s],
            [s, s, s, s, s, l, s, b, s, s, s, l],
            [b, s, s, s, s, s, l, s, b, 0, s, s],
            [s, s, s, s, l, 2, 2, l, s, b, s, b],
            [s, 1, s, s, s, l, b, 1, s, b, b, l],
            [s, l, 1, b, 1, b, s, s, l, s, s, b],
            [s, s, s, s, l, s, s, s, s, s, b, b],
            [s, s, l, s, s, s, s, b, s, l, 3, l],
            [l, s, 2, l, s, s, s, s, b, s, l, b],
        ])
    }

    // MARK: Test internals

    private func assertGridEquals(
        _ grid: LightUpGrid,
        _ expectedTiles: [[LightUpTile]],
        ignoreMarks: Bool = true,
        line: UInt = #line
    ) {

        var areEqual: Bool = true

        if ignoreMarks {
            if grid.columns != expectedTiles.count || grid.rows != expectedTiles[0].count {
                areEqual = false
            }

            for column in 0..<grid.columns {
                for row in 0..<grid.rows {
                    switch (expectedTiles[column][row].state, grid[column: column, row: row].state) {
                    case (.wall(let lhs), .wall(hint: let rhs)) where lhs != rhs:
                        areEqual = false
                    case (.space(.empty), .space(.light)), (.space(.light), .space(.empty)):
                        areEqual = false
                    default:
                        break
                    }
                }
            }
        } else {
            areEqual = grid.tiles == expectedTiles
        }

        if areEqual {
            print(grid.asString(terminalColorized: true))
        }

        XCTAssert(areEqual, """
        Grids are not equal.
        Actual:

        \(grid.asString(terminalColorized: true))

        Expected:
        \(LightUpGrid(tiles: expectedTiles).asString(terminalColorized: true))
        """)
    }

    private func printAsColumnArray(_ grid: LightUpGrid) {
        var buffer = ""

        for column in grid.tiles {
            buffer += "["

            let items = column.map {
                switch $0.state {
                case .wall(let hint?):
                    return hint.description

                case .wall(nil):
                    return "b"

                case .space(.empty), .space(.marker):
                    return "s"
                
                case .space(.light):
                    return "l"
                }
            }

            buffer += items.joined(separator: ", ")
            buffer += "],\n"
        }

        print(buffer.trimmingCharacters(in: .newlines))
    }
}
