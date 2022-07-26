import XCTest

@testable import SignpostSolver

class SolverTests: XCTestCase {


    func testIsSolved_3x3_nonSolved() {
        // Game available at: https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/signpost.html#3x3:1deecaaag9a
        let gridGen = SignpostGridGenerator(rows: 3, columns: 3)
        gridGen.loadFromGameID("1deecaaag9a")
        let sut = Solver(grid: gridGen.grid)

        XCTAssertFalse(sut.isSolved)
    }
    
    func testIsSolved_3x3_invalid() {
        // Game available at: https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/signpost.html#3x3:1d2e6e8c3a7a5a4g9a
        // Note: State is invalid and loaded puzzle is impossible to solve with
        // web UI.
        let gridGen = SignpostGridGenerator(rows: 3, columns: 3)
        gridGen.loadFromGameID("1d2e6e8c3a7a5a4g9a")
        let sut = Solver(grid: gridGen.grid)

        XCTAssertFalse(sut.isSolved)
    }
    
    func testIsSolved_3x3_solved() {
        // Game available at: https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/signpost.html#3x3:1d3e8e6c2a7a5a4g9a
        let gridGen = SignpostGridGenerator(rows: 3, columns: 3)
        gridGen.loadFromGameID("1d3e8e6c2a7a5a4g9a")
        let sut = Solver(grid: gridGen.grid)

        XCTAssertTrue(sut.isSolved)
    }

    func testSolve_3x3() {
        // Game available at: https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/signpost.html#3x3:1deecaaag9a
        let gridGen = SignpostGridGenerator(rows: 3, columns: 3)
        gridGen.loadFromGameID("1deecaaag9a")
        let sut = Solver(grid: gridGen.grid)

        sut.solve()
        
        let printer = SignpostGridPrinter(bufferForGrid: sut.grid)
        printer.printGrid(grid: sut.grid)
        XCTAssertTrue(sut.isSolved)
    }

    func testSolve_4x4() {
        // Game available at: https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/signpost.html#4x4:1cefgcdbfafbechb16a
        let gridGen = SignpostGridGenerator(rows: 4, columns: 4)
        gridGen.loadFromGameID("1cefgcdbfafbechb16a")
        let sut = Solver(grid: gridGen.grid)

        sut.solve()
        
        let printer = SignpostGridPrinter(bufferForGrid: sut.grid)
        printer.printGrid(grid: sut.grid)
        XCTAssertTrue(sut.isSolved)
    }

    func testSolve_5x5() {
        // Game available at: https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/signpost.html#5x5:1d17d3cffcdcgedgafacahhgaccb25a
        let gridGen = SignpostGridGenerator(rows: 5, columns: 5)
        gridGen.loadFromGameID("1d17d3cffcdcgedgafacahhgaccb25a")
        let sut = Solver(grid: gridGen.grid)

        sut.solve()
        
        let printer = SignpostGridPrinter(bufferForGrid: sut.grid)
        printer.printGrid(grid: sut.grid)
        XCTAssertTrue(sut.isSolved)
    }

    func testSolve_7x7() {
        // Game available at: https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/signpost.html#7x7:1c5dcffgf45decefagded47gfff25cd46becb35hc18fabhf11hcca9ca20eaabbaaa49a
        let gridGen = SignpostGridGenerator(rows: 7, columns: 7)
        gridGen.loadFromGameID("1c5dcffgf45decefagded47gfff25cd46becb35hc18fabhf11hcca9ca20eaabbaaa49a")
        let sut = Solver(grid: gridGen.grid)

        sut.solve()
        
        let printer = SignpostGridPrinter(bufferForGrid: sut.grid)
        printer.printGrid(grid: sut.grid)
        XCTAssertTrue(sut.isSolved)
    }

    func testSolve_11x11() {
        // Game available at: https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/signpost.html#11x11:1eee14dgef20e44e74gg2e30d39dc18cebc28cg51feeed25d67gg118fceed102dbbebcchhgb76cf13ac40ghbg77eh3adef119cd52ch53egh42dceab96cfh86gggcbd115bah84c33ceh9gc108c64cc109ddaa31gg107g100dbh89c70gb91hb54h78hg61aa88bcg81g83a93cha121a
        let gridGen = SignpostGridGenerator(rows: 11, columns: 11)
        gridGen.loadFromGameID("1eee14dgef20e44e74gg2e30d39dc18cebc28cg51feeed25d67gg118fceed102dbbebcchhgb76cf13ac40ghbg77eh3adef119cd52ch53egh42dceab96cfh86gggcbd115bah84c33ceh9gc108c64cc109ddaa31gg107g100dbh89c70gb91hb54h78hg61aa88bcg81g83a93cha121a")
        let sut = Solver(grid: gridGen.grid)

        sut.solve()
        
        let printer = SignpostGridPrinter(bufferForGrid: sut.grid)
        printer.printGrid(grid: sut.grid)
        XCTAssertTrue(sut.isSolved)
    }
}
