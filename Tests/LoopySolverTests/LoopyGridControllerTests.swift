import LoopySolver
import XCTest

class LoopyGridControllerTests: XCTestCase {
    func testSetEdgeStateForFaceEdgeIndex() {
        // Produce a 2x2 grid that has the all top horizontal edges of the faces
        // disabled
        //
        //  .   .   .
        //  !   !   !
        //  !___!___!
        //
        let grid = LoopySquareGridGen(width: 2, height: 2).generate()
        let sut = LoopyGridController(grid: grid)

        sut.setEdge(state: .disabled, forFace: 0, edgeIndex: 0)
        sut.setEdge(state: .disabled, forFace: 1, edgeIndex: 0)
        sut.setEdge(state: .disabled, forFace: 2, edgeIndex: 0)
        sut.setEdge(state: .disabled, forFace: 3, edgeIndex: 0)

        let edgeStates = sut.grid.edgeIds.map(sut.grid.edgeState(forEdge:))
        XCTAssertEqual(
            edgeStates,
            [
                // Top-left edges
                .disabled,
                .normal,
                .disabled,
                .normal,
                // Top-right edges
                .disabled,
                .normal,
                .disabled,
                // Bottom-left edges
                .normal,
                .normal,
                .normal,
                // Bottom-right
                .normal,
                .normal,
            ]
        )
    }

    func testSemiCompleteFaces() {
        // Create a grid with a given configuration:
        // ._________. _________.
        // |         | \   1   /
        // |         |   \   /
        // |    3    | 2  >.
        // |         |   /
        // !_________! /
        //
        var grid = LoopyGrid()
        grid.addVertex(Vertex(x: 0, y: 0))
        grid.addVertex(Vertex(x: 1, y: 0))
        grid.addVertex(Vertex(x: 1, y: 1))
        grid.addVertex(Vertex(x: 0, y: 1))
        grid.addVertex(Vertex(x: 3, y: 0))
        grid.addVertex(Vertex(x: 2, y: 0.5))
        let f1 = grid.createFace(withVertexIndices: [0, 1, 2, 3], hint: 3)
        let f2 = grid.createFace(withVertexIndices: [1, 5, 2], hint: 2)
        grid.createFace(withVertexIndices: [1, 4, 5], hint: 1)
        let sut = LoopyGridController(grid: grid)

        let faces = sut.semiCompleteFaces()

        XCTAssertEqual(faces.count, 2)
        XCTAssert(faces.contains(f1))
        XCTAssert(faces.contains(f2))
    }
}
