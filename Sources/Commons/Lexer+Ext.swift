import MiniLexer

public extension Lexer {
    /// Attempts to read the current read position as a sequence of digits,
    /// returning an integer built with the numbers.
    ///
    /// The read head is moved to the first non-digit character in the string
    /// afterwards.
    ///
    /// Does not move the read head and throws an error if the current read
    /// position is not a digit.
    ///
    /// - note: Regex equivalent: `\d+`
    @inlinable
    func consumeInt(_ errorMessage: @autoclosure () -> String = "Expected integer substring") throws -> Int {
        if try !Lexer.isDigit(peek()) {
            throw syntaxError(errorMessage())
        }

        let string = consume(while: Lexer.isDigit)
        guard let result = Int(string) else {
            throw syntaxError(errorMessage())
        }

        return result
    }
}
