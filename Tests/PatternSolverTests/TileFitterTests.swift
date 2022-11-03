import XCTest

@testable import PatternSolver

class TileFitterTests: XCTestCase {
    // MARK: - fitRunsEarliest

    func testFitRunsEarliest_fullFill_emptyTiles_singleHint() {
        // Runs:
        // [O][O]
        //
        // Tiles: (O = dark, ▋ = light, empty = undecided)
        // [ ][ ]
        //
        // Expected result:
        // [O][O]
        let sut = makeSut(hint: [2], tiles: tiles(
            .undecided,
            .undecided
        ))

        let result = sut.fitRunsEarliest()

        XCTAssertEqual(result, [
            .init(start: 0, end: 1),
        ])
    }

    func testFitRunsEarliest_partialFill_emptyTiles_singleHint() {
        // Runs:
        // [O][O]
        //
        // Tiles: (O = dark, ▋ = light, empty = undecided)
        // [ ][ ][ ]
        //
        // Expected result:
        // [O][O][ ]
        let sut = makeSut(hint: [2], tiles: tiles(
            .undecided,
            .undecided,
            .undecided
        ))

        let result = sut.fitRunsEarliest()

        XCTAssertEqual(result, [
            .init(start: 0, end: 1),
        ])
    }

    func testFitRunsEarliest_partialFill_lastHintFilled_singleHint() {
        // Runs:
        // [O][O]
        //
        // Tiles: (O = dark, ▋ = light, empty = undecided)
        // [ ][ ][ ][ ][O]
        //
        // Expected result:
        // [ ][ ][ ][O][O]
        let sut = makeSut(hint: [2], tiles: tiles(
            .undecided,
            .undecided,
            .undecided,
            .undecided,
            .dark
        ))

        let result = sut.fitRunsEarliest()

        XCTAssertEqual(result, [
            .init(start: 3, end: 4),
        ])
    }

    func testFitRunsEarliest_trailingRuns() {
        // Runs:
        // [O][O]
        // [O][O][O][O]
        //
        // Tiles: (O = dark, ▋ = light, empty = undecided)
        // [ ][O][ ][ ][ ][O][O][ ][ ]
        //
        // Expected result:
        // [O][O][ ][O][O][O][O][ ][ ]
        let sut = makeSut(hint: [2, 4], tiles: tiles(
            .undecided,
            .dark,
            .undecided,
            .undecided,
            .undecided,
            .dark,
            .dark,
            .undecided,
            .undecided
        ))

        let result = sut.fitRunsEarliest()

        XCTAssertEqual(result, [
            .init(start: 0, end: 1),
            .init(start: 3, end: 6),
        ])
    }

    func testFitRunsEarliest_prefilledTiles() {
        // Runs:
        // [O][O][O]
        // [O][O][O][O]
        // [O][O]
        //
        // Tiles: (O = dark, ▋ = light, empty = undecided)
        // [ ][O][ ][ ][ ][O][ ][O][O][▋][ ][ ][O][ ][ ][ ]
        //
        // Expected result:
        // [O][O][O][ ][ ][O][O][O][O][▋][ ][O][O][ ][ ][ ]
        let sut = makeSut(hint: [3, 4, 2], tiles: tiles(
            .undecided,
            .dark,
            .undecided,
            .undecided,
            .undecided,
            .dark,
            .undecided,
            .dark,
            .dark,
            .light,
            .undecided,
            .undecided,
            .dark,
            .undecided,
            .undecided,
            .undecided
        ))

        let result = sut.fitRunsEarliest()

        XCTAssertEqual(result, [
            .init(start: 0, end: 2),
            .init(start: 5, end: 8),
            .init(start: 11, end: 12),
        ])
    }

    func testFitRunsEarliest_singleTileFits() {
        // Runs:
        // [O][O][O][O]
        // [O]
        // [O]
        //
        // Tiles: (O = dark, ▋ = light, empty = undecided)
        // [O][O][O][O][ ][ ][ ][O][▋][▋]
        //
        // Expected result:
        // [O][O][O][O][ ][O][ ][O][▋][▋]
        let sut = makeSut(hint: [4, 1, 1], tiles: tiles(
            .dark,
            .dark,
            .dark,
            .dark,
            .undecided,
            .undecided,
            .undecided,
            .dark,
            .light,
            .light
        ))

        let result = sut.fitRunsEarliest()

        XCTAssertEqual(result, [
            .init(start: 0, end: 3),
            .init(start: 5, end: 5),
            .init(start: 7, end: 7),
        ])
    }

    func testFitRunsEarliest_undecidedSpaceFit() {
        // Runs:
        // [O]
        // [O][O][O][O]
        // [O]
        // [O][O]
        //
        // Tiles: (O = dark, ▋ = light, empty = undecided)
        // [O][ ][ ][ ][▋][O][O][O][O][O][▋][ ][▋][O][O]
        //
        // Expected result:
        // [O][ ][ ][ ][▋][O][O][O][O][O][▋][O][▋][O][O]
        let sut = makeSut(hint: [1, 5, 1, 2], tiles: tiles(
            .dark,
            .undecided,
            .undecided,
            .undecided,
            .light,
            .dark,
            .dark,
            .dark,
            .dark,
            .dark,
            .light,
            .undecided,
            .light,
            .dark,
            .dark
        ))

        let result = sut.fitRunsEarliest()

        XCTAssertEqual(result, [
            .init(start: 0, end: 0),
            .init(start: 5, end: 9),
            .init(start: 11, end: 11),
            .init(start: 13, end: 14),
        ])
    }

    func testFitRunsEarliest_rejectZeroRunHint() {
        // Runs:
        // [] (0-length)
        //
        // Tiles: (O = dark, ▋ = light, empty = undecided)
        // [ ][ ]
        //
        // Expected result:
        // nil
        let sut = makeSut(hint: [0], tiles: tiles(
            .undecided,
            .undecided
        ))

        let result = sut.fitRunsEarliest()

        XCTAssertNil(result)
    }

    func testFitRunsEarliest_rejectRunsExceedingExistingTiles() {
        // Runs:
        // [O][O]
        //
        // Tiles: (O = dark, ▋ = light, empty = undecided)
        // [ ][O][O][O][ ]
        //
        // Expected result:
        // nil
        let sut = makeSut(hint: [2], tiles: tiles(
            .undecided,
            .dark,
            .dark,
            .dark,
            .undecided
        ))

        let result = sut.fitRunsEarliest()

        XCTAssertNil(result)
    }

    func testFitRunsEarliest_rejectExcessivelyLongRun() {
        // Runs:
        // [O][O][O]
        //
        // Tiles: (O = dark, ▋ = light, empty = undecided)
        // [ ][ ]
        //
        // Expected result:
        // nil
        let sut = makeSut(hint: [3], tiles: tiles(
            .undecided,
            .undecided
        ))

        let result = sut.fitRunsEarliest()

        XCTAssertNil(result)
    }
    
    // MARK: - fitRunsLatest
    
    func testFitRunsLatest_fullFill_emptyTiles_singleHint() {
        // Runs:
        // [O][O]
        //
        // Tiles: (O = dark, ▋ = light, empty = undecided)
        // [ ][ ]
        //
        // Expected result:
        // nil
        let sut = makeSut(hint: [2], tiles: tiles(
            .undecided,
            .undecided
        ))

        let result = sut.fitRunsLatest()

        XCTAssertEqual(result, [
            .init(start: 0, end: 1),
        ])
    }

    func testFitRunsLatest_partialFill_emptyTiles_singleHint() {
        // Runs:
        // [O][O]
        //
        // Tiles: (O = dark, ▋ = light, empty = undecided)
        // [ ][ ][ ]
        //
        // Expected result:
        // nil
        let sut = makeSut(hint: [2], tiles: tiles(
            .undecided,
            .undecided,
            .undecided
        ))

        let result = sut.fitRunsLatest()

        XCTAssertEqual(result, [
            .init(start: 1, end: 2),
        ])
    }

    func testFitRunsLatest_prefilledTiles() {
        // Runs:
        // [O][O][O]
        // [O][O][O][O]
        // [O][O]
        //
        // Tiles: (O = dark, ▋ = light, empty = undecided)
        // [ ][O][ ][ ][ ][O][ ][O][O][▋][ ][ ][O][ ][ ][ ]
        //
        // Expected result:
        // [ ][O][O][O][ ][O][O][O][O][▋][ ][ ][O][O][ ][ ]
        let sut = makeSut(hint: [3, 4, 2], tiles: tiles(
            .undecided,
            .dark,
            .undecided,
            .undecided,
            .undecided,
            .dark,
            .undecided,
            .dark,
            .dark,
            .light,
            .undecided,
            .undecided,
            .dark,
            .undecided,
            .undecided,
            .undecided
        ))

        let result = sut.fitRunsLatest()

        XCTAssertEqual(result, [
            .init(start: 1, end: 3),
            .init(start: 5, end: 8),
            .init(start: 12, end: 13),
        ])
    }

    func testFitRunsLatest_singleTileFits() {
        // Runs:
        // [O][O][O][O]
        // [O]
        // [O]
        //
        // Tiles: (O = dark, ▋ = light, empty = undecided)
        // [O][O][O][O][ ][ ][ ][O][▋][▋]
        //
        // Expected result:
        // [O][O][O][O][ ][O][ ][O][▋][▋]
        let sut = makeSut(hint: [4, 1, 1], tiles: tiles(
            .dark,
            .dark,
            .dark,
            .dark,
            .undecided,
            .undecided,
            .undecided,
            .dark,
            .light,
            .light
        ))

        let result = sut.fitRunsLatest()

        XCTAssertEqual(result, [
            .init(start: 0, end: 3),
            .init(start: 5, end: 5),
            .init(start: 7, end: 7),
        ])
    }

    func testFitRunsLatest_undecidedSpaceFit() {
        // Runs:
        // [O]
        // [O][O][O][O]
        // [O]
        // [O][O]
        //
        // Tiles: (O = dark, ▋ = light, empty = undecided)
        // [O][ ][ ][ ][▋][O][O][O][O][O][▋][ ][▋][O][O]
        //
        // Expected result:
        // [O][ ][ ][ ][▋][O][O][O][O][O][▋][O][▋][O][O]
        let sut = makeSut(hint: [1, 5, 1, 2], tiles: tiles(
            .dark,
            .undecided,
            .undecided,
            .undecided,
            .light,
            .dark,
            .dark,
            .dark,
            .dark,
            .dark,
            .light,
            .undecided,
            .light,
            .dark,
            .dark
        ))

        let result = sut.fitRunsLatest()

        XCTAssertEqual(result, [
            .init(start: 0, end: 0),
            .init(start: 5, end: 9),
            .init(start: 11, end: 11),
            .init(start: 13, end: 14),
        ])
    }

    func testFitRunsLatest_rejectZeroRunHint() {
        // Runs:
        // [] (0-length)
        //
        // Tiles: (O = dark, ▋ = light, empty = undecided)
        // [ ][ ]
        //
        // Expected result:
        // nil
        let sut = makeSut(hint: [0], tiles: tiles(
            .undecided,
            .undecided
        ))

        let result = sut.fitRunsLatest()

        XCTAssertNil(result)
    }

    func testFitRunsLatest_rejectRunsExceedingExistingTiles() {
        // Runs:
        // [O][O]
        //
        // Tiles: (O = dark, ▋ = light, empty = undecided)
        // [ ][O][O][O][ ]
        //
        // Expected result:
        // nil
        let sut = makeSut(hint: [2], tiles: tiles(
            .undecided,
            .dark,
            .dark,
            .dark,
            .undecided
        ))

        let result = sut.fitRunsLatest()

        XCTAssertNil(result)
    }

    func testFitRunsLatest_rejectExcessivelyLongRun() {
        // Runs:
        // [O][O][O]
        //
        // Tiles: (O = dark, ▋ = light, empty = undecided)
        // [ ][ ]
        //
        // Expected result:
        // nil
        let sut = makeSut(hint: [3], tiles: tiles(
            .undecided,
            .undecided
        ))

        let result = sut.fitRunsLatest()

        XCTAssertNil(result)
    }

    func testFitRunsLatest_rejectUnavoidableOverlappingRuns_emptyTiles() {
        // Runs:
        // [O][O]
        // [O][O]
        //
        // Tiles: (O = dark, ▋ = light, empty = undecided)
        // [ ][ ][ ][ ]
        //
        // Expected result:
        // nil
        let sut = makeSut(hint: [2, 2], tiles: tiles(
            .undecided,
            .undecided,
            .undecided,
            .undecided
        ))

        let result = sut.fitRunsLatest()

        XCTAssertNil(result)
    }

    func testFitRunsLatest_rejectUnavoidableOverlappingRuns_prefilledTiles() {
        // Runs:
        // [O][O]
        // [O][O]
        //
        // Tiles: (O = dark, ▋ = light, empty = undecided)
        // [ ][O][O][ ]
        //
        // Expected result:
        // nil
        let sut = makeSut(hint: [2, 2], tiles: tiles(
            .undecided,
            .dark,
            .dark,
            .undecided
        ))

        let result = sut.fitRunsLatest()

        XCTAssertNil(result)
    }

    // MARK: -

    func testEarliestDarkTile() {
        // Runs:
        // [O][O][O]
        // [O][O][O][O]
        // [O][O]
        //
        // Tiles: (O = dark, ▋ = light, empty = undecided)
        // [ ][O][ ][ ][ ][O][ ][O][O][▋][ ][ ][O][ ][ ][ ]
        let sut = makeSut(hint: [3, 4, 2], tiles: tiles(
            .undecided,
            .dark,
            .undecided,
            .undecided,
            .undecided,
            .dark,
            .undecided,
            .dark,
            .dark,
            .light,
            .undecided,
            .undecided,
            .dark,
            .undecided,
            .undecided,
            .undecided
        ))

        let result = sut.earliestDarkTile()

        XCTAssertEqual(result, 0)
    }

    func testLatestDarkTile() {
        // Runs:
        // [O][O][O]
        // [O][O][O][O]
        // [O][O]
        //
        // Tiles: (O = dark, ▋ = light, empty = undecided)
        // [ ][O][ ][ ][ ][O][ ][O][O][▋][ ][ ][O][ ][ ][ ]
        let sut = makeSut(hint: [3, 4, 2], tiles: tiles(
            .undecided,
            .dark,
            .undecided,
            .undecided,
            .undecided,
            .dark,
            .undecided,
            .dark,
            .dark,
            .light,
            .undecided,
            .undecided,
            .dark,
            .undecided,
            .undecided,
            .undecided
        ))

        let result = sut.latestDarkTile()

        XCTAssertEqual(result, 13)
    }

    func testOverlappingIntervals_singleTile() {
        // Runs:
        // [O]
        //
        // Tiles: (O = dark, ▋ = light, empty = undecided)
        // [O][ ]
        let sut = makeSut(hint: [1], tiles: tiles(
            .dark,
            .undecided
        ))

        let result = sut.overlappingIntervals()

        XCTAssertEqual(result, [
            .init(start: 0, end: 0),
        ])
    }

    func testOverlappingIntervals_undecidedSpaceFit() {
        // Runs:
        // [O]
        // [O][O][O][O]
        // [O]
        // [O][O]
        //
        // Tiles: (O = dark, ▋ = light, empty = undecided)
        // [O][ ][ ][ ][▋][O][O][O][O][O][▋][ ][▋][O][O]
        //
        // Expected result:
        // [O][ ][ ][ ][▋][O][O][O][O][O][▋][O][▋][O][O]
        let sut = makeSut(hint: [1, 5, 1, 2], tiles: tiles(
            .dark,
            .undecided,
            .undecided,
            .undecided,
            .light,
            .dark,
            .dark,
            .dark,
            .dark,
            .dark,
            .light,
            .undecided,
            .light,
            .dark,
            .dark
        ))

        let result = sut.overlappingIntervals()

        XCTAssertEqual(result, [
            .init(start: 0, end: 0),
            .init(start: 5, end: 9),
            .init(start: 11, end: 11),
            .init(start: 13, end: 14),
        ])
    }

    // MARK: - Private test factory methods

    private func makeSut(hint: PatternGrid.RunsHint, tiles: [PatternTile]) -> TileFitter {
        TileFitter(hint: hint, tiles: tiles)
    }

    private func tile(_ state: PatternTile.State) -> PatternTile {
        .init(state: state)
    }

    private func tiles(_ states: PatternTile.State...) -> [PatternTile] {
        states.map {
            .init(state: $0)
        }
    }
}
