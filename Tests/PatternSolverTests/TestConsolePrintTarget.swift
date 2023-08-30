import Console

internal class TestConsolePrintTarget: ConsolePrintTarget {
    var supportsTerminalColors: Bool {
        return false
    }

    var buffer: String = ""

    func print(_ values: [Any], separator: String, terminator: String) {
        let total = values.map { String(describing: $0) }.joined(separator: separator)

        Swift.print(total, terminator: terminator, to: &buffer)
    }
}
