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
}
