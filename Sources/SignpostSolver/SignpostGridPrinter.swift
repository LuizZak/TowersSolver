import Console

public class SignpostGridPrinter: ConsolePrintBuffer {
    public override init(bufferWidth: Int, bufferHeight: Int) {
        super.init(bufferWidth: bufferWidth, bufferHeight: bufferHeight)
    }

    /// Initializes a grid printer with a buffer capable of rendering a grid of
    /// given size where each cell has 6 characters of width and 3 of height.
    public init(bufferForGridWidth width: Int, height: Int) {
        super.init(bufferWidth: width * 6 + 2, bufferHeight: height * 3 + 2)
    }

    /// Initializes a grid printer with a buffer capable of rendering the given
    /// grid with each cell has 6 characters of width and 3 of height.
    public convenience init(bufferForGrid grid: Grid) {
        self.init(bufferForGridWidth: grid.columns, height: grid.rows)
    }

    public func printGrid(grid: Grid) {
        resetBuffer()
        let availableWidth = bufferWidth - 2
        let availableHeight = bufferHeight - 2

        // Create a graph for querying purposes when drawing connection information
        let graph = GridGraph.fromGrid(grid, connectionMode: .connectedToProperty)
        let labelGen = LabelGenerator()
        labelGen.prepare(with: grid, graph: graph)

        putRect(x: 0, y: 0, w: availableWidth, h: availableHeight)

        let cellWidth = availableWidth / grid.columns
        let cellHeight = availableHeight / grid.rows

        for y in 0..<grid.rows {
            for x in 0..<grid.columns {
                let node = GridGraph.Node(column: x, row: y)
                let hasPreviousConnection = graph.edges(towards: node).count > 0

                printTile(
                    grid[column: x, row: y],
                    x: x * cellWidth,
                    y: y * cellHeight,
                    width: cellWidth,
                    height: cellHeight,
                    hasPreviousConnection: hasPreviousConnection,
                    label: labelGen.labelForNode(node, on: grid)
                )
            }
        }

        joinBoxLines()
        print()
    }

    private func printTile(
        _ tile: Tile,
        x: Int,
        y: Int,
        width: Int,
        height: Int,
        hasPreviousConnection: Bool,
        label: String?
    ) {
        // Draw surrounding tile lines
        putRect(x: x, y: y, w: width, h: height)

        // Draw tile number, if available
        if let solution = tile.solution?.description ?? label {
            putString(solution, x: x + 2, y: y + 1)
        }
        if !tile.isStartTile && !hasPreviousConnection {
            put("•", x: x + 2, y: y + height - 1)
        }

        // Draw orientation arrow or star, for end tile
        let orientationIcon: UnicodeScalar

        if tile.isEndTile {
            orientationIcon = "*"
        } else {
            switch tile.orientation {
            case .north:
                orientationIcon = "↑"

            case .northEast:
                orientationIcon = "↗"

            case .east:
                orientationIcon = "→"

            case .southEast:
                orientationIcon = "↘"

            case .south:
                orientationIcon = "↓"

            case .southWest:
                orientationIcon = "↙"

            case .west:
                orientationIcon = "←"

            case .northWest:
                orientationIcon = "↖"
            }
        }

        put(orientationIcon, x: x + width - 2, y: y + height - 1)
    }

    private class LabelGenerator {
        private var subsequences: [NodeSequence] = []

        func prepare(with grid: Grid, graph: GridGraph) {
            let seq =
                graph.subgraphs()
                .sorted { $0.nodes[0] < $1.nodes[0] } // Stabilize output
                .filter { $0.nodes.count > 1 }
                .compactMap {
                    $0.topologicalSorted()?
                        .map {
                            NodeSequence.NodeEntry(
                                label: "",
                                node: $0,
                                tile: grid[$0.coordinates]
                            )
                        }
                }
            
            // Add a letter label for each sequence, starting from [a, b, c, ...]
            subsequences =
                seq
                .enumerated()
                .compactMap {
                    guard let letter = UnicodeScalar(ascii(for: "a") + $0.offset) else {
                        return nil
                    }

                    return .init(label: letter.description, nodes: $0.element)
                }
            
            // Go back into the sequences and label each node within according
            // to the first letter of the sequence + a numerical index.
            for subsequence in subsequences {
                var index: Int = 0
                for entry in subsequence.nodes {
                    defer { index += 1 }

                    guard entry.tile.solution == nil else { continue }

                    if index == 0 {
                        subsequence.nodes[index].label = subsequence.label
                    } else {
                        subsequence.nodes[index].label = "\(subsequence.label)+\(index)"
                    }
                }
            }
        }

        // Enable labeling support for subgraphs
        func labelForNode(_ node: GridGraph.Node, on grid: Grid) -> String? {
            if let number = grid.effectiveNumberForTile(column: node.column, row: node.row) {
                return number.description
            }

            for subsequence in subsequences {
                for entry in subsequence.nodes {
                    if entry.node == node {
                        return entry.label
                    }
                }
            }

            return nil
        }

        private func ascii(for char: UnicodeScalar) -> Int {
            return Int(char.value)
        }

        private class NodeSequence {
            var label: String
            var nodes: [NodeEntry]

            internal init(label: String, nodes: [NodeEntry] = []) {
                self.label = label
                self.nodes = nodes
            }

            struct NodeEntry {
                var label: String
                var node: GridGraph.Node
                var tile: Tile
            }
        }
    }
}
