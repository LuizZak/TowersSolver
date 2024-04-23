import Console
@testable import LightUpSolver

extension LightUpGrid {
    func asString(terminalColorized: Bool = false) -> String {
        let target = StringBufferConsolePrintTarget(supportsTerminalColors: terminalColorized)
        let printer = LightUpGridPrinter(bufferForGrid: self)
        printer.target = target
        printer.printGrid(grid: self)

        return target.buffer
    }
}
