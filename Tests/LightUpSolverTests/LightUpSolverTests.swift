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
        sut.maxGuesses = 10

        let result = sut.solve()

        XCTAssertEqual(result, .solved)
        XCTAssertEqual(sut.state, .solved)
        XCTAssertEqual(sut.internalState.guessesTaken, 0)
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
        sut.maxGuesses = 10

        let result = sut.solve()

        XCTAssertEqual(result, .solved)
        XCTAssertEqual(sut.state, .solved)
        XCTAssertEqual(sut.internalState.guessesTaken, 0)
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

    func testSolve_12x12_hard() throws {
        // Game available at:
        // https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/lightup.html#12x12:fBd12dB1d0BBbBaBg2dBdBd2fBd0Bc0Bg2bBgBB1aBd0a1b00c21m2aBa1a2h1d
        let gameID = "12x12:fBd12dB1d0BBbBaBg2dBdBd2fBd0Bc0Bg2bBgBB1aBd0a1b00c21m2aBa1a2h1d"
        let grid = try LightUpGridGenerator(gameId: gameID).grid
        let sut = LightUpSolver(grid: grid)
        sut.maxGuesses = 10

        let result = sut.solve()

        XCTAssertEqual(result, .solved)
        XCTAssertEqual(sut.state, .solved)
        XCTAssertEqual(sut.internalState.guessesTaken, 9)
        assertGridEquals(sut.grid, [
            [l, 2, b, l, b, b, s, s, s, l, s, s],
            [s, l, b, s, s, s, s, s, l, 2, s, s],
            [s, s, l, 2, l, s, s, s, s, 1, l, s],
            [s, s, s, s, s, s, l, s, 0, s, s, s],
            [s, s, b, s, s, s, s, l, s, s, 2, l],
            [s, b, s, l, 2, 0, s, s, 1, s, l, s],
            [b, 1, b, s, l, b, s, b, l, s, b, s],
            [s, l, s, b, s, l, 2, b, s, s, l, 1],
            [s, s, s, s, s, s, l, 1, 0, s, 1, s],
            [s, s, l, s, s, s, s, s, 0, s, s, l],
            [l, s, s, s, s, 0, b, b, s, l, 2, s],
            [1, 0, s, l, s, b, s, s, s, s, l, s],
        ])
    }

    func testSolve_20x20_hard() throws {
        // Game available at:
        // https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/lightup.html#20x20:Ba0cBBBb1cBBa1aBdBaBaBb1c1cBd1cBbBg2e0c0d1eBBBbBBBBc1Bd0BBb2aBaBc1BbBcBBBBl1b2b1aBc1b1b1iBc1BBcBc0bBeBbBB2g1B2aBaBdBb11bBaBaBaBaBdBcBBbBaBBaBaB1eBd3aBgBjBa2a0iBeB1h3bBB0c1BbBbBdBBjBdBeBe1b3b2a2bBc3i0cBc1Ba2cB
        let gameID = "20x20:Ba0cBBBb1cBBa1aBdBaBaBb1c1cBd1cBbBg2e0c0d1eBBBbBBBBc1Bd0BBb2aBaBc1BbBcBBBBl1b2b1aBc1b1b1iBc1BBcBc0bBeBbBB2g1B2aBaBdBb11bBaBaBaBaBdBcBBbBaBBaBaB1eBd3aBgBjBa2a0iBeB1h3bBB0c1BbBbBdBBjBdBeBe1b3b2a2bBc3i0cBc1Ba2cB"
        let grid = try LightUpGridGenerator(gameId: gameID).grid
        let sut = LightUpSolver(grid: grid)
        sut.maxGuesses = 10

        let result = sut.solve()

        XCTAssertEqual(result, .solved)
        XCTAssertEqual(sut.state, .solved)
        XCTAssertEqual(sut.internalState.guessesTaken, 6)
        assertGridEquals(sut.grid, [
            [b, b, b, 2, l, b, b, s, s, l, 1, b, l, b, l, 1, s, l, s, s],
            [s, s, s, l, b, b, b, l, s, b, b, l, b, l, 2, s, s, s, l, s],
            [0, s, s, s, b, s, b, 1, s, l, 2, b, b, s, s, l, b, b, 3, l],
            [s, l, s, s, b, l, b, s, s, s, l, s, s, s, 0, s, s, s, l, s],
            [s, s, l, s, s, 2, s, b, b, s, b, b, b, s, s, s, l, s, s, 0],
            [l, b, 1, s, s, l, s, s, s, s, s, s, s, s, s, s, b, l, 2, s],
            [b, l, s, 0, b, b, s, s, l, s, b, b, b, s, s, s, s, s, l, s],
            [b, b, l, s, b, s, s, l, s, b, s, l, 1, s, s, s, s, b, 2, l],
            [b, s, s, l, b, b, s, 1, 1, l, s, s, s, b, s, s, s, l, s, b],
            [l, b, b, s, b, l, s, s, b, s, s, s, s, s, l, 3, l, s, s, s],
            [s, l, s, 0, s, s, s, l, b, b, s, s, s, s, s, l, b, s, b, s],
            [1, s, l, s, s, s, s, 1, s, b, b, b, l, s, s, s, b, s, s, l],
            [l, 1, b, s, l, 1, s, s, l, 2, l, s, s, s, s, b, s, s, s, 1],
            [s, s, l, s, 1, b, s, l, s, s, s, s, b, s, b, b, s, b, l, b],
            [s, s, s, l, b, l, s, 1, b, l, 1, s, l, s, s, 0, s, l, 3, l],
            [b, l, s, 1, s, s, l, s, s, s, 1, b, s, s, l, s, s, s, s, 2],
            [b, 1, s, s, l, b, 1, s, s, s, l, b, s, s, s, s, s, s, s, l],
            [s, s, s, s, s, l, s, s, s, s, s, s, s, s, s, s, s, s, s, s],
            [1, s, s, s, s, s, l, s, 0, s, b, l, 3, l, s, 1, l, s, s, s],
            [l, s, s, s, 0, s, 2, l, s, s, s, b, l, b, b, b, s, 1, l, b],
        ])
    }

    // MARK: Test internals

    private func assertGridEquals(
        _ grid: LightUpGrid,
        _ expectedTiles: [[LightUpTile]],
        ignoreMarks: Bool = true,
        line: UInt = #line
    ) {

        var areEqual: Bool = grid.columns == expectedTiles.count && grid.rows == expectedTiles[0].count

        if areEqual && ignoreMarks {
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
        """, line: line)
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
