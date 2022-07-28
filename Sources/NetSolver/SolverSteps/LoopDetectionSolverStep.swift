/// Solver step that checks for potential loops that can be formed by joining
/// ends of bifurcated locked networks with surrounding unlocked tiles
struct LoopDetectionSolverStep: NetSolverStep {
    func apply(on grid: Grid, delegate: NetSolverDelegate) -> [GridAction] {
        let networks = delegate.lockedTileNetworks()

        var actions: [GridAction] = []

        for network in networks {
            actions.append(contentsOf: analyzeNetwork(network, grid: grid, delegate: delegate))
        }

        return actions
    }

    func analyzeNetwork(
        _ network: Network,
        grid: Grid,
        delegate: NetSolverDelegate
    ) -> [GridAction] {
        var result: [GridAction] = []

        // Fetch all open ports on this network
        let openPorts = Array(network.openPorts(onGrid: grid))

        // At least two open ports are required
        guard openPorts.count >= 2 else {
            return []
        }

        // Map the open ports to tiles on the grid
        let tiles: [OpenPortTile] = openPorts.flatMap { openPort in
            openPort.ports.map {
                let coordinate = grid.columnRowByMoving(
                    column: openPort.column,
                    row: openPort.row,
                    direction: $0
                )

                let tile = grid[row: coordinate.row, column: coordinate.row]

                return OpenPortTile(
                    column: coordinate.column,
                    row: coordinate.row,
                    ports: tile.ports,
                    originTile: openPort
                )
            }
        }.sorted(by: {
            // Sort by column/row to make results deterministic for testing
            Network.Coordinate.isEarlierInTopBottomLeftRightSweep($0.coordinate, $1.coordinate)
        })

        // Look for neighbors to check for loops
        for i in 0..<(tiles.count - 1) {
            let tile1 = tiles[i]

            for j in (i + 1)..<tiles.count {
                let tile2 = tiles[j]

                if grid.areNeighbors(
                    atColumn1: tile1.column,
                    row1: tile1.row,
                    column2: tile2.column,
                    row2: tile2.row
                ) {

                    let actions =
                        analyzeNeighbors(tile1, tile2, onGrid: grid, delegate: delegate)

                    result.append(contentsOf: actions)
                }
            }
        }

        return result
    }

    func analyzeNeighbors(
        _ tile1: OpenPortTile,
        _ tile2: OpenPortTile,
        onGrid grid: Grid,
        delegate: NetSolverDelegate
    ) -> [GridAction] {

        let gridTile1 = grid.tile(fromCoordinate: tile1.coordinate)
        let gridTile2 = grid.tile(fromCoordinate: tile2.coordinate)

        // Loop detection can only occur between T or L tiles
        guard gridTile1.kind == .T || gridTile1.kind == .L else {
            return []
        }
        guard gridTile2.kind == .T || gridTile2.kind == .L else {
            return []
        }

        // Find port from first tile that points to second tile
        guard
            let tile1PortToTile2 = grid.edgePort(
                from: (tile1.column, tile1.row),
                to: (tile2.column, tile2.row)
            )
        else {
            return []
        }

        let tile1Orientations =
            delegate.possibleOrientationsForTile(
                atColumn: tile1.column,
                row: tile1.row
            )

        let tile1OrientationsToTile2 = gridTile1.orientations(includingPorts: [tile1PortToTile2])

        // Narrow orientations to remove by only checking against the set of
        // currently possible orientations
        let orientationsToRemove = tile1OrientationsToTile2.intersection(tile1Orientations)

        return [
            .markImpossibleOrientations(
                column: tile1.column,
                row: tile1.row,
                orientationsToRemove
            )
        ]
    }

    /// Represents the tile that an open port on a network points to
    struct OpenPortTile {
        var coordinate: Network.Coordinate

        /// Represents the tile from the original network that point to this
        /// open port tile
        var originTile: Network.Coordinate

        var column: Int {
            return coordinate.column
        }
        var row: Int {
            return coordinate.row
        }
        var ports: Set<EdgePort> {
            return coordinate.ports
        }

        init(coordinate: Network.Coordinate, originTile: Network.Coordinate) {
            self.coordinate = coordinate
            self.originTile = originTile
        }

        init(column: Int, row: Int, ports: Set<EdgePort>, originTile: Network.Coordinate) {
            self.coordinate = .init(column: column, row: row, ports: ports)
            self.originTile = originTile
        }
    }
}
