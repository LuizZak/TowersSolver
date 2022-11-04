import XCTest

@testable import PatternSolver

class PatternTile_ExtTests: XCTestCase {
    func testDarkTileRuns() {
        // Tiles: (O = dark, ▋ = light, empty = undecided)
        // [ ][O][ ][ ][O][ ][O][O][▋][ ][O][O][ ][O]
        let sut = tiles(
            .undecided,
            .dark,
            .undecided,
            .undecided,
            .dark,
            .undecided,
            .dark,
            .dark,
            .light,
            .undecided,
            .dark,
            .dark,
            .undecided,
            .dark
        )
        
        XCTAssertEqual(sut.darkTileRuns(), [
            (1..<2),
            (4..<5),
            (6..<8),
            (10..<12),
            (13..<14),
        ])
    }
    
    func testNextAvailableSpace() {
        // Tiles: (O = dark, ▋ = light, empty = undecided)
        // [ ][O][ ][ ][O][ ][O][O][▋][ ][O][O][ ][ ]
        let sut = tiles(
            .undecided,
            .dark,
            .undecided,
            .undecided,
            .dark,
            .undecided,
            .dark,
            .dark,
            .light,
            .undecided,
            .dark,
            .dark,
            .undecided,
            .undecided
        )

        XCTAssertEqual(
            sut.nextAvailableSpace(fromIndex: 0),
            0..<8
        )
        XCTAssertEqual(
            sut.nextAvailableSpace(fromIndex: 1),
            1..<8
        )
        XCTAssertEqual(
            sut.nextAvailableSpace(fromIndex: 7),
            7..<8
        )
        XCTAssertEqual(
            sut.nextAvailableSpace(fromIndex: 8),
            9..<14
        )
        XCTAssertEqual(
            sut.nextAvailableSpace(fromIndex: 9),
            9..<14
        )
        XCTAssertEqual(
            sut.nextAvailableSpace(fromIndex: 10),
            10..<14
        )
    }

    func testAvailableSpaceSurrounding() {
        // Tiles: (O = dark, ▋ = light, empty = undecided)
        // [ ][O][ ][ ][O][ ][O][O][▋][ ][O][O][ ][ ]
        let sut = tiles(
            .undecided,
            .dark,
            .undecided,
            .undecided,
            .dark,
            .undecided,
            .dark,
            .dark,
            .light,
            .undecided,
            .dark,
            .dark,
            .undecided,
            .undecided
        )

        XCTAssertEqual(
            sut.availableSpaceSurrounding(index: 0),
            0..<8
        )
        XCTAssertEqual(
            sut.availableSpaceSurrounding(index: 1),
            0..<8
        )
        XCTAssertEqual(
            sut.availableSpaceSurrounding(index: 7),
            0..<8
        )
        XCTAssertNil(sut.availableSpaceSurrounding(index: 8))
        XCTAssertEqual(
            sut.availableSpaceSurrounding(index: 9),
            9..<14
        )
        XCTAssertEqual(
            sut.availableSpaceSurrounding(index: 10),
            9..<14
        )
    }

    func testLeftmostEnclosedDarkTileRuns_emptyTileSet() {
        // Tiles: (O = dark, ▋ = light, empty = undecided)
        // [ ][ ][ ][ ]
        let sut = tiles(
            .undecided,
            .undecided,
            .undecided,
            .undecided
        )

        let result = sut.leftmostEnclosedDarkTileRuns()

        XCTAssertEqual(result, [])
    }

    func testLeftmostEnclosedDarkTileRuns_stopOnUnboundedRuns() {
        // Tiles: (O = dark, ▋ = light, empty = undecided)
        // [O][O][▋][O][O][O][▋][O][O][ ]
        let sut = tiles(
            .dark,
            .dark,
            .light,
            .dark,
            .dark,
            .dark,
            .light,
            .dark,
            .dark,
            .undecided
        )

        let result = sut.leftmostEnclosedDarkTileRuns()

        XCTAssertEqual(result, [
            (0..<2),
            (3..<6),
        ])
    }

    func testLeftmostEnclosedDarkTileRuns_stopOnFirstUndecidedTile() {
        // Tiles: (O = dark, ▋ = light, empty = undecided)
        // [O][O][▋][ ][▋][O][O][O][▋][O][O][ ]
        let sut = tiles(
            .dark,
            .dark,
            .light,
            .undecided,
            .light,
            .dark,
            .dark,
            .dark,
            .light,
            .dark,
            .dark,
            .undecided
        )

        let result = sut.leftmostEnclosedDarkTileRuns()

        XCTAssertEqual(result, [
            (0..<2),
        ])
    }

    func testLeftmostEnclosedDarkTileRuns_stopOnFirstRunTrailingAnUndecidedTile() {
        // Tiles: (O = dark, ▋ = light, empty = undecided)
        // [ ][O][O][▋][O][O][O][▋][O][O][ ]
        let sut = tiles(
            .undecided,
            .dark,
            .dark,
            .light,
            .dark,
            .dark,
            .dark,
            .light,
            .dark,
            .dark,
            .undecided
        )

        let result = sut.leftmostEnclosedDarkTileRuns()

        XCTAssertEqual(result, [])
    }

    // MARK: - Test utils

    private func tiles(_ states: PatternTile.State...) -> [PatternTile] {
        states.map {
            .init(state: $0)
        }
    }
}
