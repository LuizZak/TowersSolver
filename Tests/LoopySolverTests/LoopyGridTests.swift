import Geometry
import XCTest

@testable import LoopySolver

class LoopyGridTests: XCTestCase {

    static var allTests: [(String, () -> Void)] = []

    var grid: LoopyGrid!
    var width: Int = 5
    var height: Int = 6

    override func setUp() {
        super.setUp()

        grid = LoopyGrid()
    }

    func testAddVertex() {
        grid.addVertex(Vertex(x: 0, y: 1))

        XCTAssertEqual(grid.vertices.count, 1)
        XCTAssertEqual(grid.vertices.first, Vertex(x: 0, y: 1))
    }

    func testAddOrGetVertexAtXYFloat() {
        XCTAssertEqual(grid.addOrGetVertex(x: 0.0, y: 0.0), 0)
        XCTAssertEqual(grid.addOrGetVertex(x: 1.0, y: 0.0), 1)
        XCTAssertEqual(grid.addOrGetVertex(x: 0.0, y: 0.0), 0)

        XCTAssertEqual(grid.vertices.count, 2)
    }

    func testAddOrGetVertexAtXYInt() {
        XCTAssertEqual(grid.addOrGetVertex(x: 0, y: 0), 0)
        XCTAssertEqual(grid.addOrGetVertex(x: 1, y: 0), 1)
        XCTAssertEqual(grid.addOrGetVertex(x: 0, y: 0), 0)

        XCTAssertEqual(grid.vertices.count, 2)
    }

    func testAddOrGetVertex() {
        XCTAssertEqual(grid.addOrGetVertex(Vertex(x: 0, y: 0)), 0)
        XCTAssertEqual(grid.addOrGetVertex(Vertex(x: 1, y: 0)), 1)
        XCTAssertEqual(grid.addOrGetVertex(Vertex(x: 0, y: 0)), 0)

        XCTAssertEqual(grid.vertices.count, 2)
    }

    func testVertexIndex() {
        grid.addVertex(Vertex(x: 0, y: 1))

        XCTAssertEqual(grid.vertexIndex(x: 0, y: 1), 0)
        XCTAssertNil(grid.vertexIndex(x: 1, y: 1))
    }

    func testAddFace() {
        grid.addVertex(Vertex(x: 0, y: 0))
        grid.addVertex(Vertex(x: 1, y: 0))
        grid.addVertex(Vertex(x: 1, y: 1))
        grid.addVertex(Vertex(x: 0, y: 1))

        let faceId = grid.createFace(withVertexIndices: [0, 1, 2, 3], hint: 1)

        XCTAssertEqual(faceId.value, 0)
        XCTAssertEqual(grid.faces.count, 1)
        XCTAssertEqual(grid.hintForFace(faceId), 1)
        XCTAssertEqual(grid.faces[0].localToGlobalEdges.map { $0.value }, [0, 1, 2, 3])
    }

    func testAddFaceCorrectlySetsupEdges() {
        grid.addVertex(Vertex(x: 0, y: 0))  // 0
        grid.addVertex(Vertex(x: 1, y: 0))  // 1
        grid.addVertex(Vertex(x: 2, y: 0))  // 2
        grid.addVertex(Vertex(x: 0, y: 1))  // 3
        grid.addVertex(Vertex(x: 1, y: 1))  // 4
        grid.addVertex(Vertex(x: 2, y: 1))  // 5

        grid.createFace(withVertexIndices: [0, 1, 4, 3], hint: nil)
        grid.createFace(withVertexIndices: [1, 2, 5, 4], hint: nil)

        XCTAssertEqual(grid.edges.count, 7)
        XCTAssertEqual(grid.edges[0], Edge(start: 0, end: 1))
        XCTAssertEqual(grid.edges[1], Edge(start: 1, end: 4))
        XCTAssertEqual(grid.edges[2], Edge(start: 4, end: 3))
        XCTAssertEqual(grid.edges[3], Edge(start: 3, end: 0))
        XCTAssertEqual(grid.edges[4], Edge(start: 1, end: 2))
        XCTAssertEqual(grid.edges[5], Edge(start: 2, end: 5))
        XCTAssertEqual(grid.edges[6], Edge(start: 4, end: 5))
    }

    func testAddFaceDoesntDuplicateEdges() {
        // Create two triangle faces forming a box
        grid.addVertex(Vertex(x: 0, y: 0))
        grid.addVertex(Vertex(x: 1, y: 0))
        grid.addVertex(Vertex(x: 1, y: 1))
        grid.addVertex(Vertex(x: 0, y: 1))
        grid.createFace(withVertexIndices: [0, 1, 2], hint: nil)
        grid.createFace(withVertexIndices: [2, 3, 0], hint: nil)

        XCTAssertEqual(grid.edges.count, 5)
        XCTAssertEqual(grid.edges[0], Edge(start: 0, end: 1))
        XCTAssertEqual(grid.edges[1], Edge(start: 1, end: 2))
        XCTAssertEqual(grid.edges[2], Edge(start: 2, end: 0))
        XCTAssertEqual(grid.edges[3], Edge(start: 2, end: 3))
        XCTAssertEqual(grid.edges[4], Edge(start: 3, end: 0))
    }

    func testFacesSharingVertex() {
        // Create two triangle faces forming a box
        grid.addVertex(Vertex(x: 0, y: 0))
        grid.addVertex(Vertex(x: 1, y: 0))
        grid.addVertex(Vertex(x: 1, y: 1))
        grid.addVertex(Vertex(x: 0, y: 1))
        let face1 = grid.createFace(withVertexIndices: [0, 1, 2], hint: nil)
        let face2 = grid.createFace(withVertexIndices: [2, 3, 0], hint: nil)

        XCTAssertEqual(grid.facesSharing(vertexIndex: 0), [face1, face2])
        XCTAssertEqual(grid.facesSharing(vertexIndex: 1), [face1])
        XCTAssertEqual(grid.facesSharing(vertexIndex: 3), [face2])
        XCTAssertEqual(grid.faces[0].localToGlobalEdges.map { $0.value }, [0, 1, 2])
        XCTAssertEqual(grid.faces[1].localToGlobalEdges.map { $0.value }, [3, 4, 2])
    }

    func testIsFaceSolved() {
        grid = LoopySquareGridGen(width: 2, height: 2).generate()
        grid.withFace(0) { $0.hint = 2 }
        grid.withFace(1) { $0.hint = 2 }
        grid.withEdge(0) { $0.state = .marked }
        grid.withEdge(1) { $0.state = .marked }

        XCTAssert(grid.isFaceSolved(0))
        XCTAssertFalse(grid.isFaceSolved(1))
        XCTAssert(grid.isFaceSolved(2))
        XCTAssert(grid.isFaceSolved(3))
    }

    func testFaceIsSolvedIsTrueForNonHintedFaces() {
        grid = LoopySquareGridGen(width: 1, height: 1).generate()

        XCTAssert(grid.isFaceSolved(0))
    }

    func testFaceIsSolvedIsFalseForHintedFacesThatAreEmpty() {
        grid = LoopySquareGridGen(width: 1, height: 1).generate()
        grid.withFace(0) { $0.hint = 2 }

        XCTAssertFalse(grid.isFaceSolved(0))
    }

    func testEdgesConnectedTo() {
        // Create two triangle faces forming a box
        grid.addVertex(Vertex(x: 0, y: 0))
        grid.addVertex(Vertex(x: 1, y: 0))
        grid.addVertex(Vertex(x: 1, y: 1))
        grid.addVertex(Vertex(x: 0, y: 1))
        grid.createFace(withVertexIndices: [0, 1, 2], hint: nil)
        grid.createFace(withVertexIndices: [2, 3, 0], hint: nil)

        XCTAssertEqual(grid.edgesConnected(to: 0), [1, 2, 4])
        XCTAssertEqual(grid.edgesConnected(to: 1), [0, 2, 3])
        XCTAssertEqual(grid.edgesConnected(to: 2), [1, 0, 3, 4])
        XCTAssertEqual(grid.edgesConnected(to: 3), [1, 2, 4])
        XCTAssertEqual(grid.edgesConnected(to: 4), [3, 0, 2])
    }
    
    func testNonSharedEdges() {
        grid = LoopySquareGridGen(width: 3, height: 3).generate()

        // Center face shares all edges with all connecting faces
        XCTAssert(grid.nonSharedEdges(forFace: 4).isEmpty)
        // Corner faces share only two edges
        XCTAssertEqual(grid.nonSharedEdges(forFace: 0), [0, 3])
        // Lateral faces share three edges with neighboring faces
        XCTAssertEqual(grid.nonSharedEdges(forFace: 1), [4])
    }

    func testFacesConnectedTo() {
        grid = LoopySquareGridGen(width: 3, height: 3).generate()
        grid.setEdges(state: .disabled, forFace: 0)
        grid.setEdges(state: .marked, forFace: 3)

        XCTAssertEqual(grid.facesConnectedTo(0), [1])
    }

    func testFacesDisconnectedTo() {
        grid = LoopySquareGridGen(width: 3, height: 3).generate()
        grid.setEdges(state: .disabled, forFace: 0)
        grid.setEdges(state: .marked, forFace: 3)

        XCTAssertEqual(grid.facesDisconnectedTo(0), [3])
    }

    func testNetworkForFace() {
        grid = LoopySquareGridGen(width: 5, height: 2).generate()
        grid.setEdges(state: .disabled, forFace: 0)
        grid.setEdges(state: .disabled, forFace: 1)
        grid.setEdges(state: .disabled, forFace: 4)
        grid.setEdges(state: .marked, forFace: 5)

        XCTAssertEqual(grid.networkForFace(0).faces.sorted(by: { $0.value < $1.value }), [
            0, 1, 2, 6
        ])
    }

    func testNeighboringNetworksOf() {
        grid = LoopySquareGridGen(width: 5, height: 2).generate()
        grid.setEdges(state: .disabled, forFace: 0)
        grid.setEdges(state: .disabled, forFace: 1)
        grid.setEdges(state: .marked, forFace: 3)
        grid.setEdges(state: .disabled, forFace: 4)
        grid.setEdges(state: .marked, forFace: 5)

        let result = grid.neighboringNetworksFor([0, 1, 2, 6])

        XCTAssertEqual(Set(result.map(\.faces)), [
            [5],
            [3, 4, 9],
        ])
        let printer = LoopyGridPrinter(squareGridColumns: 5, rows: 2, printFaceIndices: true)
        printer.printGrid(grid: grid)
    }

    func testPermuteSolutionsAsEdges_normalEdges_noHint() {
        grid = LoopySquareGridGen(width: 3, height: 3).generate()
        
        let result = grid.permuteSolutionsAsEdges(forFace: 4)

        assertPermutations(result, match: [
            [],
            [6],
            [6, 10],
            [6, 10, 13],
            [6, 10, 13, 14],
            [6, 10, 14],
            [6, 13],
            [6, 13, 14],
            [6, 14],
            [10],
            [10, 13],
            [10, 13, 14],
            [10, 14],
            [13],
            [13, 14],
            [14]
        ])
    }

    func testPermuteSolutionsAsEdges_singleSquareGrid() {
        grid = LoopySquareGridGen(width: 1, height: 1).generate()
        
        let result = grid.permuteSolutionsAsEdges(forFace: 0)

        assertPermutations(result, match: [
            [],
            [0, 1, 2, 3],
        ])
    }

    func testPermuteSolutionsAsEdges_markedEdges_singleSquareGrid() {
        grid = LoopySquareGridGen(width: 1, height: 1).generate()
        grid.setEdges(state: .marked, forEdges: [0, 2])
        
        let result = grid.permuteSolutionsAsEdges(forFace: 0)

        assertPermutations(result, match: [
            [0, 1, 2, 3],
        ])
    }

    func testPermuteSolutionsAsEdges_disableEdges_singleSquareGrid() {
        grid = LoopySquareGridGen(width: 1, height: 1).generate()
        grid.setEdges(state: .disabled, forEdges: [0, 2])
        
        let result = grid.permuteSolutionsAsEdges(forFace: 0)

        assertPermutations(result, match: [
            [],
        ])
    }

    func testPermuteSolutionsAsEdges_markedEdges_noHint() {
        let gen = LoopySquareGridGen(width: 3, height: 3)
        let controller = LoopyGridController(grid: gen.generate())
        controller.setEdges(state: .marked, forFace: 4, edgeIndices: [0, 2])
        grid = controller.grid
        
        let result = grid.permuteSolutionsAsEdges(forFace: 4)

        assertPermutations(result, match: [
            [6, 10, 13, 14],
            [6, 10, 14],
            [6, 13, 14],
            [6, 14],
        ])
    }

    func testPermuteSolutionsAsEdges_disabledEdges_noHint() {
        let gen = LoopySquareGridGen(width: 3, height: 3)
        let controller = LoopyGridController(grid: gen.generate())
        controller.setEdges(state: .disabled, forFace: 4, edgeIndices: [0, 2])
        grid = controller.grid
        
        let result = grid.permuteSolutionsAsEdges(forFace: 4)

        assertPermutations(result, match: [
            [],
            [10],
            [10, 13],
            [13],
        ])
    }

    func testPermuteSolutionsAsEdges_normalEdges_hinted() {
        let gen = LoopySquareGridGen(width: 3, height: 3)
        gen.setHint(x: 1, y: 1, hint: 2)
        grid = gen.generate()
        
        let result = grid.permuteSolutionsAsEdges(forFace: 4)

        assertPermutations(result, match: [
            [6, 10],
            [6, 13],
            [6, 14],
            [10, 13],
            [10, 14],
            [13, 14]
        ])
    }

    func testPermuteSolutionsAsEdges_markedEdges_hinted() {
        let gen = LoopySquareGridGen(width: 3, height: 3)
        gen.setHint(x: 1, y: 1, hint: 2)
        let controller = LoopyGridController(grid: gen.generate())
        controller.setEdges(state: .marked, forFace: 4, edgeIndices: [0])
        grid = controller.grid
        
        let result = grid.permuteSolutionsAsEdges(forFace: 4)

        assertPermutations(result, match: [
            [6, 10],
            [6, 13],
            [6, 14],
        ])
    }

    func testPermuteSolutionsAsEdges_disabledEdges_hinted() {
        let gen = LoopySquareGridGen(width: 3, height: 3)
        gen.setHint(x: 1, y: 1, hint: 2)
        let controller = LoopyGridController(grid: gen.generate())
        controller.setEdges(state: .disabled, forFace: 4, edgeIndices: [0])
        grid = controller.grid
        
        let result = grid.permuteSolutionsAsEdges(forFace: 4)

        assertPermutations(result, match: [
            [10, 13],
            [10, 14],
            [13, 14],
        ])
    }

    func testPermuteSolutionsAsEdges_normalEdges_hinted_0() {
        let gen = LoopySquareGridGen(width: 1, height: 1)
        gen.setHint(x: 0, y: 0, hint: 0)
        grid = gen.generate()
        
        let result = grid.permuteSolutionsAsEdges(forFace: 0)

        assertPermutations(result, match: [
            [],
        ])
    }

    func testPermuteSolutionsAsEdges_neighborEdgeMarked() {
        let gen = LoopySquareGridGen(width: 3, height: 3)
        let controller = LoopyGridController(grid: gen.generate())
        controller.setEdges(state: .marked, forFace: 5, edgeIndices: [2])
        grid = controller.grid
        
        let result = grid.permuteSolutionsAsEdges(forFace: 4)

        assertPermutations(result, match: [
            [],
            [6],
            [6, 10],
            [6, 10, 13],
            [6, 10, 14],
            [6, 13],
            [6, 14],
            [10],
            [10, 13],
            [10, 14],
            [13],
            [14],
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
        grid = controller.grid
        let printer = LoopyGridPrinter(honeycombGridColumns: 2, rows: 3, columnSize: 7, rowSize: 4.5)
        printer.printGrid(grid: grid)
        
        let result = grid.permuteSolutionsAsEdges(forFace: 2)

        assertPermutations(result, match: [
            [3, 11, 13, 14],
            [3, 12, 13, 14],
            [10, 11, 13, 14],
            [10, 12, 13, 14],
        ])
    }
}

private func assertPermutations<S: Sequence, E: Comparable>(
    _ input: S,
    match expected: [[E]],
    line: UInt = #line
) where S.Element == Set<E> {

    // Pre-sort objects
    let sortedInput = input
        .map {
            Array($0).sorted()
        }.sorted(by: {
            $0.lexicographicallyPrecedes($1)
        })
    
    let sortedExpected = expected
        .map {
            Array($0).sorted()
        }.sorted(by: {
            $0.lexicographicallyPrecedes($1)
        })
    
    XCTAssertEqual(sortedInput, sortedExpected, line: line)
}
