import XCTest
@testable import LoopySolver

class SolverTests: XCTestCase {
    func testSolveSimple() {
        // .___.___.___.
        // !___!_2_!_0_!
        // !___!___!___!
        // !___!_2_!_3_!
        let gridGen = LoopySquareGrid(width: 3, height: 3)
        gridGen.setHint(x: 1, y: 0, hint: 2)
        gridGen.setHint(x: 2, y: 0, hint: 0)
        gridGen.setHint(x: 1, y: 2, hint: 2)
        gridGen.setHint(x: 2, y: 2, hint: 3)
        let solver = Solver(grid: gridGen.generate())
        
        let result = solver.solve()
        
        XCTAssertEqual(result, .solved)
    }
    
    func testIsSolved() {
        // Grid looks like this:
        //
        // .___.___.___.
        // !___!_2_!_0_!
        // !___!___!___!
        // !___!_2_!_3_!
        //
        let gridGen = LoopySquareGrid(width: 3, height: 3)
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
        let gridGen = LoopySquareGrid(width: 3, height: 3)
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
        let gridGen = LoopySquareGrid(width: 3, height: 3)
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
        let gridGen = LoopySquareGrid(width: 2, height: 2)
        let controller = LoopyGridController(grid: gridGen.generate())
        controller.setEdges(state: .marked, forFace: 1)
        controller.setEdges(state: .marked, forFace: 2)
        let sut = Solver(grid: controller.grid)
        
        XCTAssertFalse(sut.isSolved)
    }
}
