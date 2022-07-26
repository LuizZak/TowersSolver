import Commons

/// A solver for a Signpost game
public class Solver {
    private(set) public var grid: Grid

    private var connectionsGridGraph: GridGraph
    private var solutionGridGraph: GridGraph

    /// Returns `true` if the for this solver is in a valid state and solved.
    ///
    /// For a Signpost grid, the grid is valid and solved when all conditions
    /// apply:
    ///
    /// - 1- All tiles are numbered, from 1 to `grid.tileCount`, with each number
    /// showing up exactly once.
    /// - 2- Each numbered tile N, except for the hightest tile number, must have
    /// its subsequent tile numbered N+1 in the direction of its arrow in the
    /// grid.
    public var isSolved: Bool {
        _isSolved()
    }

    public init(grid: Grid) {
        self.grid = grid

        connectionsGridGraph = .fromGrid(grid)
        solutionGridGraph = .fromGrid(grid, connectionMode: .connectedToProperty)

        _preprocessConnectionsGraph()
    }

    private func _preprocessConnectionsGraph() {
        // Run through the input grid, ensuring sequential numbered tiles from
        // the input are exclusively connected to one another to reduce search
        // spaces later on
        for tileCoord in grid.tileCoordinates {
            let tile = grid[tileCoord]

            guard let solution = tile.solution else {
                continue
            }

            let nextCoords = grid.tileCoordsPointedBy(column: tileCoord.column, row: tileCoord.row)

            for next in nextCoords {
                let nextTile = grid[next]

                if nextTile.solution == solution + 1 {
                    _=_exclusiveConnect(start: .init(tileCoord), end: .init(next))
                    break
                }
            }
        }
    }

    public func solve() {
        defer { _postSolve() }

        func trivialSolverStep() -> Bool {
            var changesCount = 0

            var didChange = false
            repeat {
                didChange = false

                // Connect tiles that have only one entry/exit edge
                for node in connectionsGridGraph.nodes {
                    let from = _possibleNodesFrom(node: node)
                    let to = _possibleNodesTo(node: node)

                    if from.count == 1 {
                        let start = node
                        let end = from[0]
                        
                        didChange = didChange || _exclusiveConnect(start: start, end: end)
                    }
                    if to.count == 1 {
                        let start = to[0]
                        let end = node

                        didChange = didChange || _exclusiveConnect(start: start, end: end)
                    }
                }

                if didChange {
                    changesCount += 1
                }
            } while didChange

            return changesCount > 0
        }

        func complexSolverStep() -> Bool {
            var changesCount = 0

            var didChange = false
            repeat {
                didChange = false

                let pairs = _collectNumberedPairs()

                for pair in pairs {
                    didChange = didChange || _evaluatePathsBetween(numberedPair: pair)
                }

                if didChange {
                    changesCount += 1
                }
            } while didChange

            return changesCount > 0
        }

        // Do a pre-pass of the grid to detect obvious connections
        while trivialSolverStep() && complexSolverStep() {

        }
    }

    private func _evaluatePathsBetween(numberedPair: NumberedPair) -> Bool {
        let startTile = numberedPair.start
        let endTile = numberedPair.end

        // Number of nodes expected to be contained within the path between the
        // numbered pair. Is +1 to account for the start/end nodes themselves.
        let targetLength = numberedPair.endNumber - numberedPair.startNumber + 1

        let paths = connectionsGridGraph
            .allPaths(from: startTile, to: endTile) { visit in
                if visit.length > targetLength {
                    return false
                }

                switch visit {
                case .start:
                    return true

                case .edge(_, let from, let towards):
                    if towards == endTile && visit.length != targetLength {
                        return false
                    }

                    guard let toNum = grid.effectiveNumberForTile(towards.coordinates) else {
                        break
                    }

                    if let fromNum = grid.effectiveNumberForTile(from.node.coordinates), fromNum + 1 != toNum {
                        return false
                    }

                    // Find earliest number in the sequence, and ensure that the
                    // solution number on the next tile matches the sequence
                    // properly
                    guard let lastNumberedIndex = from.allNodes.lastIndex(where: { grid.effectiveNumberForTile($0.coordinates) != nil }) else {
                        return false
                    }
                    let lastNumbered = from.allNodes[lastNumberedIndex]

                    guard let lastNumber = grid.effectiveNumberForTile(lastNumbered.coordinates) else {
                        return false
                    }

                    let diff = from.allNodes.count - lastNumberedIndex

                    if lastNumber + diff != toNum {
                        return false
                    }
                }

                return true
            }
            .filter {
                $0.count == targetLength
            }
        
        // Numbers can only be connected if there are no ambiguous paths between
        // them
        if paths.count != 1 {
            return false
        }

        var changed = false
        outerLoop:
        for path in paths {
            for (i, node) in path.enumerated() {
                let tile = grid[node.coordinates]

                if let solution = tile.solution, solution != i + numberedPair.startNumber {
                    continue outerLoop
                }
            }

            for (node, next) in zip(path, path.dropFirst()) {
                changed = changed || _exclusiveConnect(start: node, end: next)
            }
        }

        return changed
    }

    /// Exclusively connects two nodes, returning whether the connection was made.
    ///
    /// - returns: `false` if the nodes where already previously connected on the
    /// internal grid state, `true` if they where not and a connection was made.
    private func _exclusiveConnect(start: GridGraph.Node, end: GridGraph.Node) -> Bool {
        solutionGridGraph.connectExclusive(start: start, end: end)
        connectionsGridGraph.connectExclusive(start: start, end: end)
        
        if grid[start.coordinates].connectionState == .connectedTo(column: end.column, row: end.row) {
            return false
        }

        grid[start.coordinates].connectedTo = end.coordinates

        return true
    }

    /// Returns a list of potential paths that can be connected from a given node.
    /// The function ignores nodes in the path of `node` that are either already
    /// exclusively connected to other nodes, or are already connected to `node`
    /// via an ancestor.
    private func _possibleNodesFrom(node: GridGraph.Node) -> [GridGraph.Node] {
        if grid.tileConnectedFrom(column: node.column, row: node.row) != nil {
            return []
        }
        
        let subgraph = solutionGridGraph.subgraph(forNode: node)
        var nodes = connectionsGridGraph.nodesConnected(from: node)

        let solution = grid.effectiveNumberForTile(column: node.column, row: node.row)

        for (i, next) in nodes.enumerated().reversed() {
            if grid.tileConnectedTo(column: next.column, row: next.row) != nil {
                continue
            }
            
            // Exclude nodes in the same subgraph
            if subgraph.nodes.contains(next) {
                nodes.remove(at: i)
            }

            // Exclude numbered nodes that cannot directly connect to one another
            let nextSolution = grid.effectiveNumberForTile(column: next.column, row: next.row)

            switch (solution, nextSolution) {
            case (let solution?, let nextSolution?):
                if nextSolution != solution + 1 {
                    nodes.remove(at: i)
                }
            default:
                break
            }
        }

        return nodes
    }

    /// Returns a list of potential paths that can be connected towards a given node.
    /// The function ignores nodes in the path of `node` that are either already
    /// exclusively connected to other nodes, or are already connected to `node`
    /// via a successor node.
    private func _possibleNodesTo(node: GridGraph.Node) -> [GridGraph.Node] {
        if grid.tileConnectedFrom(column: node.column, row: node.row) != nil {
            return []
        }

        let subgraph = solutionGridGraph.subgraph(forNode: node)
        var nodes = connectionsGridGraph.nodesConnected(towards: node)

        let solution = grid.effectiveNumberForTile(column: node.column, row: node.row)

        for (i, prev) in nodes.enumerated().reversed() {
            if grid.tileConnectedFrom(column: prev.column, row: prev.row) != nil {
                continue
            }

            if subgraph.nodes.contains(prev) {
                nodes.remove(at: i)
            }

            // Exclude numbered nodes that cannot directly connect to one another
            let prevSolution = grid.effectiveNumberForTile(column: prev.column, row: prev.row)

            switch (solution, prevSolution) {
            case (let solution?, let prevSolution?):
                if solution != prevSolution + 1 {
                    nodes.remove(at: i)
                }
            default:
                break
            }
        }

        return nodes
    }

    private func _printGraphViz(_ graph: GridGraph) {
        func _nodeLabel(_ node: GridGraph.Node) -> String {
            "(\(node.column), \(node.row))"
        }

        let viz = GraphViz()

        for node in graph.nodes {
            let label = _nodeLabel(node)

            viz.createNode(label: label)
        }

        for edge in graph.edges {
            let labelStart = _nodeLabel(edge.start)
            let labelEnd = _nodeLabel(edge.end)

            viz.addConnection(fromLabel: labelStart, toLabel: labelEnd)
        }

        print(viz.generateFile())
    }

    private func _postSolve() {
        for tileCoord in grid.tileCoordinates {
            guard grid[tileCoord].connectedTo == nil else {
                continue
            }
            
            guard let number = grid.effectiveNumberForTile(column: tileCoord.column, row: tileCoord.row) else {
                continue
            }

            let nextCoords = grid.tileCoordsPointedBy(column: tileCoord.column, row: tileCoord.row)

            for next in nextCoords {
                if grid.effectiveNumberForTile(column: next.column, row: next.row) == number + 1 {
                    solutionGridGraph.connect(start: .init(tileCoord), end: .init(next))
                    grid[tileCoord].connectionState = .connectedTo(column: next.column, row: next.row)
                    break
                }
            }
        }
    }

    private func _isSolved() -> Bool {
        let startTileCoord = grid.tileCoordinates.first {
            grid[$0].isStartTile && grid[$0].solution == 1
        }
        let endTileCoord = grid.tileCoordinates.first {
            grid[$0].isEndTile && grid[$0].solution == grid.tileCount
        }

        guard let startTileCoord = startTileCoord, let endTileCoord = endTileCoord else {
            return false
        }

        let resultGraph = GridGraph.fromGrid(grid, connectionMode: .connectedToProperty)

        let paths = resultGraph.allPaths(from: .init(startTileCoord), to: .init(endTileCoord), confirmVisit: { _ in true })

        if paths.count != 1 {
            return false
        }

        let path = paths[0]

        var current = 1
        
        for node in path {
            let tile = grid[node.coordinates]

            if let solution = tile.solution, solution != current {
                return false
            }

            current += 1
        }
        
        return true
    }

    /// Returns a list of numbered pairs which represent gaps between known
    /// signpost numbers, ordered from lowest to highest.
    private func _collectNumberedPairs() -> [NumberedPair] {
        // Collect static number solutions to visit
        var candidates: [(node: GridGraph.Node, number: Int)] = []
        for tileCoord in grid.tileCoordinates {
            guard let number = grid[tileCoord].solution else {
                continue
            }

            candidates.append((.init(tileCoord), number))
        }

        candidates.sort { $0.number < $1.number }
        
        var endOfLastRun: (node: GridGraph.Node, number: Int)?
        var result: [NumberedPair] = []

        // Check each pre-filled number, visiting each subsequent connected node
        // and storing the last node in the run.
        // The run is used in the next pre-filled number to indicate a path must
        // be found between them.
        // If two or more pre-filled numbers are part of the same run of
        // connected tiles, they are treated as one tile run.
        while !candidates.isEmpty {
            let candidate = candidates.removeFirst()

            if let endOfLastRun = endOfLastRun {
                result.append(
                    .init(start: endOfLastRun.node, startNumber: endOfLastRun.number, end: candidate.node, endNumber: candidate.number)
                )
            }

            if candidates.isEmpty {
                break
            }

            var counter = 0
            var next = candidate.node.coordinates
            while let n = grid.tileConnectedFrom(next) {
                if case (n.column, n.row)? = candidates.first?.node.coordinates {
                    candidates.removeFirst()
                }

                counter += 1

                next = n
            }

            endOfLastRun = (.init(next), candidate.number + counter)
        }

        return result
    }

    /// Represents a pair of tiles, both of which have proper signpost numbers
    /// associated with them.
    ///
    /// Used to find paths between gaps of signpost sequences.
    private struct NumberedPair: CustomStringConvertible {
        var start: GridGraph.Node
        var startNumber: Int

        var end: GridGraph.Node
        var endNumber: Int

        var description: String {
            "\(start): \(startNumber), \(end): \(endNumber)"
        }
    }
}
