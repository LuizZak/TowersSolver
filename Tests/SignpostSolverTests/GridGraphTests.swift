import XCTest

@testable import SignpostSolver

class GridGraphTests: XCTestCase {
    typealias Node = GridGraph.Node
    typealias Edge = GridGraph.Edge

    func testFromGrid() {
        // Game available at: https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/signpost.html#3x3:1deecaaag9a
        let gen = SignpostGridGenerator(rows: 3, columns: 3)
        gen.loadFromGameID("1deecaaag9a")
        let grid = gen.grid
        
        let graph = GridGraph.fromGrid(grid)

        XCTAssertEqual(graph.nodes.sorted(), [
            _node(0, 0), _node(1, 0), _node(2, 0),
            _node(0, 1), _node(1, 1), _node(2, 1),
            _node(0, 2), _node(1, 2), _node(2, 2),
        ])
        XCTAssertEqual(graph.edges.sorted(), [
            // Row 0
            _edge(0, 0, 1, 1), _edge(0, 0, 2, 2),   // 1st cell
            _edge(1, 0, 1, 1), _edge(1, 0, 1, 2),   // 2nd cell
            _edge(2, 0, 2, 1), _edge(2, 0, 2, 2),   // 3rd cell

            // Row 1
            _edge(0, 1, 1, 1), _edge(0, 1, 2, 1),   // 4th cell
            _edge(1, 1, 1, 0),                      // 5th cell
            _edge(2, 1, 2, 0),                      // 6th cell

            // Row 2
            _edge(0, 2, 0, 1),                      // 7th cell
            _edge(1, 2, 0, 2),                      // 8th cell
        ])
    }

    func testFromGrid_connectNodes_false() {
        // Game available at: https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/signpost.html#3x3:1deecaaag9a
        let gen = SignpostGridGenerator(rows: 3, columns: 3)
        gen.loadFromGameID("1deecaaag9a")
        let grid = gen.grid
        
        let graph = GridGraph.fromGrid(grid, connectNodes: false)

        XCTAssertEqual(graph.nodes.sorted(), [
            _node(0, 0), _node(1, 0), _node(2, 0),
            _node(0, 1), _node(1, 1), _node(2, 1),
            _node(0, 2), _node(1, 2), _node(2, 2),
        ])
        XCTAssertEqual(graph.edges, [])
    }

    private func _node(_ column: Int, _ row: Int) -> Node {
        Node(column: column, row: row)
    }

    private func _edge(_ start: Node, _ end: Node) -> Edge {
        Edge(start: start, end: end)
    }

    private func _edge(_ c0: Int, _ r0: Int, _ c1: Int, _ r1: Int) -> Edge {
        Edge(start: _node(c0, r0), end: _node(c1, r1))
    }
}
