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
        // Game available at:
        // https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/net.html#5x5:4d63229e74cebbc553e521822
        let gen = NetGridGenerator(rows: 5, columns: 5)
        gen.loadFromGameID("4d63229e74cebbc553e521822")
        let sut = NetGridPrinter(bufferWidth: 42, bufferHeight: 22)
        sut.target = target
        sut.printGrid(grid: gen.grid)
        
        XCTAssertEqual(target.buffer, """
            ╭───────┬───────┬───┬───┬───┬───┬───┬───╮
            │       │       │   │   │   │   │   │   │
            ├───■   ├───┬───┼───╯   │   ╰───┤   ■   │
            │       │   │   │       │       │       │
            ├───┬───┼───┴───┼───┬───┼───┬───┼───────┤
            │   │   │       │   │   │   │   │       │
            │   ■   │   ╭───┼───┤   ├───┴───┼───■   │
            │       │   │   │   │   │       │       │
            ├───────┼───┼───┼───┼───┼───┬───┼───────┤
            │       │   │   │   │   │   │   │       │
            ├───╮   ├───┤   │   ■───┤   ├───┼───╮   │
            │   │   │   │   │   │   │   │   │   │   │
            ├───┴───┼───┴───┼───┼───┼───┼───┼───┴───┤
            │       │       │   │   │   │   │       │
            ├───────┼───────┤   ╰───┼───┤   ├───────┤
            │       │       │       │   │   │       │
            ├───┬───┼───────┼───────┼───┼───┼───┬───┤
            │   │   │       │       │   │   │   │   │
            │   ■   │   ■───┤   ■   │   ■   │   ■   │
            │       │       │   │   │       │       │
            ╰───────┴───────┴───┴───┴───────┴───────╯


            """)
    }
}

internal class TestConsolePrintTarget: ConsolePrintTarget {
    var supportsTerminalColors: Bool {
        #if Xcode
        return false
        #else
        return true
        #endif
    }
    
    var buffer: String = ""
    
    func print(_ values: [Any], separator: String, terminator: String) {
        let total = values.map { String(describing: $0) }.joined(separator: separator)
        
        Swift.print(total, terminator: terminator, to: &buffer)
    }
}
