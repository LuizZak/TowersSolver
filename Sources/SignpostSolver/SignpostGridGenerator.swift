import Commons
import MiniLexer

/// A Signpost grid generator
public class SignpostGridGenerator {
    private static let dirMax = 9

    public let rows: Int
    public let columns: Int

    internal(set) public var grid: Grid

    public init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns

        grid = Grid(rows: rows, columns: columns)
    }

    /// Loads a Signpost grid from a given game ID.
    public convenience init(gameId: String) throws {
        let parsedGame = try ParsedGame(string: gameId)

        self.init(rows: parsedGame.width, columns: parsedGame.height)

        loadFromGameID(parsedGame.field)
    }

    public func loadFromGameID(_ gameId: String) {
        var index = gameId.startIndex

        func ascii(for char: UnicodeScalar) -> Int {
            return Int(char.value)
        }
        func charAtIndex(_ index: String.Index) -> Int? {
            gameId[index].asciiValue.map(Int.init)
        }
        func charAtIndexMatches(_ index: String.Index, char: UnicodeScalar) -> Bool {
            charAtIndex(index) == ascii(for: char)
        }

        var num: Int = 0, i: Int = 0

        while index < gameId.endIndex {
            defer { _ = gameId.formIndex(&index, offsetBy: 1, limitedBy: gameId.endIndex) }
            
            if i >= grid.tileCount {
                print("Game description longer than expected")
                return
            }

            guard let char = charAtIndex(index) else { continue }

            let charInt: Int?

            switch char {
            // Tiles
            case ascii(for: "0")...ascii(for: "9"):
                charInt = char - ascii(for: "0")

            default:
                charInt = nil
            }

            if let charInt = charInt {
                num = num * 10 + charInt

                if num > grid.tileCount {
                    print("Number out of range of grid tiles: \(num)")
                    return
                }
            } else if let orientation = Tile.Orientation(rawValue: char - ascii(for: "a")) {
                if num > 0 {
                    if num == 1 {
                        grid[sequential: i].isStartTile = true
                    }
                    if num == grid.tileCount {
                        grid[sequential: i].isEndTile = true
                    }

                    grid[sequential: i].solution = num
                    num = 0
                }

                grid[sequential: i].orientation = orientation
                
                i += 1
            } else {
                print("Invalid character in game description: \(char)")
                return
            }
        }

        _tieConnectedTiles()
    }

    /// For tiles that are sequentially numbered, pre-fill the connected state
    /// of the tiles.
    private func _tieConnectedTiles() {
        for tileCoord in grid.tileCoordinates {
            let tile = grid[tileCoord]

            guard let solution = tile.solution else {
                continue
            }

            let nextCoords = grid.tileCoordsPointedBy(column: tileCoord.column, row: tileCoord.row)

            for next in nextCoords {
                let nextTile = grid[next]

                if nextTile.solution == solution + 1 {
                    grid[tileCoord].connectionState = .connectedTo(.init(column: next.column, row: next.row))
                    break
                }
            }
        }
    }

    struct ParsedGame {
        var width: Int
        var height: Int
        var field: String

        /// Initializes a parsed game from a game ID with the regex format
        /// `(\d+)x(\d+):(.+)`
        init(string: String) throws {
            let lexer = Lexer(input: string)
            
            // Width x Height
            width = try lexer.consumeInt("Expected width integer value")
            try lexer.advance(expectingCurrent: "x")
            height = try lexer.consumeInt("Expected height integer value")

            // Separator
            try lexer.advance(expectingCurrent: ":")
            
            // Game string
            field = String(lexer.consumeRemaining())
        }
    }
}
