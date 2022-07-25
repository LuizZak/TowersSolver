import XCTest

@testable import LoopySolver

class DeadEndRemovalSolverStepTests: XCTestCase {
    var sut: DeadEndRemovalSolverStep!
    var delegate: SolverStepDelegate!

    override func setUp() {
        super.setUp()

        sut = DeadEndRemovalSolverStep()
        delegate = TestSolverStepDelegate()
    }

    func testIsEphemeral() {
        XCTAssertFalse(sut.isEphemeral)
    }

    func testApplyOnTrivial() {
        // Create a simple 2x2 square grid like so:
        //  .  .__.
        //  !__!__!
        //
        // Result should be a grid with the left and bottom-left edges disabled:
        //  .  .__.
        //  .  !__!
        //
        let gridGen = LoopySquareGridGen(width: 2, height: 1)
        var grid = gridGen.generate()
        grid.withEdge(0) { $0.state = .disabled }

        let result = sut.apply(to: grid, delegate)

        let edgeStatesForFace: (Int) -> [Edge.State] = {
            result.edges(forFace: $0).map(result.edgeState(forEdge:))
        }
        // left square
        XCTAssertEqual(edgeStatesForFace(0)[0], .disabled)
        XCTAssertEqual(edgeStatesForFace(0)[1], .normal)
        XCTAssertEqual(edgeStatesForFace(0)[2], .disabled)
        XCTAssertEqual(edgeStatesForFace(0)[3], .disabled)
        // right square
        XCTAssertEqual(edgeStatesForFace(1)[0], .normal)
        XCTAssertEqual(edgeStatesForFace(1)[1], .normal)
        XCTAssertEqual(edgeStatesForFace(1)[2], .normal)
        XCTAssertEqual(edgeStatesForFace(1)[3], .normal)
    }
}
