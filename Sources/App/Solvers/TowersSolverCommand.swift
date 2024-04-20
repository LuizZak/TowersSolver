import Foundation
import ArgumentParser
import TowersSolver

struct TowersSolverCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "towers",
        discussion: """
        Invokes a solver for a Towers game.
        """
    )

    @Argument(help: "The game ID of a towers game.")
    var gameId: String

    @Option(help: "The maximum number of guesses to use when solving the game.")
    var maxGuesses: Int = 10
    
    @Flag(help: "Whether to colorize the output in the terminal.")
    var colorized: Bool = false

    @Flag(help: "Whether to print out the grid values as a flat array of '[a, b, c, ...]' in the console.\nIf set, no other content will be printed.")
    var printGridValues: Bool = false

    var interactive: Bool = false
    var descriptive: Bool = false
    
    func run() throws {
        let game = TowersGame()

        let solver = try game.createSolver(fromGameId: gameId)
        solver.gridPrinter.diffingPrint = interactive && !printGridValues
        solver.gridPrinter.colorized = colorized
        solver.interactive = interactive && !printGridValues
        solver.descriptive = descriptive && !printGridValues

        let timer = Stopwatch.timing {
            solver.solve()
        }

        if printGridValues {
            var gridValues: [Int] = []
            for cell in solver.grid.cells {
                guard let value = cell.solution else {
                    print("[]")
                    return
                }

                gridValues.append(value)
            }

            print(gridValues)
            return
        }

        print("After solve:")
        print("")

        solver.gridPrinter.colorized = false
        solver.gridPrinter.printGrid(grid: solver.grid)

        print("Total time: \(timer.intervalString)")
        print("Total backtracked guess(es): \(solver.totalGuesses)")
    }
}
