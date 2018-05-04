import XCTest
@testable import LoopySolver

class SolverTests: XCTestCase {
    func testSolveSimple() {
        // .___.___.___.
        // !___!_2_!_0_!
        // !___!___!___!
        // !___!_2_!_3_!
        let gridGen = LoopySquareGridGen(width: 3, height: 3)
        gridGen.setHint(x: 1, y: 0, hint: 2)
        gridGen.setHint(x: 2, y: 0, hint: 0)
        gridGen.setHint(x: 1, y: 2, hint: 2)
        gridGen.setHint(x: 2, y: 2, hint: 3)
        let solver = Solver(grid: gridGen.generate())
        
        let result = solver.solve()
        
        XCTAssertEqual(result, .solved)
        let printer = LoopyGridPrinter(bufferWidth: 14, bufferHeight: 7)
        printer.printGrid(grid: solver.grid)
    }
    
    func testSolveTricky() {
        // .___.___.___.
        // !___!___!_3_!
        // !_1_!___!_1_!
        // !___!_3_!_3_!
        let gridGen = LoopySquareGridGen(width: 3, height: 3)
        gridGen.setHint(x: 2, y: 0, hint: 3)
        gridGen.setHint(x: 0, y: 1, hint: 1)
        gridGen.setHint(x: 2, y: 1, hint: 1)
        gridGen.setHint(x: 1, y: 2, hint: 3)
        gridGen.setHint(x: 2, y: 2, hint: 3)
        let solver = Solver(grid: gridGen.generate())
        
        let result = solver.solve()
        
        XCTAssertEqual(result, .solved)
        let printer = LoopyGridPrinter(bufferWidth: 14, bufferHeight: 7)
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
        gridGen.setHint(x: 0, y: 0, hint: 3)
        gridGen.setHint(x: 2, y: 0, hint: 3)
        gridGen.setHint(x: 3, y: 0, hint: 3)
        gridGen.setHint(x: 4, y: 0, hint: 2)
        gridGen.setHint(x: 5, y: 0, hint: 2)
        //
        gridGen.setHint(x: 2, y: 1, hint: 1)
        gridGen.setHint(x: 4, y: 1, hint: 2)
        gridGen.setHint(x: 5, y: 1, hint: 2)
        //
        gridGen.setHint(x: 1, y: 2, hint: 1)
        gridGen.setHint(x: 5, y: 2, hint: 2)
        //
        gridGen.setHint(x: 0, y: 3, hint: 2)
        gridGen.setHint(x: 1, y: 3, hint: 2)
        gridGen.setHint(x: 2, y: 3, hint: 1)
        gridGen.setHint(x: 3, y: 3, hint: 2)
        gridGen.setHint(x: 5, y: 3, hint: 0)
        //
        gridGen.setHint(x: 1, y: 4, hint: 3)
        gridGen.setHint(x: 4, y: 4, hint: 2)
        gridGen.setHint(x: 5, y: 4, hint: 1)
        gridGen.setHint(x: 6, y: 4, hint: 1)
        //
        gridGen.setHint(x: 4, y: 5, hint: 2)
        gridGen.setHint(x: 5, y: 5, hint: 2)
        gridGen.setHint(x: 6, y: 5, hint: 1)
        //
        gridGen.setHint(x: 0, y: 6, hint: 2)
        gridGen.setHint(x: 1, y: 6, hint: 3)
        gridGen.setHint(x: 3, y: 6, hint: 3)
        let solver = Solver(grid: gridGen.generate())
        solver.maxNumberOfGuesses = 6
        
        let result = solver.solve()
        
        XCTAssertEqual(result, .solved)
        let printer = LoopyGridPrinter(bufferWidth: 58, bufferHeight: 29)
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
        
        let result = solver.solve()
        
        XCTAssertEqual(result, .solved)
        let printer = LoopyGridPrinter(bufferWidth: 14, bufferHeight: 7)
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
        solver.maxNumberOfGuesses = 12
        
        let result = solver.solve()
        
        XCTAssertEqual(result, .solved)
        let printer = LoopyGridPrinter(bufferWidth: 62, bufferHeight: 41)
        printer.printGrid(grid: solver.grid)
    }
    
    func testIsSolved() {
        // Grid looks like this:
        //
        // .___.___.___.
        // !___!_2_!_0_!
        // !___!___!___!
        // !___!_2_!_3_!
        //
        let gridGen = LoopySquareGridGen(width: 3, height: 3)
        gridGen.setHint(x: 1, y: 0, hint: 2)
        gridGen.setHint(x: 2, y: 0, hint: 0)
        gridGen.setHint(x: 1, y: 2, hint: 2)
        gridGen.setHint(x: 2, y: 2, hint: 3)
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
        gridGen.setHint(x: 1, y: 0, hint: 2)
        gridGen.setHint(x: 2, y: 0, hint: 0)
        gridGen.setHint(x: 1, y: 2, hint: 2)
        gridGen.setHint(x: 2, y: 2, hint: 3)
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
        // .___.___.___.
        // !___!_1_!_0_!
        // !___!___!___!
        // !___!_2_!_3_!
        //
        let gridGen = LoopySquareGridGen(width: 3, height: 3)
        gridGen.setHint(x: 1, y: 0, hint: 1) // This hint ends up being violated and two edges are marked!
        gridGen.setHint(x: 2, y: 0, hint: 0)
        gridGen.setHint(x: 1, y: 2, hint: 2)
        gridGen.setHint(x: 2, y: 2, hint: 3)
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
}
