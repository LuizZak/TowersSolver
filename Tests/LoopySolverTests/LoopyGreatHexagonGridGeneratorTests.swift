import XCTest
import LoopySolver

class LoopyGreatHexagonGridGeneratorTests: XCTestCase {
    
    func testGenerate() {
        let sut = LoopyGreatHexagonGridGenerator(width: 3, height: 3)
        sut.setHint(faceIndex: 0, hint: 2)
        sut.setHint(faceIndex: 7, hint: 3)
        sut.setHint(faceIndex: 9, hint: 2)
        
        let grid = sut.generate()
        
        LoopyGridPrinter(bufferWidth: 90, bufferHeight: 60).printGrid(grid: grid)
    }
}
