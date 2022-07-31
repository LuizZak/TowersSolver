import MiniLexer

public extension Lexer {
    /// Attempts to read the current read position as a sequence of digits,
    /// returning an integer built with the numbers.
    ///
    /// Throws an error if the current read position is not a digit.
    ///
    /// - note: Regex equivalent: `\d+`
    func consumeInt(_ errorMessage: @autoclosure () -> String = "Expected integer substring") throws -> Int {
        let string = consume(while: Lexer.isDigit)
        guard let result = Int(string) else {
            throw syntaxError(errorMessage())
        }

        return result
    }
}
