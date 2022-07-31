import XCTest

@testable import LoopySolver

class LoopyGridLoaderTests: XCTestCase {
    func testLoadFromGameID_squareGrid() throws {
        let result = try LoopyGridLoader.loadFromGameID("3x5t0:a2a301b23c2a")

        XCTAssertEqual(result.faces.count, 15)
        let printer = LoopyGridPrinter(squareGridColumns: 3, rows: 5)
        printer.printGrid(grid: result)
    }

    func testLoadFromGameID_honeycomb() throws {
        let result = try LoopyGridLoader.loadFromGameID("3x4t2:145d31c")

        XCTAssertEqual(result.faces.count, 12)
        let printer = LoopyGridPrinter(honeycombGridColumns: 3, rows: 4)
        printer.printGrid(grid: result)
    }

    func testLoadFromGameID_greatHexagon() throws {
        let result = try LoopyGridLoader.loadFromGameID("5x4t5:5c413a2b2b2a32d52b321c2a1a2e2133e2421a4a1a2e2d12b23a1a432b5a")

        XCTAssertEqual(result.faces.count, LoopyGreatHexagonGridGenerator.faceCountForGrid(width: 5, height: 4))
        let printer = LoopyGridPrinter(greatHexagonGridColumns: 5, rows: 4)
        printer.printGrid(grid: result)
    }

    func testLoadFromGameID_errorOnUnsupportedGridTypes() throws {
        do {
            _ = try LoopyGridLoader.loadFromGameID("5x4t99:0")
        } catch LoopyGridLoader.Error.unsupportedGridType(99) {
            // Success
        }
    }
}
