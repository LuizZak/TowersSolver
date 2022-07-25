import LoopySolver
import XCTest

class LoopyHoneycombGridGeneratorTests: XCTestCase {

    func testGenerate() {
        let sut = LoopyHoneycombGridGenerator(width: 5, height: 5)
        sut.setHint(faceIndex: 0, hint: 2)
        sut.setHint(faceIndex: 7, hint: 3)
        sut.setHint(faceIndex: 9, hint: 2)

        let grid = sut.generate()

        LoopyGridPrinter(bufferWidth: 50, bufferHeight: 34).printGrid(grid: grid)
    }

    func testLoadHints() {
        let sut = LoopyHoneycombGridGenerator(width: 5, height: 5)
        sut.loadHints(from: "55c32b43544b4f22")

        let grid = sut.generate()

        let hints = grid.faceIds.map(grid.hintForFace)
        XCTAssertEqual(
            hints,
            [
                5, 5, nil, nil, nil,
                3, 2, nil, nil, 4,
                3, 5, 4, 4, nil,
                nil, 4, nil, nil, nil,
                nil, nil, nil, 2, 2,
            ]
        )
    }
}
