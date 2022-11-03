import Foundation
import ArgumentParser
import PatternSolver

struct PatternSolverCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "pattern",
        discussion: """
        Invokes a solver for a Pattern game.
        """
    )

    @Argument(help: "The game ID of a pattern game.")
    var gameId: String

    @Flag(help: "Whether to colorize the output in the terminal.")
    var colorized: Bool = false

    func run() throws {
        let game = PatternGame()

        let solver = try game.createSolver(fromGameId: gameId)
        let printer = PatternGridPrinter(bufferForGrid: solver.grid)
        printer.colorized = colorized

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
            print("Could not solve game ID provided.")
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
