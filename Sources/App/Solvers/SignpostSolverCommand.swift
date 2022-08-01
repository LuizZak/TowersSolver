import Foundation
import ArgumentParser
import SignpostSolver

struct SignpostSolverCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "signpost",
        discussion: """
        Invokes a solver for a Net game.
        """
    )

    @Argument(help: "The game ID of a net game.")
    var gameId: String

    @Flag(help: "Whether to colorize the output in the terminal. Note: Unused for Signpost solvers")
    var colorized: Bool = false
    
    func run() throws {
        let gridGen = try SignpostGridGenerator(gameId: gameId)
        let solver = Solver(grid: gridGen.grid)
        let printer = SignpostGridPrinter(bufferForGrid: solver.grid)
        printer.colorized = colorized

        let timer = Stopwatch.timing {
            solver.solve()
        }

        if solver.isSolved {
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
