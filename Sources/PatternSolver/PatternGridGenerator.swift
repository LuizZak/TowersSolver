import MiniLexer

public class PatternGridGenerator {
    public let rows: Int
    public let columns: Int

    internal(set) public var grid: PatternGrid

    public init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns

        grid = PatternGrid(rows: rows, columns: columns)
    }

    /// Loads a Signpost grid from a given game ID.
    public convenience init(gameId: String) throws {
        let parsedGame = try ParsedGame(string: gameId)

        self.init(rows: parsedGame.width, columns: parsedGame.height)

        try loadFromGameID(parsedGame.field)
    }

    public func loadFromGameID(_ gameId: String) throws {
        let lexer = Lexer(input: gameId)

        func readRunHints(lexer: Lexer, maximum: Int) throws -> PatternGrid.RunsHint {
            var hint = PatternGrid.RunsHint(runs: [])

            var expectsNumber = false
            while lexer.safeNextCharPasses(with: Lexer.isDigit) {
                hint.runs.append(try lexer.consumeInt())

                if !lexer.advanceIf(equals: ".") {
                    expectsNumber = false
                    break
                }

                expectsNumber = true
            }

            if expectsNumber {
                throw ParseError.invalidHints(
                    message: "Expected number after '.' hint separator"
                )
            }

            if hint.requiredEmptySpace > maximum {
                throw ParseError.invalidHints(
                    message: "Number of hints exceeds available space. Can fit up to \(maximum) but found \(hint.requiredEmptySpace)"
                )
            }

            return hint
        }

        // Fill hints for columns and rows
        let hintsCount = columns + rows
        for index in (0..<hintsCount) {
            let maximum = index < columns ? columns : rows

            try grid.hints[index] = readRunHints(lexer: lexer, maximum: maximum)
            
            if lexer.advanceIf(equals: "/") {
                // Hints separator
                if index + 1 == hintsCount {
                    throw ParseError.invalidHints(message: "Too many hints. Expected \(hintsCount) found \(index + 1)")
                }
            } else if lexer.isEof() || lexer.safeIsNextChar(equalTo: ",") {
                // Grid cell clues separator
                if index + 1 < hintsCount {
                    throw ParseError.invalidHints(message: "Too few hints. Expected \(hintsCount) found \(index + 1)")
                }
                break
            }
        }

        // TODO: Implement clue tile parsing
    }

    public func setColumnHint(_ column: Int, runs: [Int]) {
        grid.setHintForColumn(column, runs: runs)
    }

    public func setRowHint(_ row: Int, runs: [Int]) {
        grid.setHintForRow(row, runs: runs)
    }

    public func setTileState(column: Int, row: Int, _ state: PatternTile.State) {
        grid[column: column, row: row].state = state
    }

    struct ParsedGame {
        var width: Int
        var height: Int
        var field: String

        /// Initializes a parsed game from a game ID with the regex format
        /// `(\d+)(x(\d+))?:(.+)`
        init(string: String) throws {
            let lexer = Lexer(input: string)
            
            // Width x Height
            width = try lexer.consumeInt("Expected width integer value")

            if lexer.safeIsNextChar(equalTo: "x") {
                try lexer.advance(expectingCurrent: "x")
                height = try lexer.consumeInt("Expected height integer value")
            } else {
                height = width
            }

            // Separator
            try lexer.advance(expectingCurrent: ":")
            
            // Game string
            field = String(lexer.consumeRemaining())
        }
    }

    public enum ParseError: Error {
        case invalidHints(message: String)
    }
}
