#if os(macOS)
    import Foundation
#else
    import Glibc
#endif

import TowersSolver

do {
    print("See solving steps interactively? (y/n)")
    let interactive = (readLine()?.lowercased().first?.description ?? "n") == "y"
    var descriptive = false
    
    if interactive {
        print("Use descriptive solving steps (i.e. show internal logic of solver)? (y/n)")
        descriptive = (readLine()?.lowercased().first?.description ?? "n") == "y"
    }
    
    /*
    var grid = Grid(size: 5)
    
    grid.visibilities.top = [0, 4, 1, 0, 0]
    grid.visibilities.left = [0, 0, 0, 0, 4]
    grid.visibilities.right = [0, 0, 0, 0, 1]
    grid.visibilities.bottom = [4, 0, 3, 0, 0]
    */
    
    /*
    var grid = Grid(size: 6)
    
    grid.visibilities.top = [3, 4, 3, 0, 0, 1]
    grid.visibilities.left = [3, 0, 1, 2, 0, 0]
    grid.visibilities.right = [0, 2, 3, 0, 0, 0]
    grid.visibilities.bottom = [2, 0, 0, 4, 0, 0]
    
    // Pre-solve a few cells (needed for the solution)
    grid.markSolved(x: 2, y: 5, height: 2)
    */
    
    var grid = Grid(size: 8)
    
    grid.visibilities.top = [0, 0, 3, 1, 5, 0, 0, 4]
    grid.visibilities.left = [3, 3, 2, 1, 0, 4, 0, 3]
    grid.visibilities.right = [0, 0, 0, 3, 3, 0, 4, 0]
    grid.visibilities.bottom = [0, 0, 1, 4, 0, 2, 0, 0]
    
    grid.markSolved(x: 5, y: 0, height: 3)
    grid.markSolved(x: 0, y: 2, height: 4)
    grid.markSolved(x: 6, y: 2, height: 3)
    grid.markSolved(x: 2, y: 3, height: 4)
    grid.markSolved(x: 1, y: 4, height: 1)
    grid.markSolved(x: 7, y: 4, height: 4)
    grid.markSolved(x: 2, y: 5, height: 6)
    grid.markSolved(x: 7, y: 6, height: 2)
    grid.markSolved(x: 1, y: 7, height: 5)
    grid.markSolved(x: 4, y: 7, height: 1)
    
    let solver = Solver(grid: grid)
    solver.interactive = interactive
    solver.descriptive = descriptive
    
    solver.gridPrinter.printGrid(grid: solver.grid)
    
    let start = clock()
    
    solver.solve()

    let duration = clock() - start
    
    print("")
    print("After solve:")
    print("")
    
    GridPrinter.printGrid(grid: solver.grid)
    
    let msec = Float(duration) / Float(CLOCKS_PER_SEC)
    
    print("Total time: \(String(format: "%.2f", msec))s")
    print("Total backtracked guess(es): \(solver.totalGuesses)")
}
