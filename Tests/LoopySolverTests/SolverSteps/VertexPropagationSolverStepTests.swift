import XCTest

@testable import LoopySolver

class VertexPropagationSolverStepTests: XCTestCase {
    var sut: VertexPropagationSolverStep!
    var delegate: SolverStepDelegate!

    override func setUp() {
        super.setUp()

        sut = VertexPropagationSolverStep()
        delegate = TestSolverStepDelegate()
    }

    func testIsEphemeral() {
        XCTAssertFalse(sut.isEphemeral)
    }

    func testApplyToGrid_squareTwoHints() {
        // Create a 3x3 square grid like so:
        //
        //     •───•───•
        //   1 |   |   |
        // •───•───•───•
        // |   | 2 |   |
        // •───•───•───•
        // |   |       |
        // •───•───•───•
        //
        // The solver should be able to detect that propagating the guaranteed
        // exit vertex on the '1' hint should result in a cascading effect on the
        // '2' hint, resulting in the bottom-right edge to be marked:
        //
        //     •───•───•
        //   1 |   |   |
        // •───•───•───•
        // |   | 2 |   |
        // •───•───•===•
        // |   |       |
        // •───•───•───•
        //
        let gridGen = LoopySquareGridGen(width: 3, height: 3)
        gridGen.setHint(x: 0, y: 0, hint: 1)
        gridGen.setHint(x: 1, y: 1, hint: 2)
        let controller = LoopyGridController(grid: gridGen.generate())
        controller.setEdges(state: .disabled, forFace: 0, edgeIndices: [0, 3])
        controller.setEdges(state: .disabled, forFace: 8, edgeIndices: [3])

        let result = sut.apply(to: controller.grid, delegate)

        let edgesForFace: (FaceReferenceConvertible) -> [Edge.Id] = {
            result.edges(forFace: $0)
        }
        let edgeStatesForFace: (FaceReferenceConvertible) -> [Edge.State] = {
            edgesForFace($0).map(result.edgeState(forEdge:))
        }
        XCTAssertEqual(edgeStatesForFace(gridGen.faceId(atX: 2, y: 2)), [.marked, .normal, .normal, .disabled])
        let printer = LoopyGridPrinter(squareGridColumns: 3, rows: 3)
        printer.printGrid(grid: result)
    }

    func testApplyToGrid_squareOneHints() {
        // Create a 3x3 square grid like so:
        //
        //     •───•───•
        //   1 |   |   |
        // •───•───•───•
        // |   | 1 |   |
        // •───•───•───•
        // |   |   |   |
        // •───•───•───•
        //
        // The solver should be able to detect that propagating the guaranteed
        // exit vertex on the '1' hint should result in a cascading effect on the
        // '1' hint bellow:
        //
        //     •───•───•
        //   1 |   |   |
        // •───•───•───•
        // |   | 1     |
        // •───•   •───•
        // |   |   |   |
        // •───•───•───•
        //
        let gridGen = LoopySquareGridGen(width: 3, height: 3)
        gridGen.setHint(x: 0, y: 0, hint: 1)
        gridGen.setHint(x: 1, y: 1, hint: 1)
        let controller = LoopyGridController(grid: gridGen.generate())
        controller.setEdges(state: .disabled, forFace: 0, edgeIndices: [0, 3])

        let result = sut.apply(to: controller.grid, delegate)

        let edgesForFace: (FaceReferenceConvertible) -> [Edge.Id] = {
            result.edges(forFace: $0)
        }
        let edgeStatesForFace: (FaceReferenceConvertible) -> [Edge.State] = {
            edgesForFace($0).map(result.edgeState(forEdge:))
        }
        XCTAssertEqual(edgeStatesForFace(gridGen.faceId(atX: 1, y: 1)), [.normal, .disabled, .disabled, .normal])
        let printer = LoopyGridPrinter(squareGridColumns: 3, rows: 3)
        printer.printGrid(grid: result)
    }

    // TODO: Fix this test case without breaking the solver
    func xtestApplyToGrid_squareTwoHints_onEdge() {
        // Create a 3x3 square grid like so:
        //
        //     •───•───•
        //   1 |   |   |
        // •───•───•───•
        // |   | 2 |   |
        // •───•───•───•
        //
        // The solver should be able to detect that propagating the guaranteed
        // exit vertex on the '1' hint should result in a cascading effect on the
        // '2' hint, resulting in the bottom-right edge to be marked:
        //
        //     •───•───•
        //   1 |   |   |
        // •───•───•───•
        // |   | 2 |   |
        // •───•───•===•
        //
        let gridGen = LoopySquareGridGen(width: 3, height: 2)
        gridGen.setHint(x: 0, y: 0, hint: 1)
        gridGen.setHint(x: 1, y: 1, hint: 2)
        let controller = LoopyGridController(grid: gridGen.generate())
        controller.setEdges(state: .disabled, forFace: 0, edgeIndices: [0, 3])

        let result = sut.apply(to: controller.grid, delegate)

        let edgesForFace: (FaceReferenceConvertible) -> [Edge.Id] = {
            result.edges(forFace: $0)
        }
        let edgeStatesForFace: (FaceReferenceConvertible) -> [Edge.State] = {
            edgesForFace($0).map(result.edgeState(forEdge:))
        }
        XCTAssertEqual(edgeStatesForFace(gridGen.faceId(atX: 2, y: 1)), [.normal, .normal, .marked, .normal])
        let printer = LoopyGridPrinter(squareGridColumns: 3, rows: 2)
        printer.printGrid(grid: result)
    }

    func testApplyToGrid_chainedSquareTwoHints() {
        // Create a square grid like so:
        //
        //     •───•───•───•
        //   1 |   |   |   |
        // •───•───•───•───•
        // |   | 2 |   |   |
        // •───•───•───•───•
        // |   |   | 2 |   |
        // •───•───•───•───•
        // |   |   |       |
        // •───•───•───•───•
        //
        // The solver should be able to detect that propagating the guaranteed
        // exit vertex on the '1' hint should result in a cascading effect on the
        // '2' hints, resulting in the bottom-right edge to be marked:
        //
        //     •───•───•───•
        //   1 |   |   |   |
        // •───•───•───•───•
        // |   | 2 |   |   |
        // •───•───•───•───•
        // |   |   | 2 |   |
        // •───•───•───•===•
        // |   |   |       |
        // •───•───•───•───•
        //
        let gridGen = LoopySquareGridGen(width: 4, height: 4)
        gridGen.setHint(x: 0, y: 0, hint: 1)
        gridGen.setHint(x: 1, y: 1, hint: 2)
        gridGen.setHint(x: 2, y: 2, hint: 2)
        let controller = LoopyGridController(grid: gridGen.generate())
        controller.setEdges(state: .disabled, forFace: 0, edgeIndices: [0, 3])
        controller.setEdges(state: .disabled, forFace: gridGen.faceId(atX: 3, y: 3), edgeIndices: [3])

        let result = sut.apply(to: controller.grid, delegate)

        let edgesForFace: (FaceReferenceConvertible) -> [Edge.Id] = {
            result.edges(forFace: $0)
        }
        let edgeStatesForFace: (FaceReferenceConvertible) -> [Edge.State] = {
            edgesForFace($0).map(result.edgeState(forEdge:))
        }
        XCTAssertEqual(edgeStatesForFace(gridGen.faceId(atX: 3, y: 3)), [.marked, .normal, .normal, .disabled])
        let printer = LoopyGridPrinter(squareGridColumns: 4, rows: 4)
        printer.printGrid(grid: result)
    }

    func testApplyToGrid_squareTwoHints_ignoreAmbiguousExitEdge() {
        // Create a 3x3 square grid like so:
        //
        //     •───•───•
        //   1 |   |   |
        // •───•───•───•
        // |   | 2 |   |
        // •───•───•───•
        // |   |   |   |
        // •───•───•───•
        //
        // The solver should not propagate the '2' hint because its exit vertex
        // is ambiguous as to which path it can take into the lower square:
        //
        //     •───•───•
        //   1 |   |   |
        // •───•───•───•
        // |   | 2 |   |
        // •───•───•───•
        // |   |   |   |
        // •───•───•───•
        //
        let gridGen = LoopySquareGridGen(width: 3, height: 3)
        gridGen.setHint(x: 0, y: 0, hint: 1)
        gridGen.setHint(x: 1, y: 1, hint: 2)
        let controller = LoopyGridController(grid: gridGen.generate())
        controller.setEdges(state: .disabled, forFace: 0, edgeIndices: [0, 3])

        let result = sut.apply(to: controller.grid, delegate)

        let edgesForFace: (FaceReferenceConvertible) -> [Edge.Id] = {
            result.edges(forFace: $0)
        }
        let edgeStatesForFace: (FaceReferenceConvertible) -> [Edge.State] = {
            edgesForFace($0).map(result.edgeState(forEdge:))
        }
        XCTAssertEqual(edgeStatesForFace(gridGen.faceId(atX: 2, y: 2)), [.normal, .normal, .normal, .normal])
        let printer = LoopyGridPrinter(squareGridColumns: 3, rows: 3)
        printer.printGrid(grid: result)
    }

    func testApplyToGrid_chainedSquareTwoVertexOnThreeHints() {
        // Create a square grid like so:
        //
        //     •───•───•───•
        //   1 |   |   |   |
        // •───•───•───•───•
        // |   | 2 |   |   |
        // •───•───•───•───•
        // |   |   | 3 |   |
        // •───•───•───•───•
        // |   |   |   |   |
        // •───•───•───•───•
        //
        // The solver should be able to detect that propagating the guaranteed
        // exit vertex on the '1' hint should result in a cascading effect on the
        // '2' hint, resulting in the '3' hint being updated to reflect the common
        // edges across its possible solutions:
        //
        //     •───•───•───•
        //   1 |   |   |   |
        // •───•───•───•───•
        // |   | 2 |   |   |
        // •───•───•───•───•
        // |   |   | 3 ║   |
        // •───•───•===•───•
        // |   |   |   |   |
        // •───•───•───•───•
        //
        let gridGen = LoopySquareGridGen(width: 4, height: 4)
        gridGen.setHint(x: 0, y: 0, hint: 1)
        gridGen.setHint(x: 1, y: 1, hint: 2)
        gridGen.setHint(x: 2, y: 2, hint: 3)
        let controller = LoopyGridController(grid: gridGen.generate())
        controller.setEdges(state: .disabled, forFace: 0, edgeIndices: [0, 3])

        let result = sut.apply(to: controller.grid, delegate)

        let edgesForFace: (FaceReferenceConvertible) -> [Edge.Id] = {
            result.edges(forFace: $0)
        }
        let edgeStatesForFace: (FaceReferenceConvertible) -> [Edge.State] = {
            edgesForFace($0).map(result.edgeState(forEdge:))
        }
        XCTAssertEqual(edgeStatesForFace(gridGen.faceId(atX: 2, y: 2)), [.normal, .marked, .marked, .normal])
        let printer = LoopyGridPrinter(squareGridColumns: 4, rows: 4)
        printer.printGrid(grid: result)
    }

    func testApplyToGrid_chainedSquareTwoEdgeOnThreeHints() {
        // Create a square grid like so:
        //
        //     •───•───•───•
        //   1 |   |   |   |
        // •───•───•───•───•
        // |   | 2 | 3 |   |
        // •───•───•───•───•
        // |   |   |   |   |
        // •───•───•───•───•
        //
        // The solver should not affect the '3' hint as the '2' hint's exit is
        // not enough to deduce a proper entrance
        let gridGen = LoopySquareGridGen(width: 4, height: 3)
        gridGen.setHint(x: 0, y: 0, hint: 1)
        gridGen.setHint(x: 1, y: 1, hint: 2)
        gridGen.setHint(x: 2, y: 1, hint: 3)
        let controller = LoopyGridController(grid: gridGen.generate())
        controller.setEdges(state: .disabled, forFace: 0, edgeIndices: [0, 3])

        let result = sut.apply(to: controller.grid, delegate)

        let edgesForFace: (FaceReferenceConvertible) -> [Edge.Id] = {
            result.edges(forFace: $0)
        }
        let edgeStatesForFace: (FaceReferenceConvertible) -> [Edge.State] = {
            edgesForFace($0).map(result.edgeState(forEdge:))
        }
        XCTAssertEqual(edgeStatesForFace(gridGen.faceId(atX: 2, y: 1)), [.normal, .normal, .normal, .normal])
        let printer = LoopyGridPrinter(squareGridColumns: 4, rows: 3)
        printer.printGrid(grid: result)
    }
}
