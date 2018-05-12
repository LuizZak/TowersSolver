import XCTest
@testable import LoopySolver

class CommonEdgesBetweenGuessesSolverStepTests: XCTestCase {
    var sut: CommonEdgesBetweenGuessesSolverStep!
    var delegate: SolverStepDelegate!
    
    override func setUp() {
        super.setUp()
        
        sut = CommonEdgesBetweenGuessesSolverStep()
        delegate = TestSolverStepDelegate()
    }
    
    func testApply() {
        // Create a grid as follows:
        // .___.___.___.___.
        // !___!___!___!___!
        // !___!___!___!___!
        // . 1 !_1_.___!___!
        // .___║___!___!___!
        // !___!___!___!___!
        //
        // Expect a grid result as follows:
        // .___.___.___.___.
        // !___!___!___!___!
        // !___║   !___!___!
        // . 1 !_1_.___!___!
        // .___║___!___!___!
        // !___!___!___!___!
        //
        let gridGen = LoopySquareGridGen(width: 4, height: 5)
        gridGen.setHint(x: 0, y: 2, hint: 1)
        gridGen.setHint(x: 1, y: 2, hint: 1)
        let controller = LoopyGridController(grid: gridGen.generate())
        controller.setEdges(state: .disabled, forFace: 8, edgeIndices: [2, 3])
        controller.setEdge(state: .disabled, forFace: 9, edgeIndex: 1)
        controller.setEdge(state: .disabled, forFace: 10, edgeIndex: 3)
        controller.setEdge(state: .marked, forFace: 12, edgeIndex: 1)
        
        let result = sut.apply(to: controller.grid, delegate)
        
        let edgeStatesForFace: (Int) -> [Edge.State] = {
            result.edges(forFace: $0).map(result.edgeState(forEdge:))
        }
        // Row 1
        XCTAssertEqual(edgeStatesForFace(0), [.normal, .normal, .normal, .normal])
        XCTAssertEqual(edgeStatesForFace(1), [.normal, .normal, .normal, .normal])
        XCTAssertEqual(edgeStatesForFace(2), [.normal, .normal, .normal, .normal])
        XCTAssertEqual(edgeStatesForFace(3), [.normal, .normal, .normal, .normal])
        // Row 2
        XCTAssertEqual(edgeStatesForFace(4), [.normal, .marked, .normal, .normal])
        XCTAssertEqual(edgeStatesForFace(5), [.normal, .normal, .disabled, .marked])
        XCTAssertEqual(edgeStatesForFace(6), [.normal, .normal, .normal, .normal])
        XCTAssertEqual(edgeStatesForFace(7), [.normal, .normal, .normal, .normal])
        // Row 3
        XCTAssertEqual(edgeStatesForFace(8), [.normal, .normal, .disabled, .disabled])
        XCTAssertEqual(edgeStatesForFace(9), [.disabled, .disabled, .normal, .normal])
        XCTAssertEqual(edgeStatesForFace(10), [.normal, .normal, .normal, .disabled])
        XCTAssertEqual(edgeStatesForFace(11), [.normal, .normal, .normal, .normal])
        // Row 4
        XCTAssertEqual(edgeStatesForFace(12), [.disabled, .marked, .normal, .disabled])
        XCTAssertEqual(edgeStatesForFace(13), [.normal, .normal, .normal, .marked])
        XCTAssertEqual(edgeStatesForFace(14), [.normal, .normal, .normal, .normal])
        XCTAssertEqual(edgeStatesForFace(15), [.normal, .normal, .normal, .normal])
        let printer = LoopyGridPrinter(bufferWidth: 18, bufferHeight: 11)
        printer.printGrid(grid: result)
    }
}
