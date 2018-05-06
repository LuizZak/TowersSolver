import XCTest
@testable import LoopySolver

class InvalidLoopClosingDetectionSolverStepTests: XCTestCase {
    var sut: InvalidLoopClosingDetectionSolverStep!
    var delegate: SolverStepDelegate!
    
    override func setUp() {
        super.setUp()
        
        sut = InvalidLoopClosingDetectionSolverStep()
        delegate = TestSolverStepDelegate()
    }
    
    func testIncompleteLoop() {
        // Test a case where closing a loop would form an invalid loop, so we
        // disable the edge that would close such loop:
        //
        // •═══•───•═══•═══•
        // ║ 2 │   X     3 ║
        // •───•───•═══•═══•
        //
        // Closing the loop by marking the `X` edge would form an invalid board,
        // so the solver must be able to disable that edge.
        let gridGen = LoopySquareGridGen(width: 4, height: 1)
        gridGen.setHint(x: 0, y: 0, hint: 2)
        gridGen.setHint(x: 3, y: 0, hint: 3)
        let controller = LoopyGridController(grid: gridGen.generate())
        controller.setEdges(state: .marked, forFace: 0, edgeIndices: [0, 3])
        controller.setEdges(state: .marked, forFace: 2, edgeIndices: [0, 2])
        controller.setEdges(state: .marked, forFace: 3, edgeIndices: [0, 1, 2])
        controller.setEdge(state: .disabled, forFace: 2, edgeIndex: 1)
        
        let result = sut.apply(to: controller.grid, delegate)
        
        let edgesForFace: (Int) -> [Edge.Id] = {
            result.edges(forFace: $0)
        }
        let edgeStatesForFace: (Int) -> [Edge.State] = {
            edgesForFace($0).map(result.edgeState(forEdge:))
        }
        // Left `2`
        XCTAssertEqual(edgeStatesForFace(0), [.marked, .normal, .normal, .marked])
        // Center left
        XCTAssertEqual(edgeStatesForFace(1), [.normal, .disabled, .normal, .normal])
        // Center right
        XCTAssertEqual(edgeStatesForFace(2), [.marked, .disabled, .marked, .disabled])
        // Right `3`
        XCTAssertEqual(edgeStatesForFace(3), [.marked, .marked, .marked, .disabled])
    }
    
    func testSolverDoesntMarkPotentialEdgeAsDisabled() {
        // Test a counter-case where the solver should not disable an edge since
        // closing it doesn't produce dangling line segments on the rest of the
        // solution board.
        //
        // •───•═══•═══•
        // │   │     3 ║
        // •───•═══•═══•
        let gridGen = LoopySquareGridGen(width: 3, height: 1)
        gridGen.setHint(x: 2, y: 0, hint: 3)
        let controller = LoopyGridController(grid: gridGen.generate())
        controller.setEdges(state: .marked, forFace: 1, edgeIndices: [0, 2])
        controller.setEdges(state: .marked, forFace: 2, edgeIndices: [0, 1, 2])
        controller.setEdge(state: .disabled, forFace: 2, edgeIndex: 3)
        
        let result = sut.apply(to: controller.grid, delegate)
        
        let edgesForFace: (Int) -> [Edge.Id] = {
            result.edges(forFace: $0)
        }
        let edgeStatesForFace: (Int) -> [Edge.State] = {
            edgesForFace($0).map(result.edgeState(forEdge:))
        }
        // Left
        XCTAssertEqual(edgeStatesForFace(0), [.normal, .normal, .normal, .normal])
        // Center
        XCTAssertEqual(edgeStatesForFace(1), [.marked, .disabled, .marked, .normal])
        // Right `3`
        XCTAssertEqual(edgeStatesForFace(2), [.marked, .marked, .marked, .disabled])
    }
}
