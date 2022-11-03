import ArgumentParser
import TowersSolver

struct SolveCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "TowersSolver",
        discussion: """
        Invokes a solver for one of Simon Tatham's puzzles available within \
        this program.
        """,
        subcommands: [
            TowersSolverCommand.self,
            NetSolverCommand.self,
            LoopySolverCommand.self,
            SignpostSolverCommand.self,
            PatternSolverCommand.self,
        ]
    )
    
    func run() throws {
        print("See solving steps interactively? (y/n)")
        let interactive = (readLine()?.lowercased().first?.description ?? "n") == "y"
        var descriptive = false

        if interactive {
            print("Use descriptive solving steps (i.e. show internal logic of solver)? (y/n)")
            descriptive = (readLine()?.lowercased().first?.description ?? "n") == "y"
        }

        var towers = TowersSolverCommand()
        towers.interactive = interactive
        towers.descriptive = descriptive
        towers.colorized = true

        towers.gameId = "8://3/1/5///4///1/4//2///3/3/2/1//4//3////3/3//4/,e3j4e3c4f1e4b6l2a5b1c"
        towers.maxGuesses = 10

        try towers.run()
    }
}
