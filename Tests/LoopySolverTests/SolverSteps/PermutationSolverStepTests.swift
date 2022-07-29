import XCTest

@testable import LoopySolver

class PermutationSolverStepTests: XCTestCase {
    var sut: PermutationSolverStep!
    var delegate: SolverStepDelegate!

    override func setUp() {
        super.setUp()

        sut = PermutationSolverStep()
        delegate = TestSolverStepDelegate()
    }

    func testIsEphemeral() {
        XCTAssertFalse(sut.isEphemeral)
    }

    func testPermuteSolutionsAsEdges_normalEdges_noHint() {
        let grid = LoopySquareGridGen(width: 3, height: 3).generate()
        
        let result = sut.apply(to: grid, delegate)
        
        XCTAssertEqual(result, grid)
    }

    func testPermuteSolutionsAsEdges_singleSquareGrid() {
        let grid = LoopySquareGridGen(width: 1, height: 1).generate()
        
        let result = sut.apply(to: grid, delegate)
        
        XCTAssertEqual(result, grid)
    }

    func testPermuteSolutionsAsEdges_markedEdges_singleSquareGrid() {
        var grid = LoopySquareGridGen(width: 1, height: 1).generate()
        grid.setEdges(state: .marked, forEdges: [0, 2])
        
        let result = sut.apply(to: grid, delegate)
        
        XCTAssertEqual(result.edgeStatesForFace(0), [
            .marked, .marked, .marked, .marked,
        ])
    }

    func testPermuteSolutionsAsEdges_disableEdges_singleSquareGrid() {
        var grid = LoopySquareGridGen(width: 1, height: 1).generate()
        grid.setEdges(state: .disabled, forEdges: [0, 2])
        
        let result = sut.apply(to: grid, delegate)

        XCTAssertEqual(result.edgeStatesForFace(0), [
            .disabled, .disabled, .disabled, .disabled,
        ])
    }

    func testPermuteSolutionsAsEdges_markedEdges_noHint() {
        let gen = LoopySquareGridGen(width: 3, height: 3)
        let controller = LoopyGridController(grid: gen.generate())
        controller.setEdges(state: .marked, forFace: 4, edgeIndices: [0, 2])
        let grid = controller.grid
        
        let result = sut.apply(to: grid, delegate)

        XCTAssertEqual(result.edgeStatesForFace(4), [
            .marked, .normal, .marked, .normal,
        ])
    }

    func testPermuteSolutionsAsEdges_disabledEdges_noHint() {
        let gen = LoopySquareGridGen(width: 3, height: 3)
        let controller = LoopyGridController(grid: gen.generate())
        controller.setEdges(state: .disabled, forFace: 4, edgeIndices: [0, 2])
        let grid = controller.grid
        
        let result = sut.apply(to: grid, delegate)
        
        XCTAssertEqual(result.edgeStatesForFace(4), [
            .disabled, .normal, .disabled, .normal,
        ])
    }

    func testPermuteSolutionsAsEdges_normalEdges_hinted() {
        let gen = LoopySquareGridGen(width: 3, height: 3)
        gen.setHint(x: 1, y: 1, hint: 2)
        let grid = gen.generate()
        
        let result = sut.apply(to: grid, delegate)

        XCTAssertEqual(result.edgeStatesForFace(4), [
            .normal, .normal, .normal, .normal,
        ])
    }

    func testPermuteSolutionsAsEdges_markedEdges_hinted() {
        let gen = LoopySquareGridGen(width: 3, height: 3)
        gen.setHint(x: 1, y: 1, hint: 2)
        let controller = LoopyGridController(grid: gen.generate())
        controller.setEdges(state: .marked, forFace: 4, edgeIndices: [0])
        let grid = controller.grid
        
        let result = sut.apply(to: grid, delegate)

        XCTAssertEqual(result.edgeStatesForFace(4), [
            .marked, .normal, .normal, .normal,
        ])
    }

    func testPermuteSolutionsAsEdges_disabledEdges_hinted() {
        let gen = LoopySquareGridGen(width: 3, height: 3)
        gen.setHint(x: 1, y: 1, hint: 2)
        let controller = LoopyGridController(grid: gen.generate())
        controller.setEdges(state: .disabled, forFace: 4, edgeIndices: [0])
        let grid = controller.grid
        
        let result = sut.apply(to: grid, delegate)

        XCTAssertEqual(result.edgeStatesForFace(4), [
            .disabled, .normal, .normal, .normal,
        ])
    }

    func testPermuteSolutionsAsEdges_normalEdges_hinted_0() {
        let gen = LoopySquareGridGen(width: 1, height: 1)
        gen.setHint(x: 0, y: 0, hint: 0)
        let grid = gen.generate()
        
        let result = sut.apply(to: grid, delegate)

        XCTAssertEqual(result.edgeStatesForFace(0), [
            .disabled, .disabled, .disabled, .disabled,
        ])
    }

    func testPermuteSolutionsAsEdges_neighborEdgeMarked() {
        let gen = LoopySquareGridGen(width: 3, height: 3)
        let controller = LoopyGridController(grid: gen.generate())
        controller.setEdges(state: .marked, forFace: 5, edgeIndices: [2])
        let grid = controller.grid
        
        let result = sut.apply(to: grid, delegate)

        XCTAssertEqual(result.edgeStatesForFace(4), [
            .normal, .normal, .normal, .normal,
        ])
    }

    func testPermuteSolutionsAsEdges_edgeFace_honeycomb_mixedStates() {
        // Target honeycomb grid:
        //
        //    •───•
        //   /     \
        //  •       •───•
        //   \    //     \
        //    •───•       •
        //   /     \     /
        //  •   4   •───•
        //   \     /     \
        //    •───•       •
        //   /     \     /
        //  •       •───•
        //   \     /     \
        //    •───•       •
        //         \     /
        //          •───•

        let gen = LoopyHoneycombGridGenerator(width: 2, height: 3)
        gen.setHint(faceIndex: 2, hint: 4)
        let controller = LoopyGridController(grid: gen.generate())
        controller.setEdges(state: .marked, forFace: 0, edgeIndices: [2])
        let grid = controller.grid
        
        let result = sut.apply(to: grid, delegate)

        XCTAssertEqual(result.edgeStatesForFace(2), [
            .normal, .normal, .normal, .normal, .marked, .marked,
        ])
        let printer = LoopyGridPrinter(honeycombGridColumns: 2, rows: 3, columnSize: 7, rowSize: 4.5)
        printer.printGrid(grid: grid)
    }
}

private extension LoopyGrid {
    func edgesForFace(_ faceId: Int) -> [Edge.Id] {
        edges(forFace: faceId)
    }

    func edgeStatesForFace(_ faceId: Int) -> [Edge.State] {
        edgesForFace(faceId).map(edgeState(forEdge:))
    }
}
