import Commons
import MiniLexer

/// Allows loading game grids from a loopy game ID.
public class LoopyGridLoader {
    /// Attempts to load a Loopy grid from a given game ID.
    /// Note: Currently, only square (t0), honeycomb (t2), and great-hexagonal
    /// (t5) game configurations are recognized.
    public static func loadFromGameID(_ gameID: String) throws -> LoopyGrid {
        let parsed = try ParsedGame(string: gameID)
        guard let type = GridType(rawValue: parsed.type) else {
            throw Error.unsupportedGridType(parsed.type)
        }

        let generator = type.makeGenerator(width: parsed.width, height: parsed.height)

        generator.loadHints(from: parsed.field)

        return generator.generate()
    }

    public enum Error: Swift.Error {
        case unsupportedGridType(_ type: Int)
    }

    struct ParsedGame {
        var width: Int
        var height: Int
        var type: Int
        var field: String

        /// Initializes a parsed game from a game ID with the regex format
        /// `(\d+)x(\d+)t(\d+):(.+)`
        init(string: String) throws {
            let lexer = Lexer(input: string)
            
            // Width x Height
            width = try lexer.consumeInt("Expected width integer value")
            try lexer.advance(expectingCurrent: "x")
            height = try lexer.consumeInt("Expected height integer value")

            // Type flag
            try lexer.advance(expectingCurrent: "t")

            type = try lexer.consumeInt("Expected type integer value")

            // Separator
            try lexer.advance(expectingCurrent: ":")
            
            // Game string
            field = String(lexer.consumeRemaining())
        }
    }

    enum GridType: Int {
        case square = 0
        case honeycomb = 2
        case greatHexagon = 5

        func makeGridPrinter(width: Int, height: Int) -> LoopyGridPrinter {
            switch self {
            case .square:
                return LoopyGridPrinter(squareGridColumns: width, rows: height)
            
            case .honeycomb:
                return LoopyGridPrinter(honeycombGridColumns: width, rows: height)

            case .greatHexagon:
                return LoopyGridPrinter(greatHexagonGridColumns: width, rows: height)
            }
        }

        func makeGenerator(width: Int, height: Int) -> BaseLoopyGridGenerator {
            switch self {
            case .square:
                return LoopySquareGridGen(width: width, height: height)

            case .honeycomb:
                return LoopyHoneycombGridGenerator(width: width, height: height)

            case .greatHexagon:
                return LoopyGreatHexagonGridGenerator(width: width, height: height)
            }
        }
    }
}

public extension LoopyGridPrinter {
    /// Returns a grid printer configured to print a game with a given ID.
    static func forGameId(_ gameId: String) throws -> LoopyGridPrinter {
        let parsed = try LoopyGridLoader.ParsedGame(string: gameId)
        guard let type = LoopyGridLoader.GridType(rawValue: parsed.type) else {
            throw LoopyGridLoader.Error.unsupportedGridType(parsed.type)
        }

        return type.makeGridPrinter(width: parsed.width, height: parsed.height)
    }
}
