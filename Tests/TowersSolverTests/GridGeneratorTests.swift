import XCTest

@testable import TowersSolver

class GridGeneratorTests: XCTestCase {
    func testInitWithGameId_6x6_easy() throws {
        let sut = try GridGenerator(gameId: "6:2/1/3/3/2/4/2/4/3/2/1/2/2/1/2/3/4/2/3/3/3/2/1/2,g5d4f3d1a5a3g")

        let result = sut.grid

        XCTAssertEqual(result.visibilities.top, [2, 1, 3, 3, 2, 4])
        XCTAssertEqual(result.visibilities.bottom, [2, 4, 3, 2, 1, 2])
        XCTAssertEqual(result.visibilities.left, [2, 1, 2, 3, 4, 2])
        XCTAssertEqual(result.visibilities.right, [3, 3, 3, 2, 1, 2])
        XCTAssertEqual(result.cells.solutionHeights(), [
            0, 0, 0, 0, 0, 0,
            0, 5, 0, 0, 0, 0,
            4, 0, 0, 0, 0, 0,
            0, 3, 0, 0, 0, 0,
            1, 0, 5, 0, 3, 0,
            0, 0, 0, 0, 0, 0,
        ])
    }

    func testInitWithGameId_6x6_unreasonable() throws {
        let sut = try GridGenerator(gameId: "6://4/3/////2//3/3/3//4/3//3//3/1//4/,j1y")

        let result = sut.grid

        XCTAssertEqual(result.visibilities.top, [0, 0, 4, 3, 0, 0])
        XCTAssertEqual(result.visibilities.bottom, [0, 0, 2, 0, 3, 3])
        XCTAssertEqual(result.visibilities.left, [3, 0, 4, 3, 0, 3])
        XCTAssertEqual(result.visibilities.right, [0, 3, 1, 0, 4, 0])
        XCTAssertEqual(result.cells.solutionHeights(), [
            0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 1, 0,
            0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0,
        ])
    }
}
