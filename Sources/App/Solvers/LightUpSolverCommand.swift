import Foundation
import ArgumentParser
import LightUpSolver

struct LightUpSolverCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "light-up",
        discussion: """
        Invokes a solver for a Light Up game.
        """
    )

    @Argument(help: "The game ID of a net game.")
    var gameId: String

    @Option(help: "The maximum number of guesses to use when solving the game.")
    var maxGuesses: Int = 10

    @Flag(help: "Whether to colorize the output in the terminal.")
    var colorized: Bool = false
    
    func run() throws {
        let game = LightUpGame()

        let solver = try game.createSolver(fromGameId: gameId)
        let printer = LightUpGridPrinter(bufferForGrid: solver.grid)
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
