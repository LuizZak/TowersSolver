import XCTest
@testable import LoopySolver

class CornerSolverStepTests: XCTestCase {
    var sut: CornerSolverStep!
    var delegate: SolverStepDelegate!
    
    override func setUp() {
        super.setUp()
        
        sut = CornerSolverStep()
        delegate = TestSolverStepDelegate()
    }
    
    func testApplyOnTrivial() {
        // Create a simple 3x3 square grid like so:
        //  .___.___.___.
        //  !_3_!___!_0_!
        //  !___!___!___!
        //  !_1_!___!_2_!
        //
        // The expected result should have the two outer edges of the `3` cell
        // marked as part of the solution, and the outer corners of `0` and `1`
        // marked as not part of the solution.
        let gridGen = LoopySquareGridGen(width: 3, height: 3)
        gridGen.setHint(x: 0, y: 0, hint: 3)
        gridGen.setHint(x: 2, y: 0, hint: 0)
        gridGen.setHint(x: 0, y: 2, hint: 1)
        gridGen.setHint(x: 2, y: 2, hint: 2)
        let grid = gridGen.generate()
        
        let result = sut.apply(to: grid, delegate)
        
        let edgeStatesForFace: (Int) -> [Edge.State] = {
            result.edges(forFace: $0).map(result.edgeState(forEdge:))
        }
        // Check outer two edges of `3` cell where marked, while the inner edges
        // where not
        XCTAssertEqual(edgeStatesForFace(0)[0], .marked)
        XCTAssertEqual(edgeStatesForFace(0)[1], .normal)
        XCTAssertEqual(edgeStatesForFace(0)[2], .normal)
        XCTAssertEqual(edgeStatesForFace(0)[3], .marked)
        // `0`
        XCTAssertEqual(edgeStatesForFace(2)[0], .disabled)
        XCTAssertEqual(edgeStatesForFace(2)[1], .disabled)
        XCTAssertEqual(edgeStatesForFace(2)[2], .disabled)
        XCTAssertEqual(edgeStatesForFace(2)[3], .disabled)
        // `1`
        XCTAssertEqual(edgeStatesForFace(6)[0], .normal)
        XCTAssertEqual(edgeStatesForFace(6)[1], .normal)
        XCTAssertEqual(edgeStatesForFace(6)[2], .disabled)
        XCTAssertEqual(edgeStatesForFace(6)[3], .disabled)
        // `2`
        XCTAssertEqual(edgeStatesForFace(8)[0], .normal)
        XCTAssertEqual(edgeStatesForFace(8)[1], .normal)
        XCTAssertEqual(edgeStatesForFace(8)[2], .normal)
        XCTAssertEqual(edgeStatesForFace(8)[3], .normal)
    }
    
    func testApplyOnTwoInCorner() {
        // Create a simple 2x2 square grid like so:
        //  .___.___.
        //  !_2_!___!
        //  !___!___!
        //
        // The expected result should have the top-left face `2` has forced the
        // marking of the top-right vertical and bottom-left horizontal edges.
        let gridGen = LoopySquareGridGen(width: 2, height: 2)
        gridGen.setHint(x: 0, y: 0, hint: 2)
        let grid = gridGen.generate()
        
        let result = sut.apply(to: grid, delegate)
        
        let edgeStatesForFace: (Int) -> [Edge.State] = {
            result.edges(forFace: $0).map(result.edgeState(forEdge:))
        }
        // `2`
        XCTAssertEqual(edgeStatesForFace(0)[0], .normal)
        XCTAssertEqual(edgeStatesForFace(0)[1], .normal)
        XCTAssertEqual(edgeStatesForFace(0)[2], .normal)
        XCTAssertEqual(edgeStatesForFace(0)[3], .normal)
        // top-right
        XCTAssertEqual(edgeStatesForFace(1)[0], .marked)
        XCTAssertEqual(edgeStatesForFace(1)[1], .normal)
        XCTAssertEqual(edgeStatesForFace(1)[2], .normal)
        XCTAssertEqual(edgeStatesForFace(1)[3], .normal)
        // bottom-left
        XCTAssertEqual(edgeStatesForFace(2)[0], .normal)
        XCTAssertEqual(edgeStatesForFace(2)[1], .normal)
        XCTAssertEqual(edgeStatesForFace(2)[2], .normal)
        XCTAssertEqual(edgeStatesForFace(2)[3], .marked)
        // bottom-right
        XCTAssertEqual(edgeStatesForFace(3)[0], .normal)
        XCTAssertEqual(edgeStatesForFace(3)[1], .normal)
        XCTAssertEqual(edgeStatesForFace(3)[2], .normal)
        XCTAssertEqual(edgeStatesForFace(3)[3], .normal)
    }
    
    func testApplyOnTwoInCornerWithThreeOnDiagonal() {
        // Create a simple 2x2 square grid like so:
        //  .___.___.
        //  !_2_!___!
        //  !___!_3_!
        //
        // The expected result should have the top-left `2` face has the outer
        // edges marked as part of the solution, since an attempted traversal through
        // the inner faces would be abruptly stopped by the diagnotal `3`, which
        // would require capturing the line (since continuing on around the `2`
        // cell through the center would result in the `3` losing two edges (the
        // bottom-center vertical and right-center horizontal), and it would no
        // longer have enough edges to be completed.
        let gridGen = LoopySquareGridGen(width: 2, height: 2)
        gridGen.setHint(x: 0, y: 0, hint: 2)
        gridGen.setHint(x: 1, y: 1, hint: 3)
        let grid = gridGen.generate()
        
        let result = sut.apply(to: grid, delegate)
        
        let edgeStatesForFace: (Int) -> [Edge.State] = {
            result.edges(forFace: $0).map(result.edgeState(forEdge:))
        }
        // `2`
        XCTAssertEqual(edgeStatesForFace(0)[0], .marked)
        XCTAssertEqual(edgeStatesForFace(0)[1], .disabled)
        XCTAssertEqual(edgeStatesForFace(0)[2], .disabled)
        XCTAssertEqual(edgeStatesForFace(0)[3], .marked)
        // top-right
        XCTAssertEqual(edgeStatesForFace(1)[0], .marked)
        XCTAssertEqual(edgeStatesForFace(1)[1], .normal)
        XCTAssertEqual(edgeStatesForFace(1)[2], .normal)
        XCTAssertEqual(edgeStatesForFace(1)[3], .disabled)
        // bottom-left
        XCTAssertEqual(edgeStatesForFace(2)[0], .disabled)
        XCTAssertEqual(edgeStatesForFace(2)[1], .normal)
        XCTAssertEqual(edgeStatesForFace(2)[2], .normal)
        XCTAssertEqual(edgeStatesForFace(2)[3], .marked)
        // `3`
        XCTAssertEqual(edgeStatesForFace(3)[0], .normal)
        XCTAssertEqual(edgeStatesForFace(3)[1], .normal)
        XCTAssertEqual(edgeStatesForFace(3)[2], .normal)
        XCTAssertEqual(edgeStatesForFace(3)[3], .normal)
    }
    
    func testApplyOnTwoInCenterWithThreeOnDiagonal() {
        // Create a 3x3 square grid like so:
        //  .___.___.___.
        //  !   .___!___!
        //  !___!_2_!___!
        //  !___!___!_3_!
        //
        // The expected result should have the center `2` face has the outer
        // edges marked as part of the solution, since an attempted traversal through
        // the inner faces would be abruptly stopped by the diagnotal `3`, which
        // would require capturing the line (since continuing on around the `2`
        // cell through the center would result in the `3` losing two edges (the
        // bottom-center vertical and right-center horizontal), and it would no
        // longer have enough edges to be completed.
        let gridGen = LoopySquareGridGen(width: 3, height: 3)
        gridGen.setHint(x: 1, y: 1, hint: 2)
        gridGen.setHint(x: 2, y: 2, hint: 3)
        let controller = LoopyGridController(grid: gridGen.generate())
        controller.setEdges(state: .disabled, forFace: 0, edgeIndices: [1, 2])
        
        let result = sut.apply(to: controller.grid, delegate)
        
        let edgeStatesForFace: (Int) -> [Edge.State] = {
            result.edges(forFace: $0).map(result.edgeState(forEdge:))
        }
        XCTAssertEqual(edgeStatesForFace(0), [.normal, .disabled, .disabled, .normal])
        XCTAssertEqual(edgeStatesForFace(1), [.normal, .normal, .marked, .disabled])
        XCTAssertEqual(edgeStatesForFace(2), [.normal, .normal, .normal, .normal])
        XCTAssertEqual(edgeStatesForFace(3), [.disabled, .marked, .normal, .normal])
        // `2`
        XCTAssertEqual(edgeStatesForFace(4), [.marked, .disabled, .disabled, .marked])
        XCTAssertEqual(edgeStatesForFace(5), [.normal, .normal, .normal, .disabled])
        XCTAssertEqual(edgeStatesForFace(6), [.normal, .normal, .normal, .normal])
        XCTAssertEqual(edgeStatesForFace(7), [.disabled, .normal, .normal, .normal])
        // `3`
        XCTAssertEqual(edgeStatesForFace(8), [.normal, .normal, .normal, .normal])
    }
    
    func testApplyOnTwoInCornerWithThreeOnSideDoesNotTrigger() {
        // Create a simple 2x2 square grid like so:
        //  .___.___.
        //  !_2_!_3_!
        //  !___!___!
        //
        // No deductions should be made about which of the edges of the `2` face
        // are part of the solution.
        let gridGen = LoopySquareGridGen(width: 2, height: 2)
        gridGen.setHint(x: 0, y: 0, hint: 2)
        gridGen.setHint(x: 1, y: 0, hint: 3)
        let grid = gridGen.generate()
        
        let result = sut.apply(to: grid, delegate)
        
        let edgeStatesForFace: (Int) -> [Edge.State] = {
            result.edges(forFace: $0).map(result.edgeState(forEdge:))
        }
        // `2`
        XCTAssertEqual(edgeStatesForFace(0)[0], .normal)
        XCTAssertEqual(edgeStatesForFace(0)[1], .normal)
        XCTAssertEqual(edgeStatesForFace(0)[2], .normal)
        XCTAssertEqual(edgeStatesForFace(0)[3], .normal)
        // `3`
        XCTAssertEqual(edgeStatesForFace(1)[0], .marked)
        XCTAssertEqual(edgeStatesForFace(1)[1], .marked)
        XCTAssertEqual(edgeStatesForFace(1)[2], .normal)
        XCTAssertEqual(edgeStatesForFace(1)[3], .normal)
        // bottom-left
        XCTAssertEqual(edgeStatesForFace(2)[0], .normal)
        XCTAssertEqual(edgeStatesForFace(2)[1], .normal)
        XCTAssertEqual(edgeStatesForFace(2)[2], .normal)
        XCTAssertEqual(edgeStatesForFace(2)[3], .marked)
        // bottom-right
        XCTAssertEqual(edgeStatesForFace(3)[0], .normal)
        XCTAssertEqual(edgeStatesForFace(3)[1], .normal)
        XCTAssertEqual(edgeStatesForFace(3)[2], .normal)
        XCTAssertEqual(edgeStatesForFace(3)[3], .normal)
    }
    
    func testApplyOnDisabledInnerEdges() {
        // Create a simple 3x3 grid like so:
        //  .___.___.___.
        //  !___!___x   !
        //  !_x_!_2_!   !
        //  !___.___.___!
        //
        // The two edges marked with an 'x' must be marked since they are a
        // mandatory path portion of the `2`-hinted cell.
        let gridGen = LoopySquareGridGen(width: 3, height: 3)
        gridGen.setHint(x: 1, y: 1, hint: 2)
        let controller = LoopyGridController(grid: gridGen.generate())
        controller.setEdge(state: .disabled, forFace: 2, edgeIndex: 2)
        controller.setEdge(state: .disabled, forFace: 5, edgeIndex: 2)
        controller.setEdge(state: .disabled, forFace: 6, edgeIndex: 1)
        controller.setEdge(state: .disabled, forFace: 7, edgeIndex: 1)
        
        let result = sut.apply(to: controller.grid, delegate)
        
        let edgeStatesForFace: (Int) -> [Edge.State] = {
            result.edges(forFace: $0).map(result.edgeState(forEdge:))
        }
        XCTAssertEqual(edgeStatesForFace(1)[1], .marked)
        XCTAssertEqual(edgeStatesForFace(3)[2], .marked)
    }
    
    func testBugDisablingUnexpectedEdgesAroundFace() {
        // Tests against a bug found when a certain configuration would result
        // in the solver step disabling edges unexpectedly:
        //
        //  This '2' face has
        //  its left and bottom
        //  edges erroneously
        //  disabled
        //        |
        //        v
        //  .___.   .   .
        //  !___!_2_. 0 .
        //  !___!___!___.
        //  !___!_2_!_3_!
        //
        let gridGen = LoopySquareGridGen(width: 3, height: 3)
        gridGen.setHint(x: 1, y: 0, hint: 2)
        gridGen.setHint(x: 2, y: 0, hint: 0)
        gridGen.setHint(x: 1, y: 2, hint: 2)
        gridGen.setHint(x: 2, y: 2, hint: 3)
        let controller = LoopyGridController(grid: gridGen.generate())
        controller.setEdge(state: .disabled, forFace: 1, edgeIndex: 0)
        controller.setEdges(state: .disabled, forFace: 2)
        controller.setEdge(state: .disabled, forFace: 5, edgeIndex: 1)
        
        let result = sut.apply(to: controller.grid, delegate)
        
        let edgeStatesForFace: (Int) -> [Edge.State] = {
            result.edges(forFace: $0).map(result.edgeState(forEdge:))
        }
        XCTAssertEqual(edgeStatesForFace(1)[2], .normal)
        XCTAssertEqual(edgeStatesForFace(1)[3], .normal)
    }
    
    func testBugDisablingUnexpectedEdgesIndirectlyConnectedToFace() {
        // Tests against a bug found when a certain configuration would result
        // in the solver step disabling edges that are part of the set of edges
        // to disable, but not directly touching the edge's face:
        //  .___.___.___.
        //  !___!___.   !
        //  !___! 1 !   ! <- This whole section is erroneously disabled.
        //  !___!___!___!
        //
        let gridGen = LoopySquareGridGen(width: 3, height: 3)
        gridGen.setHint(x: 1, y: 1, hint: 1)
        let controller = LoopyGridController(grid: gridGen.generate())
        controller.setEdges(state: .disabled, forFace: 2, edgeIndices: [2, 3])
        controller.setEdge(state: .disabled, forFace: 4, edgeIndex: 2)
        controller.setEdge(state: .disabled, forFace: 5, edgeIndex: 2)
        
        let result = sut.apply(to: controller.grid, delegate)
        
        let edgeStatesForFace: (Int) -> [Edge.State] = {
            result.edges(forFace: $0).map(result.edgeState(forEdge:))
        }
        XCTAssertEqual(edgeStatesForFace(0), [.normal, .normal, .normal, .normal])
        XCTAssertEqual(edgeStatesForFace(1), [.normal, .disabled, .disabled, .normal])
        XCTAssertEqual(edgeStatesForFace(2), [.normal, .normal, .disabled, .disabled])
        XCTAssertEqual(edgeStatesForFace(3), [.normal, .normal, .normal, .normal])
        // `1`
        XCTAssertEqual(edgeStatesForFace(4), [.disabled, .disabled, .disabled, .normal])
        XCTAssertEqual(edgeStatesForFace(5), [.disabled, .normal, .disabled, .disabled])
        XCTAssertEqual(edgeStatesForFace(6), [.normal, .normal, .normal, .normal])
        XCTAssertEqual(edgeStatesForFace(7), [.disabled, .normal, .normal, .normal])
        XCTAssertEqual(edgeStatesForFace(8), [.disabled, .normal, .normal, .normal])
    }
}
