import XCTest

@testable import PatternSolver

class TileFitterTests: XCTestCase {
    func testPotentialRunIndices() {
        // Runs:
        // [O][O]
        // [O][O][O]
        //
        // Tiles: (O = dark, ▋ = light, empty = undecided)
        // [ ][ ][ ][ ][ ][ ][ ][ ][ ][▋][ ][ ] (12 total)
        let sut = makeSut(hint: [2, 3], tiles: tiles(
            .undecided,
            .undecided,
            .undecided,
            .undecided,
            .undecided,
            .undecided,
            .undecided,
            .undecided,
            .undecided,
            .light,
            .undecided,
            .undecided
        ))

        XCTAssertEqual(sut.potentialRunIndices(forTileAt: 0), [0])
        XCTAssertEqual(sut.potentialRunIndices(forTileAt: 3), [0, 1])
        XCTAssertEqual(sut.potentialRunIndices(forTileAt: 8), [1])
        XCTAssertEqual(sut.potentialRunIndices(forTileAt: 10), [])
        XCTAssertEqual(sut.potentialRunIndices(forTileAt: 11), [])
    }

    func testPotentialRunLengths() {
        // Runs:
        // [O][O]
        // [O][O]
        // [O][O][O]
        //
        // Tiles: (O = dark, ▋ = light, empty = undecided)
        // [ ][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ][▋][ ][ ] (15 total)
        let sut = makeSut(hint: [2, 2, 3], tiles: tiles(
            .undecided,
            .undecided,
            .undecided,
            .undecided,
            .undecided,
            .undecided,
            .undecided,
            .undecided,
            .undecided,
            .undecided,
            .undecided,
            .undecided,
            .undecided,
            .light,
            .undecided,
            .undecided
        ))

        XCTAssertEqual(sut.potentialRunLengths(forTileAt: 0), [2])
        XCTAssertEqual(sut.potentialRunLengths(forTileAt: 4), [2])
        XCTAssertEqual(sut.potentialRunLengths(forTileAt: 7), [2, 3])
        XCTAssertEqual(sut.potentialRunLengths(forTileAt: 11), [3])
        XCTAssertEqual(sut.potentialRunLengths(forTileAt: 13), [])
        XCTAssertEqual(sut.potentialRunLengths(forTileAt: 14), [])
    }

    func testGuaranteedDarkTilesSurrounding_runPrecedingSeparator() {
        // Runs:
        // [O][O][O][O] (4)
        // [O][O] (2)
        // [O][O][O][O][O][O][O] (7)
        // [O][O][O] (3)
        // [O][O][O] (3)
        //
        // Tiles: (O = dark, ▋ = light, empty = undecided)
        // [ ][ ][ ][ ][ ] x [ ][ ][ ][ ][ ] x [ ][ ][ ][ ][ ] x [ ][ ][ ][ ][ ] x [ ][ ][ ][ ][ ] x [ ][ ][ ][O][O] x [▋][ ][ ][ ][ ] (35 total)
        let sut = makeSut(hint: [4, 2, 7, 3, 3], tiles: tiles(
            .undecided,
            .undecided,
            .undecided,
            .undecided,
            .undecided,
            //
            .undecided,
            .undecided,
            .undecided,
            .undecided,
            .undecided,
            //
            .undecided,
            .undecided,
            .undecided,
            .undecided,
            .undecided,
            //
            .undecided,
            .undecided,
            .undecided,
            .undecided,
            .undecided,
            //
            .undecided,
            .undecided,
            .undecided,
            .undecided,
            .undecided,
            //
            .undecided,
            .undecided,
            .undecided,
            .dark,
            .dark,
            //
            .light,
            .undecided,
            .undecided,
            .undecided,
            .undecided
        ))

        XCTAssertEqual(
            sut.guaranteedDarkTilesSurrounding(tileAtIndex: 29),
            [27, 28, 29]
        )
        XCTAssertEqual(
            sut.guaranteedDarkTilesSurrounding(tileAtIndex: 28),
            [27, 28, 29]
        )
        XCTAssertEqual(
            sut.guaranteedDarkTilesSurrounding(tileAtIndex: 26),
            []
        )
    }

    func testGuaranteedDarkTilesSurrounding_runSucceedingSeparator() {
        // Runs:
        // [O][O][O] (3)
        // [O][O][O] (3)
        // [O][O][O][O][O][O][O] (7)
        // [O][O] (2)
        // [O][O][O][O] (4)
        //
        // Tiles: (O = dark, ▋ = light, empty = undecided)
        // [ ][ ][ ][ ][▋] x [O][O][ ][ ][ ] x [ ][ ][ ][ ][ ] x [ ][ ][ ][ ][ ] x [ ][ ][ ][ ][ ] x [ ][ ][ ][ ][ ] x [ ][ ][ ][ ][ ] (35 total)
        let sut = makeSut(hint: [3, 3, 7, 2, 4], tiles: tiles(
            .undecided,
            .undecided,
            .undecided,
            .undecided,
            .light,
            //
            .dark,
            .dark,
            .undecided,
            .undecided,
            .undecided,
            //
            .undecided,
            .undecided,
            .undecided,
            .undecided,
            .undecided,
            //
            .undecided,
            .undecided,
            .undecided,
            .undecided,
            .undecided,
            //
            .undecided,
            .undecided,
            .undecided,
            .undecided,
            .undecided,
            //
            .undecided,
            .undecided,
            .undecided,
            .undecided,
            .undecided,
            //
            .undecided,
            .undecided,
            .undecided,
            .undecided,
            .undecided
        ))

        XCTAssertEqual(
            sut.guaranteedDarkTilesSurrounding(tileAtIndex: 5),
            [5, 6, 7]
        )
        XCTAssertEqual(
            sut.guaranteedDarkTilesSurrounding(tileAtIndex: 6),
            [5, 6, 7]
        )
        XCTAssertEqual(
            sut.guaranteedDarkTilesSurrounding(tileAtIndex: 7),
            []
        )
    }

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
            (0..<(1 + 1)),
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
            (0..<(1 + 1)),
        ])
    }

    func testFitRunsEarliest_partialFill_existingRun() {
        // Runs:
        // [O][O]
        //
        // Tiles: (O = dark, ▋ = light, empty = undecided)
        // [O][O][▋]
        //
        // Expected result:
        // [O][O][ ]
        let sut = makeSut(hint: [2], tiles: tiles(
            .dark,
            .dark,
            .light
        ))

        let result = sut.fitRunsEarliest()

        XCTAssertEqual(result, [
            (0..<(1 + 1)),
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
            (3..<(4 + 1)),
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
            (0..<(1 + 1)),
            (3..<(6 + 1)),
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
            (0..<(2 + 1)),
            (5..<(8 + 1)),
            (11..<(12 + 1)),
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
            (0..<(3 + 1)),
            (5..<(5 + 1)),
            (7..<(7 + 1)),
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
            (0..<(0 + 1)),
            (5..<(9 + 1)),
            (11..<(11 + 1)),
            (13..<(14 + 1)),
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
            (0..<(1 + 1)),
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
            (1..<(2 + 1)),
        ])
    }

    func testFitRunsLatest_partialFill_existingRun() {
        // Runs:
        // [O][O]
        //
        // Tiles: (O = dark, ▋ = light, empty = undecided)
        // [O][O][▋]
        //
        // Expected result:
        // [O][O][ ]
        let sut = makeSut(hint: [2], tiles: tiles(
            .dark,
            .dark,
            .light
        ))

        let result = sut.fitRunsLatest()

        XCTAssertEqual(result, [
            (0..<(1 + 1)),
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
            (1..<(3 + 1)),
            (5..<(8 + 1)),
            (12..<(13 + 1)),
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
            (0..<(3 + 1)),
            (5..<(5 + 1)),
            (7..<(7 + 1)),
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
            (0..<(0 + 1)),
            (5..<(9 + 1)),
            (11..<(11 + 1)),
            (13..<(14 + 1)),
        ])
    }

    func testFitRunsLatest_finalizeSingleTileRuns() {
        // Runs: 
        // [O]
        // [O]
        // [O][O][O][O][O][O][O][O]
        // [O][O][O][O]
        // [O][O][O][O][O]
        // [O][O]
        //
        // Tiles: (O = dark, ▋ = light, empty = undecided)
        // [▋][O][▋][O][ ][ ][ ][ ][ ][ ][ ][ ][O][ ][ ][ ][O][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ][▋][▋][ ][ ]
        //
        // Expected result:
        // [▋][O][▋][O][ ][ ][ ][ ][ ][ ][ ][ ][O][O][O][O][O][O][O][O][ ][O][O][O][O][ ][O][O][O][O][O][▋][▋][O][O]
        let sut = makeSut(hint: [1, 1, 8, 4, 5, 2], tiles: tiles(
            .light,
            .dark,
            .light,
            .dark,
            .undecided,
            .undecided,
            .undecided,
            .undecided,
            .undecided,
            .undecided,
            .undecided,
            .undecided,
            .dark,
            .undecided,
            .undecided,
            .undecided,
            .dark,
            .undecided,
            .undecided,
            .undecided,
            .undecided,
            .undecided,
            .undecided,
            .undecided,
            .undecided,
            .undecided,
            .undecided,
            .undecided,
            .undecided,
            .undecided,
            .undecided,
            .light,
            .light,
            .undecided,
            .undecided
        ))

        let result = sut.fitRunsLatest()

        XCTAssertEqual(result, [
            (1..<(1 + 1)),
            (3..<(3 + 1)),
            (12..<(19 + 1)),
            (21..<(24 + 1)),
            (26..<(30 + 1)),
            (33..<(34 + 1)),
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
            (0..<(0 + 1)),
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
            (0..<(0 + 1)),
            (5..<(9 + 1)),
            (11..<(11 + 1)),
            (13..<(14 + 1)),
        ])
    }

    func testEarliestAlignedRuns_encompassExistingRuns() {
        // Runs: 
        // [O][O][O][O][O] (5x)
        // [O][O][O][O][O][O][O][O][O][O][O] (11x)
        // [O][O][O][O][O] (5x)
        //
        // Tiles: (O = dark, ▋ = light, empty = undecided)
        // [O][O][O][O][O][▋][ ][ ][O][O][O][O][O][O][O][O][O][ ][ ][ ][▋][▋][▋][▋][▋][O][O][O][O][O][▋][▋][▋][▋]
        //
        // Expected result:
        // [O][O][O][O][O][▋][O][O][O][O][O][O][O][O][O][O][O][ ][ ][ ][▋][▋][▋][▋][▋][O][O][O][O][O][▋][▋][▋][▋]
        let sut = makeSut(hint: [5, 11, 5], tiles: tiles(
            .dark,
            .dark,
            .dark,
            .dark,
            .dark,
            .light,
            .undecided,
            .undecided,
            .dark,
            .dark,
            .dark,
            .dark,
            .dark,
            .dark,
            .dark,
            .dark,
            .dark,
            .undecided,
            .undecided,
            .undecided,
            .light,
            .light,
            .light,
            .light,
            .light,
            .dark,
            .dark,
            .dark,
            .dark,
            .dark,
            .light,
            .light,
            .light,
            .light
        ))

        let result = sut.earliestAlignedRuns()

        XCTAssertEqual(result, [
            (0..<(4 + 1)),
            (6..<(16 + 1)),
            (25..<(29 + 1)),
        ])
    }

    func testLatestAlignedRuns_encompassExistingRuns() {
        // Runs: 
        // [O][O][O][O][O] (5x)
        // [O][O][O][O][O][O][O][O][O][O][O] (11x)
        // [O][O][O][O][O] (5x)
        //
        // Tiles: (O = dark, ▋ = light, empty = undecided)
        // [O][O][O][O][O][▋][ ][ ][O][O][O][O][O][O][O][O][O][ ][ ][ ][▋][▋][▋][▋][▋][O][O][O][O][O][▋][▋][▋][▋]
        //
        // Expected result:
        // [O][O][O][O][O][▋][ ][ ][O][O][O][O][O][O][O][O][O][O][O][ ][▋][▋][▋][▋][▋][O][O][O][O][O][▋][▋][▋][▋]
        let sut = makeSut(hint: [5, 11, 5], tiles: tiles(
            .dark,
            .dark,
            .dark,
            .dark,
            .dark,
            .light,
            .undecided,
            .undecided,
            .dark,
            .dark,
            .dark,
            .dark,
            .dark,
            .dark,
            .dark,
            .dark,
            .dark,
            .undecided,
            .undecided,
            .undecided,
            .light,
            .light,
            .light,
            .light,
            .light,
            .dark,
            .dark,
            .dark,
            .dark,
            .dark,
            .light,
            .light,
            .light,
            .light
        ))

        let result = sut.latestAlignedRuns()

        XCTAssertEqual(result, [
            (0..<(4 + 1)),
            (8..<(18 + 1)),
            (25..<(29 + 1)),
        ])
    }

    // MARK: - Private test factory methods

    private func makeSut(hint: PatternGrid.RunsHint, tiles: [PatternTile]) -> TileFitter<[PatternTile]> {
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
