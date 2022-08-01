import Foundation
import ArgumentParser
import LoopySolver

struct LoopySolverCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "loopy",
        discussion: """
        Invokes a solver for a Loopy game.
        """
    )

    @Argument(help: "The game ID of a net game.")
    var gameId: String

    @Option(help: "The maximum number of guesses to use when solving the game.")
    var maxGuesses: Int = 10

    @Flag(help: "Whether to colorize the output in the terminal.")
    var colorized: Bool = false
    
    func run() throws {
        let grid = try LoopyGridLoader.loadFromGameID(gameId)
        let printer = try LoopyGridPrinter.forGameId(gameId)
        printer.colorized = colorized
        
        let solver = Solver(grid: grid)
        solver.maxNumberOfGuesses = maxGuesses

        var isSolved = false
        
        let timer = Stopwatch.timing {
            isSolved = solver.solve() == .solved
        }

        if isSolved {
            print("After solve:")
            print("")

            printer.printGrid(grid: solver.grid)
            
            print("Total time: \(timer.intervalString)")
        } else {
            print("Could not solve game ID provided within \(maxGuesses) guesses.")
            print("")

            printer.printGrid(grid: solver.grid)
            
            print("Total time: \(timer.intervalString)")

            Self.exit(withError: Error.unsolved)
        }
    }

    enum Error: Swift.Error {
        case unsolved
    }
}
