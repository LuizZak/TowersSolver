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

        var coordinates: Grid.Coordinates {
            (column, row)
        }

        init(column: Int, row: Int) {
            self.column = column
            self.row = row
        }

        init(_ coord: Grid.Coordinates) {
            self.column = coord.column
            self.row = coord.row
        }

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
    static func fromGrid(_ grid: Grid, connectionMode: ConnectionMode = .tilesInPathOfArrow) -> GridGraph {
        var graph = GridGraph()

        for tileCoord in grid.tileCoordinates {
            let node = Node(column: tileCoord.column, row: tileCoord.row)

            graph.nodes.append(node)

            switch connectionMode {
            case .noConnections:
                break

            case .connectedToProperty:
                guard let connectedTo = grid[tileCoord].connectedTo else {
                    break
                }

                graph.connect(start: Node(tileCoord), end: Node(connectedTo))

            case .tilesInPathOfArrow:
                // Do not connect nodes from end tile
                guard !grid[tileCoord].isEndTile else {
                    continue
                }

                let tilesFrom = grid
                    .tileCoordsPointedBy(column: tileCoord.column, row: tileCoord.row)
                    .filter {
                        !grid[$0].isStartTile
                    }
                    .filter {
                        switch (grid[node.coordinates].solution, grid[$0].solution) {
                        case (let lhs?, let rhs?):
                            return lhs == rhs - 1
                        default:
                            return true
                        }
                    }

                graph.edges.append(contentsOf:
                    tilesFrom.map {
                        Edge(start: node, end: Node(column: $0.column, row: $0.row))
                    }
                )
            }
        }

        return graph
    }

    enum ConnectionMode {
        case noConnections
        case tilesInPathOfArrow
        case connectedToProperty
    }
}

extension GridGraph {
    @discardableResult
    mutating func connect(start: Node, end: Node) -> Edge {
        if let existing = edge(from: start, to: end) {
            return existing
        }

        let edge = Edge(start: start, end: end)
        edges.append(edge)
        return edge
    }

    /// Connects two nodes such that the other entry/exit edges for each node are
    /// removed in the process, resulting in an exclusive path between `start -> end`
    @discardableResult
    mutating func connectExclusive(start: Node, end: Node) -> Edge {
        let fromStart = edges(from: start)
        let toEnd = edges(towards: end)

        edges.removeAll(where: fromStart.contains)
        edges.removeAll(where: toEnd.contains)

        return connect(start: start, end: end)
    }

    /// Returns a subgraph that represents a section of this graph with all nodes
    /// connected to a given node within it.
    ///
    /// If `node` has no connections, the resulting subgraph contains `node` only.
    @inlinable
    func subgraph(forNode node: Node) -> Self {
        var result = Self()

        var queue: [Node] = [node]
        var visited: Set<Node> = []

        while let next = queue.popLast() {
            if !visited.insert(next).inserted {
                continue
            }

            result.nodes.append(next)

            for nextNode in nodesConnected(from: next) {
                result.connect(start: next, end: nextNode)

                queue.append(nextNode)
            }
            for prevNode in nodesConnected(towards: next) {
                result.connect(start: prevNode, end: next)

                queue.append(prevNode)
            }
        }

        return result
    }

    /// Returns a list of graphs based on which island of nodes are connected
    /// within this graph.
    /// The resulting subgraphs are guaranteed to be connected within themselves
    /// within this graph, but not connected to any other node of any other
    /// subgraph.
    ///
    /// If a node has no connections, it is present as a single-node subgraph.
    @inlinable
    func subgraphs() -> [Self] {
        var result: [Self] = []
        var remaining: Set<Node> = Set(nodes)

        while !remaining.isEmpty {
            let node = remaining.removeFirst()

            let subgraph = self.subgraph(forNode: node)
            result.append(subgraph)

            remaining.subtract(subgraph.nodes)
        }

        return result
    }
}
