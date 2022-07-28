/// Represents a sub-network in a Net grid.
/// Contains the tiles that form the network, along with their ports at the time
/// of creation.
struct Network: Equatable {
    var tiles: Set<Coordinate>

    /// Returns `true` if this network contains a tile for a given column/row
    /// combination.
    func hasTile(forColumn column: Int, row: Int) -> Bool {
        return tile(forColumn: column, row: row) != nil
    }

    /// Returns `true` if this network contains a tile that neighbors a tile at
    /// the given column/row, with the given port available pointing towards it.
    ///
    /// The provided grid is used to perform grid wrapping and check for barriers.
    func hasConnection(
        toColumn column: Int,
        row: Int,
        port: EdgePort,
        onGrid grid: Grid
    ) -> Bool {

        let barriers = grid.barriersForTile(atColumn: column, row: row)
        if barriers.contains(port) {
            // If a barrier is present at the requested edge, it cannot be
            // connected with a tile from this network.
            return false
        }

        let neighbor = grid.columnRowByMoving(column: column, row: row, direction: port)
        if let tile = self.tile(forColumn: neighbor.column, row: neighbor.row),
            tile.ports.contains(port.opposite)
        {
            return true
        }

        return false
    }

    /// Returns `true` if this network represents a closed network, where all
    /// tiles have ports that only connect to other tiles on this same network.
    ///
    /// The provided grid is used to perform grid wrapping.
    func isClosed(onGrid grid: Grid) -> Bool {
        for tile in tiles {
            let barriers = grid.barriersForTile(atColumn: tile.column, row: tile.row)

            for port in tile.ports {
                if barriers.contains(port) {
                    return false
                }

                let coord =
                    grid.columnRowByMoving(
                        column: tile.column,
                        row: tile.row,
                        direction: port
                    )

                if !hasTile(forColumn: coord.column, row: coord.row) {
                    return false
                }
            }
        }

        return true
    }

    /// Returns `true` if the tiles in this network form any loops.
    /// The provided grid is used to perform grid wrapping.
    func hasLoops(onGrid grid: Grid) -> Bool {
        let subNetworks = splitNetwork(onGrid: grid)

        return subNetworks.contains(where: { $0._internalHasLoops(onGrid: grid) })
    }

    /// Returns `true` if this network has the same set of tiles than the given
    /// grid.
    /// If any of the tiles is out-of-bounds on the given grid, `false` is returned.
    /// Only tile coordinates are checked, current tile ports are ignored.
    func isCompleteNetwork(ofGrid grid: Grid) -> Bool {
        if tiles.count != grid.tileCount {
            return false
        }

        return tiles.allSatisfy { grid.isWithinBounds(column: $0.column, row: $0.row) }
    }

    private func _internalHasLoops(onGrid grid: Grid) -> Bool {
        if tiles.isEmpty {
            return false
        }

        var visited: Set<Coordinate> = []
        var toCheck: [(Coordinate, incomingPort: EdgePort?)] = [(Array(tiles)[0], nil)]

        // Checks a tile into the tilesToCheck array in case it has a given port
        // available and is locked. Returns `true` if the tile has been checked
        // before, signaling a loop.
        func checkTile(_ x: Int, _ y: Int, port: EdgePort) -> Bool {
            guard let tile = self.tile(forColumn: x, row: y) else {
                return false
            }

            // Check for loops
            guard !visited.contains(tile) else {
                return true
            }

            if tile.ports.contains(port) {
                toCheck.append((tile, port))
            }

            return false
        }

        while !toCheck.isEmpty {
            let current = toCheck.removeFirst()
            defer { visited.insert(current.0) }

            let barriers = grid.barriersForTile(atColumn: current.0.column, row: current.0.row)

            // Check in all four directions if a tile with a matching port
            // is connected with an available port on the tile
            for port in current.0.ports
            where port != current.incomingPort && !barriers.contains(port) {
                let next = grid.columnRowByMoving(
                    column: current.0.column,
                    row: current.0.row,
                    direction: port
                )

                if checkTile(next.column, next.row, port: port.opposite) {
                    return true
                }
            }
        }

        return false
    }

    /// Returns a set of tile coordinates from this network that have ports that
    /// do not connect to another tile from this network.
    ///
    /// The resulting set represents the coordinates for tiles that are
    /// unconnected, where ``Coordinate.ports`` maps which ports of the tile are
    /// unconnected.
    ///
    /// The provided grid is used to perform grid wrapping.
    func openPorts(onGrid grid: Grid) -> Set<Coordinate> {
        var result: Set<Coordinate> = []

        for tile in tiles {
            var ports: Set<EdgePort> = []

            let barriers = grid.barriersForTile(atColumn: tile.column, row: tile.row)

            ports.formUnion(barriers.intersection(tile.ports))

            for port in tile.ports where !barriers.contains(port) {
                let coord =
                    grid.columnRowByMoving(
                        column: tile.column,
                        row: tile.row,
                        direction: port
                    )

                if !hasTile(forColumn: coord.column, row: coord.row) {
                    ports.insert(port)
                }
            }

            if !ports.isEmpty {
                result.insert(Coordinate(column: tile.column, row: tile.row, ports: ports))
            }
        }

        return result
    }

    /// Attempts to split this network into its subcomponents, composed of smaller
    /// subsets of tiles from this network which are connected by ports.
    ///
    /// If this network is indivisible, the resulting array has length 1, and if
    /// this network is empty, the result is empty as well.
    ///
    /// The provided grid is used to perform grid wrapping.
    func splitNetwork(onGrid grid: Grid) -> [Network] {
        var copy = self
        var result: [Network] = []

        while let next = copy.tiles.first {
            let connected = Network.allConnectedStartingFrom(
                column: next.column,
                row: next.row,
                onNetwork: copy,
                onGrid: grid
            )

            copy.tiles.subtract(connected.tiles)

            result.append(connected)
        }

        return result
    }

    /// Attempts to join this network with another, returning a single connected
    /// network.
    ///
    /// If there are no connections between any of the network tiles via tile
    /// ports, `nil` is returned, instead.
    /// If one or more tile coordinates are shared between the two networks, the
    /// result is a single Network containing both tile lists.
    ///
    /// Barriers on the grid prevent networks from being joined.
    ///
    /// The provided grid is used to perform grid wrapping.
    func attemptJoin(other: Network, onGrid grid: Grid) -> Network? {
        func flushList() -> Network {
            let list = Self.removeDuplicates(from: Array(tiles) + Array(other.tiles), grid: grid)

            return Network(tiles: list)
        }

        for tile in tiles {
            if other.hasTile(forColumn: tile.column, row: tile.row) {
                return flushList()
            }

            for port in tile.ports {
                guard
                    other.hasConnection(
                        toColumn: tile.column,
                        row: tile.row,
                        port: port,
                        onGrid: grid
                    )
                else {
                    continue
                }

                return flushList()
            }
        }

        return nil
    }

    private func tile(forColumn column: Int, row: Int) -> Coordinate? {
        return tiles.first(where: { $0.column == column && $0.row == row })
    }

    private static func removeDuplicates(from list: [Coordinate], grid: Grid) -> Set<Coordinate> {
        var result: Set<Coordinate> = []

        for item in list where !result.contains(item) {
            if item.column >= grid.columns || item.row >= grid.rows {
                result.insert(item)
                continue
            }

            let tile = grid[column: item.column, row: item.row]
            result.insert(Coordinate(column: item.column, row: item.row, ports: tile.ports))
        }

        return result
    }

    struct Coordinate: Hashable {
        var column: Int
        var row: Int
        var ports: Set<EdgePort>

        func hash(into hasher: inout Hasher) {
            hasher.combine(column)
            hasher.combine(row)
        }
    }
}

extension Network {
    /// Creates a network from the given list of coordinates, fetching information
    /// about tile ports from the provided grid.
    static func fromCoordinates(onGrid grid: Grid, _ coordinates: [(column: Int, row: Int)])
        -> Network
    {
        var result = Network(tiles: [])

        for coord in coordinates {
            let tile = grid[column: coord.column, row: coord.row]

            let netCoord = Coordinate(column: coord.column, row: coord.row, ports: tile.ports)
            result.tiles.insert(netCoord)
        }

        return result
    }

    /// Creates a single network that is formed out of all the tiles of a grid.
    /// The resulting network may contain unconnected sub-networks, if they are
    /// present in the underlying grid.
    static func fromGrid(_ grid: Grid) -> Network {
        var network = Network(tiles: [])

        for row in 0..<grid.rows {
            for column in 0..<grid.columns {
                let tile = grid[column: column, row: row]

                network.tiles.insert(Coordinate(column: column, row: row, ports: tile.ports))
            }
        }

        return network
    }

    /// Creates a list of networks formed by the currently locked tiles on a grid.
    static func fromLockedTiles(onGrid grid: Grid) -> [Network] {
        var network = Network(tiles: [])

        for row in 0..<grid.rows {
            for column in 0..<grid.columns {
                let tile = grid[column: column, row: row]
                guard tile.isLocked else {
                    continue
                }

                network.tiles.insert(Coordinate(column: column, row: row, ports: tile.ports))
            }
        }

        return network.splitNetwork(onGrid: grid)
    }

    /// Creates a network by spanning all connected tiles starting from a tile
    /// at a given column/row combination.
    ///
    /// Barriers are taking into consideration when traversing the grid.
    static func allConnectedStartingFrom(column: Int, row: Int, onGrid grid: Grid) -> Network {
        var tiles: Set<Coordinate> = []
        var queue: [(column: Int, row: Int)] = [(column, row)]

        while !queue.isEmpty {
            let current = queue.removeFirst()

            if tiles.contains(where: { ($0.column, $0.row) == current }) {
                continue
            }

            let tile = grid[column: current.column, row: current.row]
            let barriers = grid.barriersForTile(atColumn: current.column, row: current.row)

            tiles.insert(Coordinate(column: current.column, row: current.row, ports: tile.ports))

            for port in tile.ports where !barriers.contains(port) {
                let neighbor = grid.columnRowByMoving(
                    column: current.column,
                    row: current.row,
                    direction: port
                )
                let neighborPorts = grid[column: neighbor.column, row: neighbor.row]

                if neighborPorts.ports.contains(port.opposite) {
                    queue.append(neighbor)
                }
            }
        }

        return Network(tiles: tiles)
    }

    /// Creates a network by spanning all connected tiles starting from a tile
    /// at a given column/row combination on a given Network.
    ///
    /// The resulting Network only spans as far as the connected tiles within
    /// the provided Network, not skipping gaps for tiles that are missing but
    /// connected on the underlying grid.
    ///
    /// Barriers are taking into consideration when traversing the grid.
    static func allConnectedStartingFrom(
        column: Int,
        row: Int,
        onNetwork network: Network,
        onGrid grid: Grid
    ) -> Network {

        guard let start = network.tile(forColumn: column, row: row) else {
            return Network(tiles: [])
        }

        var tiles: Set<Coordinate> = []
        var queue: [Coordinate] = [start]

        while !queue.isEmpty {
            let current = queue.removeFirst()
            if !tiles.insert(current).inserted {
                continue
            }

            let barriers = grid.barriersForTile(atColumn: current.column, row: current.row)

            for port in current.ports where !barriers.contains(port) {
                let neighbor = grid.columnRowByMoving(
                    column: current.column,
                    row: current.row,
                    direction: port
                )

                if let next = network.tile(forColumn: neighbor.column, row: neighbor.row) {
                    if next.ports.contains(port.opposite) {
                        queue.append(next)
                    }
                }
            }
        }

        return Network(tiles: tiles)
    }
}

extension Network.Coordinate {
    /// Returns `true` if `coord1` comes first in a top-bottom/left-right sweep
    /// of the grid compared to `coord2`, `false` otherwise.
    ///
    /// Used to sort coordinates according to a top-bottom/left-right sweep of
    /// the grid.
    static func isEarlierInTopBottomLeftRightSweep(_ coord1: Self, _ coord2: Self) -> Bool {
        if coord1.row < coord2.row {
            return true
        }
        if coord1.row == coord2.row {
            if coord1.column < coord2.column {
                return true
            }
        }

        return false
    }
}
