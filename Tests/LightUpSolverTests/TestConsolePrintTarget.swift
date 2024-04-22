import Console

internal class TestConsolePrintTarget: ConsolePrintTarget {
    var supportsTerminalColors: Bool

    var buffer: String = ""

    init(supportsTerminalColors: Bool = false) {
        self.supportsTerminalColors = supportsTerminalColors
    }

    func print(_ values: [Any], separator: String, terminator: String) {
        let total = values.map { String(describing: $0) }.joined(separator: separator)

        Swift.print(total, terminator: terminator, to: &buffer)
    }
}
