import XCTest

@testable import SignpostSolver

class SignpostGridGeneratorTests: XCTestCase {
    func testLoadFromGameID() {
        let sut = SignpostGridGenerator(rows: 4, columns: 4)

        // Game available at: https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/signpost.html#4x4:1efdgedbe12bafebca16a
        sut.loadFromGameID("1efdgedbe12bafebca16a")

        let result = sut.grid
        let tiles = result.tilesSequential
        let hints = tiles.map(\.hint)
        let orientations = tiles.map(\.orientation)
        let isStartTile = tiles.map(\.isStartTile)
        let isEndTile = tiles.map(\.isEndTile)
        XCTAssertEqual(orientations, [
            .south, .southWest, .southEast, .west,
            .south, .southEast, .northEast, .south,
            .northEast, .north, .southWest, .south,
            .northEast, .east, .north, .north
        ])
        XCTAssertEqual(hints, [
            1, nil, nil, nil,
            nil, nil, nil, nil,
            12, nil, nil, nil,
            nil, nil, nil, 16,
        ])
        XCTAssertEqual(isStartTile, [
            true, false, false, false,
            false, false, false, false,
            false, false, false, false,
            false, false, false, false,
        ])
        XCTAssertEqual(isEndTile, [
            false, false, false, false,
            false, false, false, false,
            false, false, false, false,
            false, false, false, true,
        ])
    }
}
