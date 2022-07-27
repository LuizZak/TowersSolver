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
        XCTAssertEqual(sut.grid.tileNumbers, [
            1, 3, 8,
            6, 2, 7,
            5, 4, 9,
        ])
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
        XCTAssertEqual(sut.grid.tileNumbers, [
            1,  11, 2,  10,
            8,  3,  9,  5,
            7,  12, 4,  15,
            13, 6,  14, 16,
        ])
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
        XCTAssertEqual(sut.grid.tileNumbers, [
            1,  17, 3,  4,  10,
            7,  24, 5,  6,  8,
            15, 14, 2,  18, 9,
            12, 16, 13, 23, 22,
            11, 19, 20, 21, 25,
        ])
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
        XCTAssertEqual(sut.grid.tileNumbers, [
            1,  5,  40, 24, 41, 4,  2,
            45, 30, 6,  7,  17, 3,  44,
            14, 31, 48, 47, 12, 36, 27,
            25, 15, 46, 8,  34, 26, 35,
            42, 18, 39, 43, 29, 22, 11,
            19, 32, 38, 9,  33, 20, 10,
            13, 37, 28, 23, 16, 21, 49,
        ])
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
        XCTAssertEqual(sut.grid.tileNumbers, [
            1,   75,  6,  14,  5,   48,  113, 20,  44,  74,  73,
            2,   30,  39, 27,  18,  80,  19,  50,  28,  29,  51,
            99,  55,  68, 58,  25,  67,  66,  118, 45,  22,  46,
            62,  102, 17, 79,  59,  49,  15,  116, 117, 112, 16,
            4,   76,  41, 13,  11,  40,  26,  21,  12,  77,  111,
            3,   114, 63, 103, 119, 120, 52,  24,  53,  23,  47,
            42,  56,  87, 57,  72,  96,  97,  38,  86,  95,  37,
            8,   43,  69, 115, 10,  98,  84,  33,  34,  85,  9,
            104, 108, 64, 106, 109, 92,  65,  32,  31,  105, 107,
            100, 71,  7,  89,  70,  110, 91,  36,  54,  78,  90,
            61,  101, 88, 82,  60,  81,  83,  93,  35,  94,  121,
        ])
    }
}
