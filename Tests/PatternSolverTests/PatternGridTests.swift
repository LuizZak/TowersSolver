import XCTest

@testable import PatternSolver

class PatternGridTests: XCTestCase {
    // MARK: isSolved()

    func testIsSolved_emptyGrid_returnsFalse() throws {
        let gen = try PatternGridGenerator(gameId: "4x4:1/1.2/1/3/2/2/1.1/1.1")
        let sut = gen.grid

        XCTAssertFalse(sut.isSolved())
    }

    func testIsSolved_partialGrid_returnsFalse() throws {
        let gen = try PatternGridGenerator(gameId: "4x4:1/1.2/1/3/2/2/1.1/1.1")
        gen.setTileState(column: 0, row: 1, .light)
        gen.setTileState(column: 1, row: 1, .light)
        gen.setTileState(column: 2, row: 1, .dark)
        gen.setTileState(column: 3, row: 1, .dark)
        let sut = gen.grid

        XCTAssertFalse(sut.isSolved())
    }

    func testIsSolved_darkTilesOnly_returnsFalse() throws {
        let gen = try PatternGridGenerator(gameId: "4x4:1/1.2/1/3/2/2/1.1/1.1")
        gen.setTileState(column: 0, row: 0, .dark)
        gen.setTileState(column: 1, row: 0, .dark)
        gen.setTileState(column: 2, row: 1, .dark)
        gen.setTileState(column: 3, row: 1, .dark)
        gen.setTileState(column: 1, row: 2, .dark)
        gen.setTileState(column: 3, row: 2, .dark)
        gen.setTileState(column: 1, row: 3, .dark)
        gen.setTileState(column: 3, row: 3, .dark)
        let sut = gen.grid

        XCTAssertFalse(sut.isSolved())
    }

    func testIsSolved_filledGridInvalid_returnsFalse() throws {
        let gen = try PatternGridGenerator(gameId: "4x4:1/1.2/1/3/2/2/1.1/1.1")
        // Row 0
        gen.setTileState(column: 0, row: 0, .light)
        gen.setTileState(column: 1, row: 0, .dark)
        gen.setTileState(column: 2, row: 0, .light)
        gen.setTileState(column: 3, row: 0, .dark)
        // Row 1
        gen.setTileState(column: 0, row: 1, .light)
        gen.setTileState(column: 1, row: 1, .dark)
        gen.setTileState(column: 2, row: 1, .light)
        gen.setTileState(column: 3, row: 1, .dark)
        // Row 2
        gen.setTileState(column: 0, row: 2, .dark)
        gen.setTileState(column: 1, row: 2, .light)
        gen.setTileState(column: 2, row: 2, .light)
        gen.setTileState(column: 3, row: 2, .dark)
        // Row 3
        gen.setTileState(column: 0, row: 3, .dark)
        gen.setTileState(column: 1, row: 3, .light)
        gen.setTileState(column: 2, row: 3, .dark)
        gen.setTileState(column: 3, row: 3, .dark)
        let sut = gen.grid

        XCTAssertFalse(sut.isSolved())
    }

    func testIsSolved_fullySolvedGrid_returnsTrue() throws {
        let gen = try PatternGridGenerator(gameId: "4x4:1/1.2/1/3/2/2/1.1/1.1")
        // Row 0
        gen.setTileState(column: 0, row: 0, .dark)
        gen.setTileState(column: 1, row: 0, .dark)
        gen.setTileState(column: 2, row: 0, .light)
        gen.setTileState(column: 3, row: 0, .light)
        // Row 1
        gen.setTileState(column: 0, row: 1, .light)
        gen.setTileState(column: 1, row: 1, .light)
        gen.setTileState(column: 2, row: 1, .dark)
        gen.setTileState(column: 3, row: 1, .dark)
        // Row 2
        gen.setTileState(column: 0, row: 2, .light)
        gen.setTileState(column: 1, row: 2, .dark)
        gen.setTileState(column: 2, row: 2, .light)
        gen.setTileState(column: 3, row: 2, .dark)
        // Row 3
        gen.setTileState(column: 0, row: 3, .light)
        gen.setTileState(column: 1, row: 3, .dark)
        gen.setTileState(column: 2, row: 3, .light)
        gen.setTileState(column: 3, row: 3, .dark)
        let sut = gen.grid

        XCTAssertTrue(sut.isSolved())
    }

    // MARK: isValid()
    func testIsValid_emptyGrid_returnsTrue() throws {
        let gen = try PatternGridGenerator(gameId: "4x4:1/1.2/1/3/2/2/1.1/1.1")
        let sut = gen.grid

        XCTAssertTrue(sut.isValid())
    }

    func testIsValid_partialGrid_returnsTrue() throws {
        let gen = try PatternGridGenerator(gameId: "4x4:1/1.2/1/3/2/2/1.1/1.1")
        gen.setTileState(column: 0, row: 1, .light)
        gen.setTileState(column: 1, row: 1, .light)
        gen.setTileState(column: 2, row: 1, .dark)
        gen.setTileState(column: 3, row: 1, .dark)
        let sut = gen.grid

        XCTAssertTrue(sut.isValid())
    }

    func testIsValid_darkTilesOnly_returnsTrue() throws {
        let gen = try PatternGridGenerator(gameId: "4x4:1/1.2/1/3/2/2/1.1/1.1")
        gen.setTileState(column: 0, row: 0, .dark)
        gen.setTileState(column: 1, row: 0, .dark)
        gen.setTileState(column: 2, row: 1, .dark)
        gen.setTileState(column: 3, row: 1, .dark)
        gen.setTileState(column: 1, row: 2, .dark)
        gen.setTileState(column: 3, row: 2, .dark)
        gen.setTileState(column: 1, row: 3, .dark)
        gen.setTileState(column: 3, row: 3, .dark)
        let sut = gen.grid

        XCTAssertTrue(sut.isValid())
    }

    func testIsValid_darkTilesOnly_invalid_returnsTrue() throws {
        let gen = try PatternGridGenerator(gameId: "4x4:1/1.2/1/3/2/2/1.1/1.1")
        gen.setTileState(column: 0, row: 0, .dark)
        gen.setTileState(column: 1, row: 0, .dark)
        gen.setTileState(column: 2, row: 0, .dark)
        gen.setTileState(column: 3, row: 0, .dark)
        let sut = gen.grid

        XCTAssertFalse(sut.isValid())
    }

    func testIsValid_filledGridInvalid_returnsFalse() throws {
        let gen = try PatternGridGenerator(gameId: "4x4:1/1.2/1/3/2/2/1.1/1.1")
        // Row 0
        gen.setTileState(column: 0, row: 0, .light)
        gen.setTileState(column: 1, row: 0, .dark)
        gen.setTileState(column: 2, row: 0, .light)
        gen.setTileState(column: 3, row: 0, .dark)
        // Row 1
        gen.setTileState(column: 0, row: 1, .light)
        gen.setTileState(column: 1, row: 1, .dark)
        gen.setTileState(column: 2, row: 1, .light)
        gen.setTileState(column: 3, row: 1, .dark)
        // Row 2
        gen.setTileState(column: 0, row: 2, .dark)
        gen.setTileState(column: 1, row: 2, .light)
        gen.setTileState(column: 2, row: 2, .light)
        gen.setTileState(column: 3, row: 2, .dark)
        // Row 3
        gen.setTileState(column: 0, row: 3, .dark)
        gen.setTileState(column: 1, row: 3, .light)
        gen.setTileState(column: 2, row: 3, .dark)
        gen.setTileState(column: 3, row: 3, .dark)
        let sut = gen.grid

        XCTAssertFalse(sut.isValid())
    }

    func testIsValid_fullySolvedGrid_returnsTrue() throws {
        let gen = try PatternGridGenerator(gameId: "4x4:1/1.2/1/3/2/2/1.1/1.1")
        // Row 0
        gen.setTileState(column: 0, row: 0, .dark)
        gen.setTileState(column: 1, row: 0, .dark)
        gen.setTileState(column: 2, row: 0, .light)
        gen.setTileState(column: 3, row: 0, .light)
        // Row 1
        gen.setTileState(column: 0, row: 1, .light)
        gen.setTileState(column: 1, row: 1, .light)
        gen.setTileState(column: 2, row: 1, .dark)
        gen.setTileState(column: 3, row: 1, .dark)
        // Row 2
        gen.setTileState(column: 0, row: 2, .light)
        gen.setTileState(column: 1, row: 2, .dark)
        gen.setTileState(column: 2, row: 2, .light)
        gen.setTileState(column: 3, row: 2, .dark)
        // Row 3
        gen.setTileState(column: 0, row: 3, .light)
        gen.setTileState(column: 1, row: 3, .dark)
        gen.setTileState(column: 2, row: 3, .light)
        gen.setTileState(column: 3, row: 3, .dark)
        let sut = gen.grid

        XCTAssertTrue(sut.isValid())
    }
}
