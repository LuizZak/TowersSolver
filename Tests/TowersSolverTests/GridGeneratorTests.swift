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

    func testGameIdForGrid_noHints() {
        var grid = Grid(size: 5)
        grid.visibilities.top = [4, 0, 0, 3, 2]
        grid.visibilities.left = [0, 0, 0, 0, 0]
        grid.visibilities.right = [0, 0, 0, 3, 3]
        grid.visibilities.bottom = [1, 4, 0, 2, 3]

        let result = GridGenerator.gameId(for: grid)

        XCTAssertEqual(result, "5:4///3/2/1/4//2/3/////////3/3")
    }

    func testGameIdForGrid_withHints() {
        var grid = Grid(size: 8)
        grid.visibilities.top = [0, 0, 3, 1, 5, 0, 0, 4]
        grid.visibilities.left = [3, 3, 2, 1, 0, 4, 0, 3]
        grid.visibilities.right = [0, 0, 0, 3, 3, 0, 4, 0]
        grid.visibilities.bottom = [0, 0, 1, 4, 0, 2, 0, 0]
        grid.markSolved(x: 5, y: 0, height: 3)
        grid.markSolved(x: 0, y: 2, height: 4)
        grid.markSolved(x: 6, y: 2, height: 3)
        grid.markSolved(x: 2, y: 3, height: 4)
        grid.markSolved(x: 1, y: 4, height: 1)
        grid.markSolved(x: 7, y: 4, height: 4)
        grid.markSolved(x: 2, y: 5, height: 6)
        grid.markSolved(x: 7, y: 6, height: 2)
        grid.markSolved(x: 1, y: 7, height: 5)
        grid.markSolved(x: 4, y: 7, height: 1)

        let result = GridGenerator.gameId(for: grid)

        XCTAssertEqual(result, "8://3/1/5///4///1/4//2///3/3/2/1//4//3////3/3//4/,e3j4e3c4f1e4b6l2a5b1c")
    }
}
