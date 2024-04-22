import Commons
import MiniLexer

public class LightUpGridGenerator {
    public let rows: Int
    public let columns: Int

    internal(set) public var grid: LightUpGrid

    public init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns

        grid = LightUpGrid(rows: rows, columns: columns)
    }

    /// Loads a Light Up grid from a given game ID.
    public convenience init(gameId: String) throws {
        let parsedGame = try ParsedGame(string: gameId)

        self.init(rows: parsedGame.height, columns: parsedGame.width)

        try loadFromGameID(parsedGame.field)
    }

    public func loadFromGameID(_ gameId: String) throws {
        let lexer = Lexer(input: gameId)

        var run = 0

        for row in 0..<grid.rows {
            for column in 0..<grid.columns {
                if run == 0 {
                    if lexer.safeNextCharPasses(with: Lexer.isLowercaseLetter) {
                        run = try ParseUtils.charToInt(lexer.next())
                    }
                }

                if run > 0 {
                    run -= 1
                } else {
                    switch try lexer.peek() {
                    // Hint on a black square
                    case "0", "1", "2", "3", "4":
                        setTileState(
                            column: column,
                            row: row,
                            .wall(hint: ParseUtils.charToInt(try lexer.next(), startIndex: "0") - 1)
                        )
                    
                    // Black square
                    case "B":
                        try lexer.advance()
                        setTileState(column: column, row: row, .wall())
                    
                    default:
                        throw lexer.unexpectedCharacterError(char: try lexer.peek(), "Unexpected character in Light Up game ID")
                    }
                }
            }
        }

        if !lexer.isEof() {
            assertionFailure("Unexpected trailing characters in Light Up game ID: '\(lexer.consumeRemaining())'")
        }
    }

    public func setTileState(column: Int, row: Int, _ state: LightUpTile.State) {
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
        case invalidGameId(message: String)
    }
}
