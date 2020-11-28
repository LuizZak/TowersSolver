/// Represents a sub-network in a Net grid.
/// Contains the tiles that form the network, along with their ports at the time
/// of creation.
struct Network {
    var tiles: [Coordinate]
    
    /// Returns `true` if this network contains a tile for a given column/row
    /// combination.
    func hasTile(forColumn column: Int, row: Int) -> Bool {
        return tile(forColumn: column, row: row) != nil
    }
    
    /// Returns `true` if this network represents a closed network, where all
    /// tiles have ports that only connect to other tiles on this same network.
    /// The provided grid is used to perform grid wrapping.
    func isClosed(onGrid grid: Grid) -> Bool {
        for tile in tiles {
            for port in tile.ports {
                let coord =
                    grid.columnRowByMoving(column: tile.column,
                                           row: tile.row,
                                           direction: port)
                
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
        var remaining = Self.removeDuplicates(from: tiles, grid: grid)
        if remaining.count != grid.tileCount {
            return false
        }
        
        while let next = remaining.popLast() {
            if next.column >= grid.columns || next.row >= grid.rows {
                return false
            }
        }
        
        return true
    }
    
    private func _internalHasLoops(onGrid grid: Grid) -> Bool {
        var visited: [Coordinate] = []
        var toCheck: [(Coordinate, incomingPort: EdgePort?)] = [(tiles[0], nil)]
        
        // Checks a tile into the tilesToCheck array in case it has a given port
        // available and is locked. Returns `true` if the tile has been checked
        // before, signaling a loop.
        func checkTile(_ x: Int, _ y: Int, port: EdgePort) -> Bool {
            guard let tile = self.tile(forColumn: x, row: y) else {
                return false
            }
            guard x >= 0 && x < grid.columns && y >= 0 && y < grid.rows else {
                return false
            }
            
            // Check for loops
            guard !visited.contains(where: { ($0.column, $0.row) == (x, y) }) else {
                return true
            }
            
            if tile.ports.contains(port) {
                toCheck.append((tile, port))
            }
            
            return false
        }
        
        while !toCheck.isEmpty {
            let current = toCheck.removeFirst()
            defer { visited.append(current.0) }
            
            let barriers = grid.barriersForTile(atColumn: current.0.column, row: current.0.row)
            
            // Check in all four directions if a tile with a matching port
            // is connected with an available port on the tile
            for port in current.0.ports where port != current.incomingPort && !barriers.contains(port) {
                let next
                    = grid.columnRowByMoving(column: current.0.column,
                                             row: current.0.row,
                                             direction: port)
                
                if checkTile(next.column, next.row, port: port.opposite) {
                    return true
                }
            }
        }
        
        return false
    }
    
    /// Attempts to split this network into its subcomponents, composed of smaller
    /// subsets of tiles from this network which are connected by ports.
    ///
    /// If this network is indivisible, the resulting array has length 1, and if
    /// this network is empty, the result is empty as well.
    ///
    /// The provided grid is used to perform grid wrapping.
    func splitNetwork(onGrid grid: Grid) -> [Network] {
        // Split networks
        let networks: [Network] = tiles.map({ Network.fromCoordinates(onGrid: grid, [($0.column, $0.row)]) })
        var result: [Network] = []
        
        outerLoop: for next in networks {
            for index in 0..<result.count {
                if let joined = result[index].attemptJoin(other: next, onGrid: grid) {
                    result[index] = joined
                    continue outerLoop
                }
            }
            
            result.append(next)
        }
        
        return result
    }
    
    /// Attempts to join this network with another, returning a single connected
    /// network.
    ///
    /// If there are no connections between any of the network tiles via tile
    /// ports, `nil` is returned, instead.
    /// If one or more tile coordinates are shared between the two networks, the
    /// result is a Network containing both tile lists, joined or not.
    ///
    /// Barriers on the grid prevent networks from being joined.
    ///
    /// The provided grid is used to perform grid wrapping.
    func attemptJoin(other: Network, onGrid grid: Grid) -> Network? {
        func flushList() -> Network {
            let list = Self.removeDuplicates(from: tiles + other.tiles, grid: grid)
            
            return Network(tiles: list)
        }
        
        for tile in tiles {
            if other.hasTile(forColumn: tile.column, row: tile.row) {
                return flushList()
            }
            
            for port in tile.ports {
                if grid.barriersForTile(atColumn: tile.column, row: tile.row).contains(port) {
                    continue
                }
                
                let neighbor = grid.columnRowByMoving(column: tile.column, row: tile.row, direction: port)
                if other.hasTile(forColumn: neighbor.column, row: neighbor.row) {
                    return flushList()
                }
            }
        }
        
        return nil
    }
    
    private func tile(forColumn column: Int, row: Int) -> Coordinate? {
        return tiles.first(where: { $0.column == column && $0.row == row })
    }
    
    private static func removeDuplicates(from list: [Coordinate], grid: Grid) -> [Coordinate] {
        var result: [Coordinate] = []
        
        for item in list where !result.contains(where: { $0.column == item.column && $0.row == item.row }) {
            if item.column >= grid.columns || item.row >= grid.rows {
                result.append(item)
                continue
            }
            
            let tile = grid[row: item.row, column: item.column]
            result.append(Coordinate(column: item.column, row: item.row, ports: tile.ports))
        }
        
        return result
    }
    
    struct Coordinate: Hashable {
        var column: Int
        var row: Int
        var ports: Set<EdgePort>
    }
}

extension Network {
    /// Creates a network from the given list of coordinates, fetching information
    /// about tile ports from the provided grid.
    static func fromCoordinates(onGrid grid: Grid, _ coordinates: [(column: Int, row: Int)]) -> Network {
        var result = Network(tiles: [])
        
        for coord in coordinates {
            let tile = grid[row: coord.row, column: coord.column]
            
            let netCoord = Coordinate(column: coord.column, row: coord.row, ports: tile.ports)
            result.tiles.append(netCoord)
        }
        
        return result
    }
    
    /// Creates a list of networks formed by the currently locked tiles on a grid.
    static func fromLockedTiles(onGrid grid: Grid) -> [Network] {
        var network = Network(tiles: [])
        
        for row in 0..<grid.rows {
            for column in 0..<grid.columns {
                let tile = grid[row: row, column: column]
                
                if tile.isLocked {
                    network.tiles.append(Coordinate(column: column, row: row, ports: tile.ports))
                }
            }
        }
        
        return network.splitNetwork(onGrid: grid)
    }
    
    /// Creates a network by spanning all connected tiles starting from a tile
    /// at a given column/row combination.
    ///
    /// Barriers are taking into consideration when traversing the grid.
    static func allConnectedStartingFrom(column: Int, row: Int, onGrid grid: Grid) -> Network {
        var tiles: [Coordinate] = []
        var queue: [(column: Int, row: Int)] = [(column, row)]
        
        while !queue.isEmpty {
            let current = queue.removeLast()
            
            if tiles.contains(where: { ($0.column, $0.row) == current }) {
                continue
            }
            
            let tile = grid[row: current.row, column: current.column]
            let barriers = grid.barriersForTile(atColumn: current.column, row: current.row)
            
            tiles.append(Coordinate(column: current.column, row: current.row, ports: tile.ports))
            
            for port in tile.ports where !barriers.contains(port) {
                let neighbor = grid.columnRowByMoving(column: current.column,
                                                      row: current.row,
                                                      direction: port)
                let neighborPorts = grid[row: neighbor.row, column: neighbor.column]
                
                if neighborPorts.ports.contains(port.opposite) {
                    queue.append(neighbor)
                }
            }
        }
        
        return Network(tiles: tiles)
    }
}
