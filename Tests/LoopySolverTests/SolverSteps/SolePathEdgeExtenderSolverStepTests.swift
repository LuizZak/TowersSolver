import XCTest

@testable import LoopySolver

class SolePathEdgeExtenderSolverStepTests: XCTestCase {
    var sut: SolePathEdgeExtenderSolverStep!
    var delegate: SolverStepDelegate!

    override func setUp() {
        super.setUp()

        sut = SolePathEdgeExtenderSolverStep()
        delegate = TestSolverStepDelegate()
    }

    func testIsEphemeral() {
        XCTAssertFalse(sut.isEphemeral)
    }

    func testApplyOnTrivial() {
        // Create a grid with a loopy line that ends in a corner:
        //
        // .  .  .
        // !  x  .  (assuming 'x' is the mid vertical column disabled)
        // .  .  .
        //
        // Result should be a line that extends around the corner such that it
        // ends in a vertex with more than one choise of path:
        //
        // .__.__.
        // !  x  !
        // .  .  .
        //
        let gridGen = LoopySquareGridGen(width: 2, height: 2)
        let controller = LoopyGridController(grid: gridGen.generate())
        controller.setEdge(state: .disabled, forFace: 0, edgeIndex: 1)
        controller.setEdge(state: .marked, forFace: 0, edgeIndex: 3)

        let result = sut.apply(to: controller.grid, delegate)

        let edgeStatesForFace: (Int) -> [Edge.State] = {
            result.edges(forFace: $0).map(result.edgeState(forEdge:))
        }
        // Top-left
        XCTAssertEqual(edgeStatesForFace(0)[0], .marked)
        XCTAssertEqual(edgeStatesForFace(0)[1], .disabled)
        XCTAssertEqual(edgeStatesForFace(0)[2], .normal)
        XCTAssertEqual(edgeStatesForFace(0)[3], .marked)
        // Top-right
        XCTAssertEqual(edgeStatesForFace(1)[0], .marked)
        XCTAssertEqual(edgeStatesForFace(1)[1], .marked)
        XCTAssertEqual(edgeStatesForFace(1)[2], .normal)
        XCTAssertEqual(edgeStatesForFace(1)[3], .disabled)
        // Bottom-left
        XCTAssertEqual(edgeStatesForFace(2)[0], .normal)
        XCTAssertEqual(edgeStatesForFace(2)[1], .normal)
        XCTAssertEqual(edgeStatesForFace(2)[2], .normal)
        XCTAssertEqual(edgeStatesForFace(2)[3], .normal)
        // Bottom-right
        XCTAssertEqual(edgeStatesForFace(3)[0], .normal)
        XCTAssertEqual(edgeStatesForFace(3)[1], .normal)
        XCTAssertEqual(edgeStatesForFace(3)[2], .normal)
        XCTAssertEqual(edgeStatesForFace(3)[3], .normal)
    }

    func testApplyEdgeCase() {
        // Create a grid with a loopy line that ends in a corner:
        //
        // •═══•   •   •
        // ║   ║
        // •   •═══•   •
        // ║       ║
        // •───•   •═══•
        // │   ║       ║
        // •   •═══•═══•
        //
        // Result should be a grid with the following configuration:
        //
        // •═══•   •   •
        // ║   ║
        // •   •═══•   •
        // ║       ║
        // •═══•   •═══•
        // │   ║       ║
        // •   •═══•═══•
        //
        let gridGen = LoopySquareGridGen(width: 3, height: 3)
        let controller = LoopyGridController(grid: gridGen.generate())
        // Disabled edges
        controller.setEdge(state: .disabled, forFace: 0, edgeIndex: 2)
        controller.setEdges(state: .disabled, forFace: 1, edgeIndices: [0, 1])
        controller.setEdges(state: .disabled, forFace: 2, edgeIndices: [0, 1, 2])
        controller.setEdges(state: .disabled, forFace: 3, edgeIndices: [1])
        controller.setEdges(state: .disabled, forFace: 4, edgeIndices: [2])
        controller.setEdges(state: .disabled, forFace: 5, edgeIndices: [1])
        controller.setEdges(state: .disabled, forFace: 6, edgeIndices: [2])
        controller.setEdges(state: .disabled, forFace: 7, edgeIndices: [1])
        // Marked edges
        controller.setEdges(state: .marked, forFace: 0, edgeIndices: [0, 1, 3])
        controller.setEdges(state: .marked, forFace: 1, edgeIndices: [2])
        controller.setEdges(state: .marked, forFace: 3, edgeIndices: [3])
        controller.setEdges(state: .marked, forFace: 4, edgeIndices: [1])
        controller.setEdges(state: .marked, forFace: 5, edgeIndices: [2])
        controller.setEdges(state: .marked, forFace: 6, edgeIndices: [1])
        controller.setEdges(state: .marked, forFace: 7, edgeIndices: [2])
        controller.setEdges(state: .marked, forFace: 8, edgeIndices: [1, 2])

        let result = sut.apply(to: controller.grid, delegate)

        let edgeStatesForFace: (Int) -> [Edge.State] = {
            result.edges(forFace: $0).map(result.edgeState(forEdge:))
        }
        // 1, 1
        XCTAssertEqual(edgeStatesForFace(0), [.marked, .marked, .disabled, .marked])
        // 2, 1
        XCTAssertEqual(edgeStatesForFace(1), [.disabled, .disabled, .marked, .marked])
        // 3, 1
        XCTAssertEqual(edgeStatesForFace(2), [.disabled, .disabled, .disabled, .disabled])
        // 1, 2
        XCTAssertEqual(edgeStatesForFace(3), [.disabled, .disabled, .marked, .marked])
        // 2, 2
        XCTAssertEqual(edgeStatesForFace(4), [.marked, .marked, .disabled, .disabled])
        // 3, 2
        XCTAssertEqual(edgeStatesForFace(5), [.disabled, .disabled, .marked, .marked])
        // 1, 3
        XCTAssertEqual(edgeStatesForFace(6), [.marked, .marked, .disabled, .normal])
        // 2, 3
        XCTAssertEqual(edgeStatesForFace(7), [.disabled, .disabled, .marked, .marked])
        // 3, 3
        XCTAssertEqual(edgeStatesForFace(8), [.marked, .marked, .marked, .disabled])
    }

    func testApplyEdgeCase2() {
        // Create a grid with a loopy line that ends in a corner:
        //
        // •───•───•───•
        // |   |   │   │
        // •   •   •───•
        // ║   ║   ║   ║
        // •   •═══•   •
        // ║           ║
        // •═══•═══•═══•
        //
        // Result should be a grid with the following configuration:
        //
        // •═══•───•───•
        // ║   ║   │   │
        // •   •   •───•
        // ║   ║   ║   ║
        // •   •═══•   •
        // ║           ║
        // •═══•═══•═══•
        //
        let gridGen = LoopySquareGridGen(width: 3, height: 3)
        let controller = LoopyGridController(grid: gridGen.generate())
        // Disabled edges
        controller.setEdge(state: .disabled, forFace: 0, edgeIndex: 2)
        controller.setEdges(state: .disabled, forFace: 1, edgeIndices: [2])
        controller.setEdges(state: .disabled, forFace: 3, edgeIndices: [2])
        controller.setEdges(state: .disabled, forFace: 5, edgeIndices: [2])
        controller.setEdges(state: .disabled, forFace: 6, edgeIndices: [1])
        controller.setEdges(state: .disabled, forFace: 7, edgeIndices: [1])
        // Marked edges
        controller.setEdges(state: .marked, forFace: 3, edgeIndices: [1, 3])
        controller.setEdges(state: .marked, forFace: 4, edgeIndices: [1, 2])
        controller.setEdges(state: .marked, forFace: 5, edgeIndices: [1])
        controller.setEdges(state: .marked, forFace: 6, edgeIndices: [2, 3])
        controller.setEdges(state: .marked, forFace: 7, edgeIndices: [2])
        controller.setEdges(state: .marked, forFace: 8, edgeIndices: [1, 2])

        let result = sut.apply(to: controller.grid, delegate)

        let edgeStatesForFace: (Int) -> [Edge.State] = {
            result.edges(forFace: $0).map(result.edgeState(forEdge:))
        }
        // 1, 1
        XCTAssertEqual(edgeStatesForFace(0), [.marked, .marked, .disabled, .marked])
        // 2, 1
        XCTAssertEqual(edgeStatesForFace(1), [.normal, .normal, .disabled, .marked])
        // 3, 1
        XCTAssertEqual(edgeStatesForFace(2), [.normal, .normal, .normal, .normal])
        // 1, 2
        XCTAssertEqual(edgeStatesForFace(3), [.disabled, .marked, .disabled, .marked])
        // 2, 2
        XCTAssertEqual(edgeStatesForFace(4), [.disabled, .marked, .marked, .marked])
        // 3, 2
        XCTAssertEqual(edgeStatesForFace(5), [.normal, .marked, .disabled, .marked])
        // 1, 3
        XCTAssertEqual(edgeStatesForFace(6), [.disabled, .disabled, .marked, .marked])
        // 2, 3
        XCTAssertEqual(edgeStatesForFace(7), [.marked, .disabled, .marked, .disabled])
        // 3, 3
        XCTAssertEqual(edgeStatesForFace(8), [.disabled, .marked, .marked, .disabled])
    }
}
