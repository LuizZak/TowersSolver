import XCTest

@testable import PatternSolver

class PatternGridGeneratorTests: XCTestCase {
    func testParseGameId_10x10() throws {
        let sut = try makeSut("10x10:4.3/4.3/1.1.1/3/1.2/6/3.2/2.3.1/5/5/2.4/2.3/2.2/3.1/3/8/1.3/4.3/2.2/2.3")

        let grid = sut.grid

        XCTAssertEqual(sut.columns, 10)
        XCTAssertEqual(sut.rows, 10)
        XCTAssertEqual(grid.columns, 10)
        XCTAssertEqual(grid.rows, 10)
        XCTAssertEqual(grid.hints, [
            // Columns
            .init(runs: [4, 3]),
            .init(runs: [4, 3]),
            .init(runs: [1, 1, 1]),
            .init(runs: [3]),
            .init(runs: [1, 2]),
            .init(runs: [6]),
            .init(runs: [3, 2]),
            .init(runs: [2, 3, 1]),
            .init(runs: [5]),
            .init(runs: [5]),
            // Rows
            .init(runs: [2, 4]),
            .init(runs: [2, 3]),
            .init(runs: [2, 2]),
            .init(runs: [3, 1]),
            .init(runs: [3]),
            .init(runs: [8]),
            .init(runs: [1, 3]),
            .init(runs: [4, 3]),
            .init(runs: [2, 2]),
            .init(runs: [2, 3]),
        ])
    }

    func testParseGameId_gridSquareSyntax_2x2() throws {
        let sut = try makeSut("2:1/1/1/1")

        let grid = sut.grid

        XCTAssertEqual(sut.columns, 2)
        XCTAssertEqual(sut.rows, 2)
        XCTAssertEqual(grid.columns, 2)
        XCTAssertEqual(grid.rows, 2)
        XCTAssertEqual(grid.hints, [
            // Columns
            .init(runs: [1]),
            .init(runs: [1]),
            // Rows
            .init(runs: [1]),
            .init(runs: [1]),
        ])
    }

    func testParseGameId_hintMatchesGridSize_doesNotThrowError() {
        XCTAssertNoThrow(try makeSut("2:2/1/1/1"))
    }

    func testParseGameId_hintsExceedGridSize_throwsError() {
        XCTAssertThrowsError(try makeSut("2:3/1/1/1"))   // Run too large
        XCTAssertThrowsError(try makeSut("2:1.1/1/1/1")) // Not enough space between hints
    }

    func testParseGameId_notEnoughHints_throwsError() {
        XCTAssertThrowsError(try makeSut("2:1/1"))
    }

    func testParseGameId_tooManyHints_throwsError() {
        XCTAssertThrowsError(try makeSut("2:1/1/1/1/1/1"))
    }

    private func makeSut(_ gameId: String) throws -> PatternGridGenerator {
        try PatternGridGenerator(gameId: gameId)
    }
}
