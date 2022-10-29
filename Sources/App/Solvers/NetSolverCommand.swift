import Foundation
import ArgumentParser
import NetSolver

struct NetSolverCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "net",
        discussion: """
        Invokes a solver for a Net game.
        """
    )

    @Argument(help: "The game ID of a net game.")
    var gameId: String

    @Option(help: "The maximum number of guesses to use when solving the game.")
    var maxGuesses: Int = 10

    @Flag(help: "Whether to colorize the output in the terminal.")
    var colorized: Bool = false
    
    func run() throws {
        let game = NetGame()

        let solver = try game.createSolver(fromGameId: gameId)
        let printer = NetGridPrinter(bufferForGridWidth: solver.grid.columns, height: solver.grid.rows)
        printer.colorized = colorized
        solver.maxGuesses = maxGuesses

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
