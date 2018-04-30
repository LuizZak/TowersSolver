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
        let solver = Solver(field: gridGen.generate())
        
        let result = solver.solve()
        
        XCTAssertEqual(result, .solved)
        
        let printer = LoopyFieldPrinter(bufferWidth: 40, bufferHeight: 20)
        printer.printField(field: solver.field)
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
        let solver = Solver(field: gridGen.generate())
        
        let result = solver.solve()
        
        XCTAssertEqual(result, .solved)
        
        let printer = LoopyFieldPrinter(bufferWidth: 40, bufferHeight: 20)
        printer.printField(field: solver.field)
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
        let solver = Solver(field: gridGen.generate())
        
        let result = solver.solve()
        
        XCTAssertEqual(result, .solved)
        
        let printer = LoopyFieldPrinter(bufferWidth: 70, bufferHeight: 40)
        printer.printField(field: solver.field)
    }
    
    func testSolveHard() {
        // .___.___.___.
        // !___!_2_!___!
        // !___!_3_!___!
        // !_2_!___!_2_!
        let gridGen = LoopySquareGridGen(width: 3, height: 3)
        gridGen.setHint(x: 1, y: 0, hint: 2)
        gridGen.setHint(x: 1, y: 1, hint: 3)
        gridGen.setHint(x: 0, y: 2, hint: 2)
        gridGen.setHint(x: 2, y: 2, hint: 2)
        let solver = Solver(field: gridGen.generate())
        
        let result = solver.solve()
        
        XCTAssertEqual(result, .solved)
        
        let printer = LoopyFieldPrinter(bufferWidth: 40, bufferHeight: 20)
        printer.printField(field: solver.field)
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
        let controller = LoopyFieldController(field: gridGen.generate())
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
        let sut = Solver(field: controller.field)
        
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
        let controller = LoopyFieldController(field: gridGen.generate())
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
        let sut = Solver(field: controller.field)
        
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
        let controller = LoopyFieldController(field: gridGen.generate())
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
        let sut = Solver(field: controller.field)
        
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
        let controller = LoopyFieldController(field: gridGen.generate())
        controller.setEdges(state: .marked, forFace: 1)
        controller.setEdges(state: .marked, forFace: 2)
        let sut = Solver(field: controller.field)
        
        XCTAssertFalse(sut.isSolved)
    }
}
