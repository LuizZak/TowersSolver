import XCTest

@testable import LoopySolver

class InsideOutsideSolverStepTests: XCTestCase {
    
    var sut: InsideOutsideSolverStep!
    var delegate: SolverStepDelegate!

    override func setUp() {
        super.setUp()

        sut = InsideOutsideSolverStep()
        delegate = TestSolverStepDelegate()
    }

    func testIsEphemeral() {
        XCTAssertFalse(sut.isEphemeral)
    }

    func testApplyToGrid_outsideToInsideEdge() {
        // Create a 3x4 square grid with marked edges like so:
        //
        // •───•===•───•
        // |   |   |   |
        // •───•===•───•
        // |   |   |   |
        // •───•-X-•───•
        // |   |   |   |
        // •───•===•───•
        // |   |   |   |
        // •───•===•───•
        //
        // Result should be a grid where the marked edge in the center is disabled
        // to account for the fact that its top/bottom faces are both part of the
        // 'outside' of the loop due to neighboring 'inside' faces up and bellow
        let gridGen = LoopySquareGridGen(width: 3, height: 4)
        let controller = LoopyGridController(grid: gridGen.generate())
        controller.setEdges(state: .marked, forFace: 1, edgeIndices: [0, 2])
        controller.setEdges(state: .marked, forFace: 10, edgeIndices: [0, 2])

        let result = sut.apply(to: controller.grid, delegate)

        let edgesForFace: (Int) -> [Edge.Id] = {
            result.edges(forFace: $0)
        }
        let edgeStatesForFace: (Int) -> [Edge.State] = {
            edgesForFace($0).map(result.edgeState(forEdge:))
        }
        XCTAssertEqual(edgeStatesForFace(4), [.marked, .normal, .disabled, .normal])
        XCTAssertEqual(edgeStatesForFace(7), [.disabled, .normal, .marked, .normal])
        let printer = LoopyGridPrinter(squareGridColumns: 3, rows: 4, printFaceIndices: true)
        printer.printGrid(grid: result)
    }

    func testApplyToGrid_insideToInsideEdge() {
        // Create a 3x4 square grid with marked edges like so:
        //
        // •───•===•───•
        // |   |   |   |
        // •───•   •───•
        // |   |   |   |
        // •───•-X-•───•
        // |   |   |   |
        // •───•   •───•
        // |   |   |   |
        // •───•===•───•
        //
        // Result should be a grid where the marked edge in the center is disabled
        // to account for the fact that its top/bottom faces are both part of the
        // 'outside' of the loop due to neighboring 'inside' faces up and bellow
        let gridGen = LoopySquareGridGen(width: 3, height: 4)
        let controller = LoopyGridController(grid: gridGen.generate())
        controller.setEdges(state: .marked, forFace: 1, edgeIndices: [0])
        controller.setEdges(state: .disabled, forFace: 1, edgeIndices: [2])
        controller.setEdges(state: .marked, forFace: 10, edgeIndices: [2])
        controller.setEdges(state: .disabled, forFace: 10, edgeIndices: [0])

        let result = sut.apply(to: controller.grid, delegate)

        let edgesForFace: (Int) -> [Edge.Id] = {
            result.edges(forFace: $0)
        }
        let edgeStatesForFace: (Int) -> [Edge.State] = {
            edgesForFace($0).map(result.edgeState(forEdge:))
        }
        XCTAssertEqual(edgeStatesForFace(4), [.disabled, .normal, .disabled, .normal])
        XCTAssertEqual(edgeStatesForFace(7), [.disabled, .normal, .disabled, .normal])
        let printer = LoopyGridPrinter(squareGridColumns: 3, rows: 4, printFaceIndices: true)
        printer.printGrid(grid: result)
    }

    func testApplyToGrid_markOuterEdgesOfInsideArea() {
        // Create a 3x4 square grid with marked edges like so:
        //
        // •───•───•───•
        // |   |   |   |
        // •───•===•───•
        //
        // Result should be the top edge of the center square is marked as part
        // of the solution
        let gridGen = LoopySquareGridGen(width: 3, height: 1)
        let controller = LoopyGridController(grid: gridGen.generate())
        controller.setEdges(state: .marked, forFace: 1, edgeIndices: [2])

        let result = sut.apply(to: controller.grid, delegate)

        let edgesForFace: (Int) -> [Edge.Id] = {
            result.edges(forFace: $0)
        }
        let edgeStatesForFace: (Int) -> [Edge.State] = {
            edgesForFace($0).map(result.edgeState(forEdge:))
        }
        XCTAssertEqual(edgeStatesForFace(1), [.marked, .normal, .marked, .normal])
        let printer = LoopyGridPrinter(squareGridColumns: 3, rows: 1, printFaceIndices: true)
        printer.printGrid(grid: result)
    }

    func testApplyToGrid_disableOuterEdgesOfOutsideGraph() {
        // Create a 3x4 square grid with marked edges like so:
        //
        // •───•───•───•
        // |   |   |   |
        // •───•===•───•
        // |   |   |   |
        // •───•===•───•
        //
        // Result should be the top edge of the top-center square is disabled
        let gridGen = LoopySquareGridGen(width: 3, height: 2)
        let controller = LoopyGridController(grid: gridGen.generate())
        controller.setEdges(state: .marked, forFace: 4, edgeIndices: [0, 2])

        let result = sut.apply(to: controller.grid, delegate)

        let edgesForFace: (Int) -> [Edge.Id] = {
            result.edges(forFace: $0)
        }
        let edgeStatesForFace: (Int) -> [Edge.State] = {
            edgesForFace($0).map(result.edgeState(forEdge:))
        }
        XCTAssertEqual(edgeStatesForFace(1), [.disabled, .normal, .marked, .normal])
        let printer = LoopyGridPrinter(squareGridColumns: 3, rows: 2, printFaceIndices: true)
        printer.printGrid(grid: result)
    }

    func testApplyToGrid_dontEnclosedSpacesForSingleInsideNetworks() {
        // Create a 3x3 square grid with marked edges like so:
        //
        // •───•───•───•
        // |   |   |   |
        // •───•───•───•
        // |   ║   ║   |
        // •───•   •───•
        // |   ║   ║   |
        // •───•===•───•
        //
        // Grid should not extend the enclosed space because there is exactly
        // one inside space
        let gridGen = LoopySquareGridGen(width: 3, height: 3)
        let controller = LoopyGridController(grid: gridGen.generate())
        controller.setEdges(state: .marked, forFace: gridGen.faceId(atX: 1, y: 1), edgeIndices: [1, 3])
        controller.setEdges(state: .marked, forFace: gridGen.faceId(atX: 1, y: 2), edgeIndices: [1, 2, 3])
        controller.setEdges(state: .disabled, forFace: gridGen.faceId(atX: 1, y: 2), edgeIndices: [0])

        let result = sut.apply(to: controller.grid, delegate)

        let edgesForFace: (Int) -> [Edge.Id] = {
            result.edges(forFace: $0)
        }
        let edgeStatesForFace: (Int) -> [Edge.State] = {
            edgesForFace($0).map(result.edgeState(forEdge:))
        }
        XCTAssertEqual(edgeStatesForFace(1), [.normal, .normal, .normal, .normal])
        let printer = LoopyGridPrinter(squareGridColumns: 3, rows: 3, printFaceIndices: true)
        printer.printGrid(grid: result)
    }

    func testApplyToGrid_extendEnclosedInsideSpaces() {
        // Create a 3x3 square grid with marked edges like so:
        //
        // •───•───•───•
        // ║   |   |   |
        // •───•───•───•
        // |   ║   ║   |
        // •───•   •───•
        // |   ║   ║   |
        // •───•===•───•
        //
        // Grid should extend the enclosed space at the center.
        let gridGen = LoopySquareGridGen(width: 3, height: 3)
        let controller = LoopyGridController(grid: gridGen.generate())
        controller.setEdges(state: .marked, forFace: gridGen.faceId(atX: 0, y: 0), edgeIndices: [0])
        controller.setEdges(state: .marked, forFace: gridGen.faceId(atX: 1, y: 1), edgeIndices: [1, 3])
        controller.setEdges(state: .marked, forFace: gridGen.faceId(atX: 1, y: 2), edgeIndices: [1, 2, 3])
        controller.setEdges(state: .disabled, forFace: gridGen.faceId(atX: 1, y: 2), edgeIndices: [0])

        let result = sut.apply(to: controller.grid, delegate)

        let edgesForFace: (Int) -> [Edge.Id] = {
            result.edges(forFace: $0)
        }
        let edgeStatesForFace: (Int) -> [Edge.State] = {
            edgesForFace($0).map(result.edgeState(forEdge:))
        }
        XCTAssertEqual(edgeStatesForFace(1), [.normal, .normal, .disabled, .normal])
        let printer = LoopyGridPrinter(squareGridColumns: 3, rows: 3, printFaceIndices: true)
        printer.printGrid(grid: result)
    }

    func testApplyToGrid_extendEnclosedOutsideSpaces() {
        // Create a 3x3 square grid with marked edges like so:
        //
        // •───•===•───•
        // |   |   |   |
        // •───•===•───•
        // |   ║   ║   |
        // •───•───•───•
        // |   |   |   |
        // •───•───•───•
        //
        // Grid should extend the enclosed outside space in the center.
        let gridGen = LoopySquareGridGen(width: 3, height: 3)
        let controller = LoopyGridController(grid: gridGen.generate())
        controller.setEdges(state: .marked, forFace: gridGen.faceId(atX: 1, y: 0), edgeIndices: [0, 2])
        controller.setEdges(state: .marked, forFace: gridGen.faceId(atX: 1, y: 1), edgeIndices: [1, 3])

        let result = sut.apply(to: controller.grid, delegate)

        let edgesForFace: (FaceReferenceConvertible) -> [Edge.Id] = {
            result.edges(forFace: $0)
        }
        let edgeStatesForFace: (FaceReferenceConvertible) -> [Edge.State] = {
            edgesForFace($0).map(result.edgeState(forEdge:))
        }
        XCTAssertEqual(edgeStatesForFace(gridGen.faceId(atX: 1, y: 1)), [.marked, .marked, .disabled, .marked])
        let printer = LoopyGridPrinter(squareGridColumns: 3, rows: 3, printFaceIndices: true)
        printer.printGrid(grid: result)
    }

    func testApplyToGrid_dontExtendEnclosedSpacesWithOpenEdges() {
        // Create a 2x3 square grid with marked edges like so:
        //
        // •===•───•
        // |   |   |
        // •===•───•
        //     ║   |
        // •───•───•
        // |   |   |
        // •───•───•
        //
        // Grid should not extend the enclosed outside space in the center as
        // it is not fully enclosed by marked edges.
        let gridGen = LoopySquareGridGen(width: 2, height: 3)
        let controller = LoopyGridController(grid: gridGen.generate())
        controller.setEdges(state: .marked, forFace: gridGen.faceId(atX: 0, y: 0), edgeIndices: [0, 2])
        controller.setEdges(state: .marked, forFace: gridGen.faceId(atX: 0, y: 1), edgeIndices: [1])
        controller.setEdges(state: .disabled, forFace: gridGen.faceId(atX: 0, y: 1), edgeIndices: [3])

        let result = sut.apply(to: controller.grid, delegate)

        let edgesForFace: (FaceReferenceConvertible) -> [Edge.Id] = {
            result.edges(forFace: $0)
        }
        let edgeStatesForFace: (FaceReferenceConvertible) -> [Edge.State] = {
            edgesForFace($0).map(result.edgeState(forEdge:))
        }
        XCTAssertEqual(edgeStatesForFace(gridGen.faceId(atX: 0, y: 1)), [.marked, .marked, .normal, .disabled])
        let printer = LoopyGridPrinter(squareGridColumns: 2, rows: 3, printFaceIndices: true)
        printer.printGrid(grid: result)
    }
    
    // Following two tests from InvalidLoopClosingDetectionSolverStep

    func testApplyToGrid_extendIncompleteLoop() {
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
        XCTAssertEqual(edgeStatesForFace(0), [.marked, .disabled, .marked, .marked])
        // Center left
        XCTAssertEqual(edgeStatesForFace(1), [.normal, .disabled, .normal, .disabled])
        // Center right
        XCTAssertEqual(edgeStatesForFace(2), [.marked, .disabled, .marked, .disabled])
        // Right `3`
        XCTAssertEqual(edgeStatesForFace(3), [.marked, .marked, .marked, .disabled])
        let printer = LoopyGridPrinter(squareGridColumns: 4, rows: 1, printFaceIndices: true)
        printer.printGrid(grid: result)
    }

    func testApplyToGrid_dontMarkPotentialEdgeAsDisabled() {
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
