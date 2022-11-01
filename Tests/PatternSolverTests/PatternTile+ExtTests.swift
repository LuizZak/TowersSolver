import XCTest

@testable import PatternSolver

class PatternTile_ExtTests: XCTestCase {
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

    private func tiles(_ states: PatternTile.State...) -> [PatternTile] {
        states.map {
            .init(state: $0)
        }
    }
}
