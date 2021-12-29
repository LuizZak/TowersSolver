import XCTest
@testable import LoopySolver

class BifurcationSolverStepTests: XCTestCase {
    var sut: BifurcationSolverStep!
    var delegate: SolverStepDelegate!
    
    override func setUp() {
        super.setUp()
        
        sut = BifurcationSolverStep()
        delegate = TestSolverStepDelegate()
    }
    
    func testIsEphemeral() {
        XCTAssertFalse(sut.isEphemeral)
    }
    
    func testApply() {
        // Create a honeycomb grid like so:
        //
        //     •───•       •───•
        //    /     \\          \
        //   •       •═══•       •
        //    \           \\    /
        //     •───•   4   •   •
        //    /     \     //    \
        //   •       •───•       •
        //    \    */     \     /
        //     •───•       •───•
        //          \     /
        //           •───•
        //
        // Expected result is to have the edge marked (*) be marked
        let gen = LoopyHoneycombGridGenerator(width: 3, height: 2)
        gen.setHint(faceIndex: 1, hint: 4)
        let controller = LoopyGridController(grid: gen.generate())
        controller.setEdge(state: .marked, forEdge: 1)
        controller.setEdge(state: .disabled, forEdge: 2)
        controller.setEdge(state: .marked, forEdge: 6)
        controller.setEdge(state: .disabled, forEdge: 15)
        controller.setEdge(state: .marked, forEdge: 7)
        controller.setEdge(state: .marked, forEdge: 8)
        controller.setEdge(state: .disabled, forEdge: 14)
        let input = controller.grid
        controller.setEdge(state: .marked, forEdge: 16)
        let expected = controller.grid
        
        let result = sut.apply(to: input, delegate)
        
        XCTAssertEqual(result, expected)
        
        let printer = LoopyGridPrinter(bufferWidth: 22, bufferHeight: 11)
        printer.printGrid(grid: result)
    }
}
