import XCTest

@testable import SignpostSolver

class SignpostGridGeneratorTests: XCTestCase {
    func testLoadFromGameID() {
        // Game available at: https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/signpost.html#4x4:1efdgedbe12bafebca16a
        let sut = SignpostGridGenerator(rows: 4, columns: 4)
        sut.loadFromGameID("1efdgedbe12bafebca16a")

        let result = sut.grid
        let tiles = result.tilesSequential
        let solutions = tiles.map(\.solution)
        let orientations = tiles.map(\.orientation)
        let isStartTile = tiles.map(\.isStartTile)
        let isEndTile = tiles.map(\.isEndTile)
        XCTAssertEqual(orientations, [
            .south, .southWest, .southEast, .west,
            .south, .southEast, .northEast, .south,
            .northEast, .north, .southWest, .south,
            .northEast, .east, .north, .north
        ])
        XCTAssertEqual(solutions, [
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

    func testLoadFromGameID_3x3_solved() {
        // Game available at:
        // https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/signpost.html#3x3:1d3e8e6c2a7a5a4g9a
        let sut = SignpostGridGenerator(rows: 3, columns: 3)
        sut.loadFromGameID("1d3e8e6c2a7a5a4g9a")

        let result = sut.grid
        let tiles = result.tilesSequential
        let solutions = tiles.map(\.solution)
        let connections = tiles.compactMap(\.connectedTo)
        XCTAssertEqual(solutions, [
            1, 3, 8,
            6, 2, 7,
            5, 4, 9,
        ])
        XCTAssert(connections.elementsEqual([
            (1, 1), (1, 2), (2, 2),
            (2, 1), (1, 0), (2, 0),
            (0, 1), (0, 2)
        ], by: { $0 == $1 }))
    }
}
