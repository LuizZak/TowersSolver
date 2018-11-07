import XCTest
@testable import LoopySolver

class LoopyGreatHexagonGridGeneratorTests: XCTestCase {
    
    func testGenerate() {
        let sut = LoopyGreatHexagonGridGenerator(width: 3, height: 3)
        sut.setHint(faceIndex: 0, hint: 2)
        sut.setHint(faceIndex: 7, hint: 3)
        sut.setHint(faceIndex: 9, hint: 2)
        
        let grid = sut.generate()
        
        LoopyGridPrinter(bufferWidth: 90, bufferHeight: 60).printGrid(grid: grid)
    }
    
    func testFaceCount() {
        let makeCount = LoopyGreatHexagonGridGenerator.faceCountForGrid
        
        XCTAssertEqual(makeCount(0, 0), 0)
        XCTAssertEqual(makeCount(1, 0), 0)
        XCTAssertEqual(makeCount(1, 1), 1)
        XCTAssertEqual(makeCount(2, 1), 3)
        XCTAssertEqual(makeCount(2, 2), 11)
        XCTAssertEqual(makeCount(3, 2), 19)
        XCTAssertEqual(makeCount(3, 3), 33)
        XCTAssertEqual(makeCount(2, 3), 19)
        XCTAssertEqual(makeCount(4, 3), 47)
        XCTAssertEqual(makeCount(4, 5), 87)
    }
}
