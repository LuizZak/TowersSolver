import LoopySolver
import XCTest

// TODO: Work on reducing the number of guesses required to solve some of these
// puzzles

class SolverTests: XCTestCase {
    func testIsSolved() {
        // Grid looks like this:
        //
        // .___.___.___.
        // !___!_2_!_0_!
        // !___!___!___!
        // !___!_2_!_3_!
        //
        let gridGen = LoopySquareGridGen(width: 3, height: 3)
        let n: Int? = nil
        gridGen.setHints(atRow: 0, hints: [n, 2, 0])
        gridGen.setHints(atRow: 1, hints: [n, n, n])
        gridGen.setHints(atRow: 2, hints: [n, 2, 3])
        let controller = LoopyGridController(grid: gridGen.generate())
        controller.setEdge(state: .marked, forFace: 0, edgeIndex: 0)
        controller.setEdge(state: .marked, forFace: 0, edgeIndex: 1)
        controller.setEdge(state: .marked, forFace: 0, edgeIndex: 3)
        controller.setEdge(state: .marked, forFace: 3, edgeIndex: 2)
        controller.setEdge(state: .marked, forFace: 3, edgeIndex: 3)
        controller.setEdge(state: .marked, forFace: 4, edgeIndex: 0)
        controller.setEdge(state: .marked, forFace: 4, edgeIndex: 1)
        controller.setEdge(state: .marked, forFace: 5, edgeIndex: 2)
        controller.setEdge(state: .marked, forFace: 6, edgeIndex: 1)
        controller.setEdge(state: .marked, forFace: 7, edgeIndex: 2)
        controller.setEdge(state: .marked, forFace: 8, edgeIndex: 1)
        controller.setEdge(state: .marked, forFace: 8, edgeIndex: 2)
        let sut = Solver(grid: controller.grid)

        XCTAssert(sut.isSolved)
    }

    func testIsSolvedFalseWhenLoopyLineIsNotComplete() {
        // Grid looks like this:
        //
        // .___.___.___.
        // !___!_2_!_0_!
        // !___!___!___!
        // !___!_2_!_3_!
        //
        let gridGen = LoopySquareGridGen(width: 3, height: 3)
        let n: Int? = nil
        gridGen.setHints(atRow: 0, hints: [n, 2, 0])
        gridGen.setHints(atRow: 1, hints: [n, n, n])
        gridGen.setHints(atRow: 2, hints: [n, 2, 3])
        let controller = LoopyGridController(grid: gridGen.generate())
        controller.setEdge(state: .marked, forFace: 0, edgeIndex: 0)
        controller.setEdge(state: .marked, forFace: 0, edgeIndex: 1)
        controller.setEdge(state: .marked, forFace: 0, edgeIndex: 3)
        controller.setEdge(state: .marked, forFace: 3, edgeIndex: 2)
        // controller.setEdge(state: .marked, forFace: 3, edgeIndex: 3) Missing end link!
        controller.setEdge(state: .marked, forFace: 4, edgeIndex: 0)
        controller.setEdge(state: .marked, forFace: 4, edgeIndex: 1)
        controller.setEdge(state: .marked, forFace: 6, edgeIndex: 1)
        controller.setEdge(state: .marked, forFace: 7, edgeIndex: 2)
        controller.setEdge(state: .marked, forFace: 8, edgeIndex: 1)
        controller.setEdge(state: .marked, forFace: 8, edgeIndex: 2)
        let sut = Solver(grid: controller.grid)

        XCTAssertFalse(sut.isSolved)
    }

    func testIsSolvedFalseWhenHintsAreNotSatisfied() {
        // Grid looks like this:
        //
        //      This hint ends up being violated and two edges are marked!
        //       |
        //       v
        // .___.___.___.
        // !___!_1_!_0_!
        // !___!___!___!
        // !___!_2_!_3_!
        //
        let gridGen = LoopySquareGridGen(width: 3, height: 3)
        let n: Int? = nil
        gridGen.setHints(atRow: 0, hints: [n, 1, 0])
        gridGen.setHints(atRow: 1, hints: [n, n, n])
        gridGen.setHints(atRow: 2, hints: [n, 2, 3])
        let controller = LoopyGridController(grid: gridGen.generate())
        controller.setEdge(state: .marked, forFace: 0, edgeIndex: 0)
        controller.setEdge(state: .marked, forFace: 0, edgeIndex: 1)
        controller.setEdge(state: .marked, forFace: 0, edgeIndex: 3)
        controller.setEdge(state: .marked, forFace: 3, edgeIndex: 2)
        controller.setEdge(state: .marked, forFace: 3, edgeIndex: 3)
        controller.setEdge(state: .marked, forFace: 4, edgeIndex: 0)
        controller.setEdge(state: .marked, forFace: 4, edgeIndex: 1)
        controller.setEdge(state: .marked, forFace: 6, edgeIndex: 1)
        controller.setEdge(state: .marked, forFace: 7, edgeIndex: 2)
        controller.setEdge(state: .marked, forFace: 8, edgeIndex: 1)
        controller.setEdge(state: .marked, forFace: 8, edgeIndex: 2)
        let sut = Solver(grid: controller.grid)

        XCTAssertFalse(sut.isSolved)
    }

    func testIsSolvedFalseWhenLineLoopIsSelfIntersecting() {
        // Grid looks like this:
        //
        // .___.___.
        // !___!___!
        // !___!___!
        //
        // An "8" shaped loop is laid upon the grid such that it forms a closed
        // loop, but this loop is self-intersecting:
        //     .___.
        // .___!___!
        // !___!
        //
        let gridGen = LoopySquareGridGen(width: 2, height: 2)
        let controller = LoopyGridController(grid: gridGen.generate())
        controller.setEdges(state: .marked, forFace: 1)
        controller.setEdges(state: .marked, forFace: 2)
        let sut = Solver(grid: controller.grid)

        XCTAssertFalse(sut.isSolved)
    }

    func testIsConsistent() {
        let gridGen = LoopySquareGridGen(width: 3, height: 3)
        gridGen.setHint(x: 0, y: 0, hint: 0)
        gridGen.setHint(x: 2, y: 0, hint: 3)
        gridGen.setHint(x: 0, y: 2, hint: 3)
        let controller = LoopyGridController(grid: gridGen.generate())
        controller.setEdges(state: .marked, forFace: 2, edgeIndices: [0, 1, 2])
        let sut = Solver(grid: controller.grid)

        XCTAssert(sut.isConsistent)
    }

    func testIsConsistentIsTrueWhenLoopyLineIsClosedWithAllMarkedEdgesPartOfTheLoop() {
        let gridGen = LoopySquareGridGen(width: 3, height: 3)
        let controller = LoopyGridController(grid: gridGen.generate())
        controller.setEdges(state: .marked, forFace: 4, edgeIndices: [0, 1, 2, 3])
        let sut = Solver(grid: controller.grid)

        XCTAssert(sut.isConsistent)
    }

    func testIsConsistentIsFalseWhenLoopyLineIsClosedWhileMarkedEdgesAreNotPartOfTheLoop() {
        let gridGen = LoopySquareGridGen(width: 3, height: 3)
        let controller = LoopyGridController(grid: gridGen.generate())
        controller.setEdges(state: .marked, forFace: 4, edgeIndices: [0, 1, 2, 3])
        controller.setEdge(state: .marked, forEdge: 0)
        let sut = Solver(grid: controller.grid)

        XCTAssertFalse(sut.isConsistent)
    }

    func testIsConsistentIsFalseWhenFaceHasLessEnabledEdgesThanItsHintCount() {
        let gridGen = LoopySquareGridGen(width: 3, height: 3)
        gridGen.setHint(x: 1, y: 1, hint: 3)
        let controller = LoopyGridController(grid: gridGen.generate())
        controller.setEdges(state: .disabled, forFace: 4, edgeIndices: [0, 1])
        let sut = Solver(grid: controller.grid)

        XCTAssertFalse(sut.isConsistent)
    }

    func testIsConsistentIsFalseWhenFaceHasMoreMarkedEdgesThanItsHintCount() {
        let gridGen = LoopySquareGridGen(width: 3, height: 3)
        gridGen.setHint(x: 1, y: 1, hint: 1)
        let controller = LoopyGridController(grid: gridGen.generate())
        controller.setEdges(state: .marked, forFace: 4, edgeIndices: [0, 1])
        let sut = Solver(grid: controller.grid)

        XCTAssertFalse(sut.isConsistent)
    }

    func testSolveSimple() {
        // .___.___.___.
        // !___!_2_!_0_!
        // !___!___!___!
        // !___!_2_!_3_!
        let gridGen = LoopySquareGridGen(width: 3, height: 3)
        let n: Int? = nil
        gridGen.setHints(atRow: 0, hints: [n, 2, 0])
        gridGen.setHints(atRow: 1, hints: [n, n, n])
        gridGen.setHints(atRow: 2, hints: [n, 2, 3])
        let solver = Solver(grid: gridGen.generate())
        solver.maxNumberOfGuesses = 0

        let result = solver.solve()

        XCTAssertEqual(result, .solved)
        let printer = LoopyGridPrinter(squareGridColumns: 3, rows: 3)
        printer.printGrid(grid: solver.grid)
    }

    func testSolveTricky() {
        // .___.___.___.
        // !___!___!_3_!
        // !_1_!___!_1_!
        // !___!_3_!_3_!
        let gridGen = LoopySquareGridGen(width: 3, height: 3)
        let n: Int? = nil
        gridGen.setHints(atRow: 0, hints: [n, n, 3])
        gridGen.setHints(atRow: 1, hints: [1, n, 1])
        gridGen.setHints(atRow: 2, hints: [n, 3, 3])
        let solver = Solver(grid: gridGen.generate())
        solver.maxNumberOfGuesses = 0

        let result = solver.solve()

        XCTAssertEqual(result, .solved)
        let printer = LoopyGridPrinter(squareGridColumns: 3, rows: 3)
        printer.printGrid(grid: solver.grid)
    }

    func testSolveTricky7x7() {
        // .___.___.___.___.___.___.___.
        // !_3_!___!_3_!_3_!_2_!_2_!___!
        // !___!___!_1_!___!_2_!_2_!___!
        // !___!_1_!___!___!___!_2_!___!
        // !_2_!_2_!_1_!_2_!___!_0_!___!
        // !___!_3_!___!___!_2_!_1_!_1_!
        // !___!___!___!___!_2_!_2_!_1_!
        // !_2_!_3_!___!_3_!___!___!___!
        //
        let gridGen = LoopySquareGridGen(width: 7, height: 7)
        let n: Int? = nil
        gridGen.setHints(atRow: 0, hints: [3, n, 3, 3, 2, 2, n])
        gridGen.setHints(atRow: 1, hints: [n, n, 1, n, 2, 2, n])
        gridGen.setHints(atRow: 2, hints: [n, 1, n, n, n, 2, n])
        gridGen.setHints(atRow: 3, hints: [2, 2, 1, 2, n, 0, n])
        gridGen.setHints(atRow: 4, hints: [n, 3, n, n, 2, 1, 1])
        gridGen.setHints(atRow: 5, hints: [n, n, n, n, 2, 2, 1])
        gridGen.setHints(atRow: 6, hints: [2, 3, n, 3, n, n, n])
        let solver = Solver(grid: gridGen.generate())
        solver.maxNumberOfGuesses = 0

        let result = solver.solve()

        XCTAssertEqual(result, .solved)
        let printer = LoopyGridPrinter(squareGridColumns: 7, rows: 7, columnSize: 8, rowSize: 4)
        printer.printGrid(grid: solver.grid)
    }

    func testSolveHard3x3() {
        // .___.___.___.
        // !___!_2_!___!
        // !___!_3_!___!
        // !_2_!___!_2_!
        let gridGen = LoopySquareGridGen(width: 3, height: 3)
        gridGen.setHint(x: 1, y: 0, hint: 2)
        gridGen.setHint(x: 1, y: 1, hint: 3)
        gridGen.setHint(x: 0, y: 2, hint: 2)
        gridGen.setHint(x: 2, y: 2, hint: 2)
        let solver = Solver(grid: gridGen.generate())
        solver.maxNumberOfGuesses = 0

        let result = solver.solve()

        XCTAssertEqual(result, .solved)
        let printer = LoopyGridPrinter(squareGridColumns: 3, rows: 3)
        printer.printGrid(grid: solver.grid)
    }

    func testSolveHard10x10() {
        // .___.___.___.___.___.___.___.___.___.___.
        // !_3_!_2_!_2_!_2_!_3_!_3_!___!_1_!_2_!___!
        // !_2_!___!___!___!___!___!_0_!___!___!_2_!
        // !_3_!___!___!___!___!___!_2_!_1_!_3_!___!
        // !___!___!___!_2_!_3_!___!___!_1_!___!___!
        // !_1_!_3_!_1_!_1_!___!___!_2_!_3_!___!_2_!
        // !___!___!_2_!___!___!___!___!___!_1_!_2_!
        // !___!_3_!_2_!___!_1_!_0_!_2_!___!___!_3_!
        // !___!___!___!___!_1_!___!___!___!___!___!
        // !___!___!_3_!_2_!_2_!_2_!_1_!_0_!___!_2_!
        // !_3_!___!___!___!___!_2_!_3_!_3_!___!___!
        //
        let gridGen = LoopySquareGridGen(width: 10, height: 10)
        let n: Int? = nil
        gridGen.setHints(atRow: 0, hints: [3, 2, 2, 2, 3, 3, n, 1, 2, n])
        gridGen.setHints(atRow: 1, hints: [2, n, n, n, n, n, 0, n, n, 2])
        gridGen.setHints(atRow: 2, hints: [3, n, n, n, n, n, 2, 1, 3, n])
        gridGen.setHints(atRow: 3, hints: [n, n, n, 2, 3, n, n, 1, n, n])
        gridGen.setHints(atRow: 4, hints: [1, 3, 1, 1, n, n, 2, 3, n, 2])
        gridGen.setHints(atRow: 5, hints: [n, n, 2, n, n, n, n, n, 1, 2])
        gridGen.setHints(atRow: 6, hints: [n, 3, 2, n, 1, 0, 2, n, n, 3])
        gridGen.setHints(atRow: 7, hints: [n, n, n, n, 1, n, n, n, n, n])
        gridGen.setHints(atRow: 8, hints: [n, n, 3, 2, 2, 2, 1, 0, n, 2])
        gridGen.setHints(atRow: 9, hints: [3, n, n, n, n, 2, 3, 3, n, n])
        let solver = Solver(grid: gridGen.generate())
        solver.maxNumberOfGuesses = 0

        let result = solver.solve()

        XCTAssertEqual(result, .solved)
        let printer = LoopyGridPrinter(squareGridColumns: 10, rows: 10, columnSize: 6, rowSize: 4)
        printer.printGrid(grid: solver.grid)
    }

    func testSolveHardGreatHexagon3x3() {
        // Attempt solving a Great Hexagon 3x3 game.
        // Game is this one:
        // https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/loopy.html#3x3t5:51b2a21b5b2a1a13c2b2a2133a3
        let gen = LoopyGreatHexagonGridGenerator(width: 3, height: 3)
        gen.loadHints(from: "51b2a21b5b2a1a13c2b2a2133a3")

        let solver = Solver(grid: gen.generate())
        solver.maxNumberOfGuesses = 0

        let result = solver.solve()

        XCTAssertEqual(result, .solved)
        let printer = LoopyGridPrinter(bufferWidth: 50, bufferHeight: 33)
        printer.printGrid(grid: solver.grid)
    }

    func testSolveHardGreatHexagon5x4() {
        // Attempt solving a rather tricky Great Hexagon 5x4 game.
        // Game is this one:
        // https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/loopy.html#5x4t5:53b2b2b522d222b5e2b22a1a22a2a1e25b141e22d3b31a2a01c5a4a2d
        let gen = LoopyGreatHexagonGridGenerator(width: 5, height: 4)
        gen.loadHints(from: "53b2b2b522d222b5e2b22a1a22a2a1e25b141e22d3b31a2a01c5a4a2d")

        let solver = Solver(grid: gen.generate())
        solver.maxNumberOfGuesses = 10

        let result = solver.solve()

        XCTAssertEqual(result, .solved)
        let printer = LoopyGridPrinter(bufferWidth: 73, bufferHeight: 53)
        //printer.printFaceIndices = true
        printer.printGrid(grid: solver.grid)
    }

    func testSolveHardGreatHexagon5x4_2() {
        // Attempt solving a rather tricky Great Hexagon 5x4 game.
        // Game is this one:
        // https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/loopy.html#5x4t5:5c5a2b1b22a0e243b43b13c132b12e1212152f12c1114c2a1121b5b214a
        let gen = LoopyGreatHexagonGridGenerator(width: 5, height: 4)
        gen.loadHints(from: "5c5a2b1b22a0e243b43b13c132b12e1212152f12c1114c2a1121b5b214a")

        let solver = Solver(grid: gen.generate())
        solver.maxNumberOfGuesses = 0

        let result = solver.solve()

        XCTAssertEqual(result, .solved)
        let printer = LoopyGridPrinter(bufferWidth: 73, bufferHeight: 53)
        //printer.printFaceIndices = true
        printer.printGrid(grid: solver.grid)
    }

    func testSolverHardHoneycomb10x10() {
        // Attempt solving a honeycomb game grid.
        // Game is this one:
        // https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/loopy.html#10x10t2:2b35c5f442a4a5443c2b34444223d4a4244a433e3045a4435b2d4a3a4b3a4b4d4454b44a
        let gen = LoopyHoneycombGridGenerator(width: 10, height: 10)
        gen.loadHints(
            from: "2b35c5f442a4a5443c2b34444223d4a4244a433e3045a4435b2d4a3a4b3a4b4d4454b44a"
        )

        let solver = Solver(grid: gen.generate())
        solver.maxNumberOfGuesses = 0

        let result = solver.solve()

        XCTAssertEqual(result, .solved)
        let printer = LoopyGridPrinter(honeycombGridColumns: 10, rows: 10)
        printer.printGrid(grid: solver.grid)
    }

    func testSolveHardHoneycomb11x11() {
        // Attempt solving a honeycomb game grid.
        // Game is this one:
        // https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/loopy.html#11x11t2:5d4a3a2a4a4c5g34d204a45314d433a2a543a2b5344c4545b5b4a3a4c4b44c34a4a53b3a334a4a3a23a5a5b45543
        let gen = LoopyHoneycombGridGenerator(width: 11, height: 11)
        gen.loadHints(
            from:
                "5d4a3a2a4a4c5g34d204a45314d433a2a543a2b5344c4545b5b4a3a4c4b44c34a4a53b3a334a4a3a23a5a5b45543"
        )

        let solver = Solver(grid: gen.generate())
        solver.maxNumberOfGuesses = 0

        let result = solver.solve()

        XCTAssertEqual(result, .solved)
        let printer = LoopyGridPrinter(honeycombGridColumns: 11, rows: 11)
        printer.printGrid(grid: solver.grid)
    }
}
