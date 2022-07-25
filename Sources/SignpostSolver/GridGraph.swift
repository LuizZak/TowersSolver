import Geometry

/// Represents a signposts grid as a graph where each node is a tile, and each
/// edge connects to tiles that are in the direction that a tile is pointing
/// to.
struct GridGraph: DirectedGraph {
    var nodes: [Node] = []
    var edges: [Edge] = []

    func areNodesEqual(_ node1: Node, _ node2: Node) -> Bool {
        node1 == node2
    }

    func startNode(for edge: Edge) -> Node {
        edge.start
    }

    func endNode(for edge: Edge) -> Node {
        edge.end
    }

    func edges(from node: Node) -> [Edge] {
        edges.filter {
            $0.start == node
        }
    }

    func edges(towards node: Node) -> [Edge] {
        edges.filter {
            $0.end == node
        }
    }

    func edge(from start: Node, to end: Node) -> Edge? {
        edges.first {
            $0.start == start && $0.end == end
        }
    }

    struct Edge: DirectedGraphEdge, CustomStringConvertible, Comparable {
        var start: Node
        var end: Node

        var description: String {
            "\(start) -> \(end)"
        }

        static func < (lhs: Self, rhs: Self) -> Bool {
            if lhs.start == rhs.start {
                return lhs.end < rhs.end
            }
            
            return lhs.start < rhs.start
        }
    }

    struct Node: DirectedGraphNode, CustomStringConvertible, Comparable {
        var column: Int, row: Int

        var description: String {
            "(\(column), \(row))"
        }

        static func < (lhs: Self, rhs: Self) -> Bool {
            if lhs.row == rhs.row {
                return (lhs.column < rhs.column)
            }

            return lhs.row < rhs.row
        }
    }
}

extension GridGraph {
    /// Creates a new grid graph for a given grid input.
    static func fromGrid(_ grid: Grid) -> GridGraph {
        var graph = GridGraph()

        for tileCoord in grid.tileCoordinates {
            let node = Node(column: tileCoord.column, row: tileCoord.row)

            graph.nodes.append(node)

            // Do not connect nodes from end tile
            if grid[tileCoord].isEndTile {
                continue
            }

            let tilesFrom = grid
                .tileCoordsPointedBy(column: tileCoord.column, row: tileCoord.row)
                .filter {
                    !grid[$0].isStartTile
                }

            graph.edges.append(contentsOf:
                tilesFrom.map {
                    Edge(start: node, end: Node(column: $0.column, row: $0.row))
                }
            )
        }

        return graph
    }
}
