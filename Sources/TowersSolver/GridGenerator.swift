import Commons
import MiniLexer

/// Generator for Towers grids
public class GridGenerator {
    private(set) public var grid: Grid

    public init(gameId: String) throws {
        let parsedGame = try ParsedGame(string: gameId)

        grid = Grid(size: parsedGame.width)

        loadHints(parsedGame.field)
    }

    public func loadHints(_ gameId: String) {
        do {

            let lexer = Lexer(input: gameId)
            
            let expectedSideClues = grid.size * 4

            // Order of side hint loading:
            // 1. top
            // 2. bottom
            // 3. left
            // 4. right
            // The indexing in the appropriate arrays is handled by
            // `Grid.Visibilities`
            for i in 0..<expectedSideClues {
                if i > 0 {
                    try lexer.advance(expectingCurrent: "/")
                }

                if let hint = try? lexer.consumeInt() {
                    grid.visibilities[i] = hint
                } else {
                    grid.visibilities[i] = 0
                }
            }

            if lexer.advanceIf(equals: ",") {
                var pos = 0

                while !lexer.isEof() {
                    let c = try lexer.peek()
                    let cChar = ascii(for: c)

                    if Lexer.isLowercaseLetter(c) {
                        pos += cChar - ascii(for: "a") + 1

                        try lexer.advance()
                    } else if c == "_" {
                        // no-op
                        try lexer.advance()
                    } else if Lexer.isDigit(c) {
                        let val = try lexer.consumeInt()

                        if val < 0 || val > grid.size {
                            throw Error.invalidGameId
                        }
                        if pos >= grid.cells.count {
                            throw Error.invalidGameId
                        }

                        let x = pos % grid.size
                        let y = pos / grid.size

                        grid.markSolved(x: x, y: y, height: val)

                        pos += 1
                    }
                }

                if pos != grid.cells.count {
                    throw Error.invalidGameId
                }
            }
        } catch {
            print("Error loading from game id: \(error)")
        }
    }

    public static func gameId(for grid: Grid) -> String {
        // 9:3/4//1///3/5/5/3///2//2/4///3/2//2/4/1///5///3/4/3///2/,d3f1f2n7g2i6_8c3h8a7a5f1d

        // Visibilities
        let visibilities = grid.visibilities.asArray.map {
            $0 == 0 ? "" : $0.description
        }.joined(separator: "/")

        // Hints
        var hints = ""

        if grid.cells.contains(where: { $0.hasSolution }) {
            hints += ","

            var run = 0
            for i in 0...grid.cells.count {
                let n = i < grid.cells.count ? (grid.cells[i].solution ?? 0) : -1

                if n == 0 {
                    run += 1
                    continue
                }

                if run > 0 {
                    while run > 0 {
                        let r = min(UInt8(run), 26)
                        let scalar: UInt8 = r - 1 + asciiByte(for: "a")
                        run -= Int(r)
                        
                        hints.append(
                            Character(Unicode.Scalar(scalar))
                        )
                    }
                } else {
                    if i > 0 && n > 0 {
                        hints += "_"
                    }
                }

                if n > 0 {
                    hints += n.description
                }

                run = 0
            }
        }

        return "\(grid.size):\(visibilities)\(hints)"
    }

    enum Error: Swift.Error {
        case invalidGameId
    }

    struct ParsedGame {
        var width: Int
        var field: String

        /// Initializes a parsed game from a game ID with the regex format
        /// `(\d+):(.+)`
        init(string: String) throws {
            let lexer = Lexer(input: string)
            
            // Width
            width = try lexer.consumeInt("Expected width integer value")

            // Separator
            try lexer.advance(expectingCurrent: ":")
            
            // Game string
            field = String(lexer.consumeRemaining())
        }
    }
}

private func ascii(for char: UnicodeScalar) -> Int {
    return Int(char.value)
}

/// - precondition: 'char' represents an ASCII character that can be fit within
/// a single byte (8 bits).
private func asciiByte(for char: UnicodeScalar) -> UInt8 {
    return UInt8(char.value)
}
