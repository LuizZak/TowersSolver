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

    func testApplyToGrid_invalidEdgeMarksBug() {
        // Test grid is an excerpt from the 10x10 Honeycomb Solver test:
        //
        //   •───•       •───•       •───•       •───•  
        //  /     \     /     \     /     \     /     \ 
        // •       •───•   4   •───•   2   •───•   4   •
        //  \     /     \     /     \     /     \     / 
        //   •───•   3   •───•       •───•   2   •───•  
        //  /     \     /     \     /     \     /     \ 
        // •   4   •───•       •───•       •───•       •
        //  \     /     \     /                 \     / 
        //   •───•   4   •───•   2   •   •   3   •/──•\ 
        //  /     \     /     \                 //    \\
        // •   4   •───•   4   •   •   2   •═══•/      •
        //  \     /     \     /           //          //
        //   •───•       •───•   2   •/══•/  4   •/══•/ 
        //  /     \     /     \     //          //      
        // •   4   •───•   4   •   •\  4   •═══•/      •
        //  \     /     \     /     \\    //            
        //   •───•       •───•       •/  •\  3   •   •  
        //        \     /     \     //    \\            
        //         •───•       •───•/      •   •
        let gen = LoopyHoneycombGridGenerator(width: 7, height: 4)
        // Row 0
        gen.setHint(x: 1, y: 0, hint: 3)
        gen.setHint(x: 2, y: 0, hint: 4)
        gen.setHint(x: 4, y: 0, hint: 2)
        gen.setHint(x: 5, y: 0, hint: 2)
        gen.setHint(x: 6, y: 0, hint: 4)
        // Row 1
        gen.setHint(x: 0, y: 1, hint: 4)
        gen.setHint(x: 1, y: 1, hint: 4)
        gen.setHint(x: 3, y: 1, hint: 2)
        gen.setHint(x: 5, y: 1, hint: 3)
        // Row 2
        gen.setHint(x: 0, y: 2, hint: 4)
        gen.setHint(x: 2, y: 2, hint: 4)
        gen.setHint(x: 3, y: 2, hint: 2)
        gen.setHint(x: 4, y: 2, hint: 2)
        gen.setHint(x: 5, y: 2, hint: 4)
        // Row 3
        gen.setHint(x: 0, y: 3, hint: 4)
        gen.setHint(x: 2, y: 3, hint: 4)
        gen.setHint(x: 4, y: 3, hint: 4)
        gen.setHint(x: 5, y: 3, hint: 3)
        // Controller
        let controller = LoopyGridController(grid: gen.generate())
        // Helper function
        func setEdges(x: Int, y: Int, _ states: [Edge.State]) {
            let face = gen.faceId(atX: x, y: y)
            let edges = controller.grid.edges(forFace: face)
            zip(edges, states).forEach { controller.grid.setEdge(state: $1, forEdge: $0) }
        }
        // Edge states
        // Row 1
        setEdges(x: 3, y: 1, [.normal, .disabled, .disabled, .disabled])
        setEdges(x: 4, y: 1, [.normal, .normal, .disabled, .disabled, .disabled])
        setEdges(x: 5, y: 1, [.normal, .normal, .marked, .marked, .disabled, .disabled])
        // Row 2
        setEdges(x: 3, y: 2, [.disabled, .disabled, .marked, .disabled])
        setEdges(x: 4, y: 2, [.disabled, .disabled, .marked, .marked])
        setEdges(x: 5, y: 2, [.marked, .disabled, .marked, .marked, .disabled, .marked])
        setEdges(x: 6, y: 2, [.normal, .marked, .marked, .marked, .disabled])
        // Row 3
        setEdges(x: 3, y: 3, [.disabled, .marked, .marked])
        setEdges(x: 4, y: 3, [.marked, .disabled, .marked, .disabled, .marked, .marked])
        setEdges(x: 5, y: 3, [.marked, .disabled, .disabled, .disabled, .marked])
        setEdges(x: 6, y: 3, [.marked, .disabled, .disabled, .disabled, .disabled, .marked])

        // Act
        let result = sut.apply(to: controller.grid, delegate)
        
        // Assert
        let edgesForFace: (_ x: Int, _ y: Int) -> [Edge.Id] = {
            let id = gen.faceId(atX: $0, y: $1)
            return result.edges(forFace: id)
        }
        let edgeStatesForFace: (_ x: Int, _ y: Int) -> [Edge.State] = {
            edgesForFace($0, $1).map(result.edgeState(forEdge:))
        }
        XCTAssertEqual(edgeStatesForFace(2, 3), [.normal, .normal, .normal, .normal, .normal, .normal])
        let printer = LoopyGridPrinter(honeycombGridColumns: 7 * 2, rows: 4 * 2, columnSize: 6.3, rowSize: 4.4)
        printer.printFaceIndices = true
        printer.printVertexIndices = true
        printer.printEdgeIndices = true
        printer.printGrid(grid: result)
    }
}
