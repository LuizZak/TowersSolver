import XCTest
import Console
import NetSolver

class NetGridPrinterTests: XCTestCase {
    private var target: TestConsolePrintTarget!
    
    override func setUp() {
        super.setUp()
        
        target = TestConsolePrintTarget()
    }
    
    func testPrintGrid5x5() {
        var rng = MersenneTwister(seed: 58196234)
        let grid = Grid(rows: 5, columns: 5)
        let controller = NetGridController(grid: grid)
        controller.shuffle(using: &rng)
        let sut = NetGridPrinter(bufferWidth: 42, bufferHeight: 22)
        sut.target = target
        sut.printGrid(grid: grid)
        
        XCTAssertEqual(target.buffer, """
            
            """)
    }
}

private class TestConsolePrintTarget: ConsolePrintTarget {
    let supportsTerminalColors = false
    
    var buffer: String = ""
    
    func print(_ values: [Any], separator: String, terminator: String) {
        let total = values.map { String(describing: $0) }.joined(separator: separator)
        
        Swift.print(total, terminator: terminator, to: &buffer)
    }
}

