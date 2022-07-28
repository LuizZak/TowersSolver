public class NetGridController {
    private(set) public var grid: Grid

    public var columns: Int {
        return grid.columns
    }
    public var rows: Int {
        return grid.rows
    }

    /// Returns `true` if the current grid state is invalid.
    ///
    /// Grid states are invalid if locked tiles form closed networks that do not
    /// include the full grid and/or they form loops.
    public var isInvalid: Bool {
        return checkIsInvalid()
    }

    /// Returns whether the current grid is solved in a valid state.
    public var isSolved: Bool {
        return checkIsSolved()
    }

    public init(grid: Grid) {
        self.grid = grid
    }

    /// Returns whether a tile at a given column/row can be rotated.
    public func canRotateTile(atColumn column: Int, row: Int) -> Bool {
        return !grid[row: row, column: column].isLocked
    }

    /// Rotates a tile at a given column/row a given direction.
    ///
    /// Optionally specified whether to ignore the rotation command in case the
    /// tile is locked.
    ///
    /// - Parameters:
    ///   - column: The column to rotate the tile of
    ///   - row: The row to rotate the tile of
    ///   - direction: The direction of rotation
    ///   - ignoreIfLocked: Whether to ignore the rotation command in case the
    ///   tile is locked. Defaults to true.
    public func rotateTile(
        atColumn column: Int,
        row: Int,
        direction: RotationDirection,
        ignoreIfLocked: Bool = true
    ) {

        if ignoreIfLocked && grid[row: row, column: column].isLocked {
            return
        }

        switch direction {
        case .counterClockwise:
            grid[row: row, column: column].orientation.rotateLeft()
        case .clockwise:
            grid[row: row, column: column].orientation.rotateRight()
        }
    }

    /// Unconditionally sets the orientation of a tile at a given column/row
    /// to the one specified.
    public func setTileOrientation(
        atColumn column: Int,
        row: Int,
        orientation: Tile.Orientation
    ) {

        grid[row: row, column: column].orientation = orientation
    }

    /// Returns the orientations for all tiles on a given row.
    ///
    /// - precondition: `row >= 0 && row < rows`
    public func tileOrientations(forRow row: Int) -> [Tile.Orientation] {
        return grid[row: row].map(\.orientation)
    }

    /// Returns the kinds for all tiles on a given row.
    ///
    /// - precondition: `row >= 0 && row < rows`
    public func tileKinds(forRow row: Int) -> [Tile.Kind] {
        return grid[row: row].map(\.kind)
    }

    /// Shuffle the rotation of the tiles, optionally specifying whether to
    /// rotate locked tiles as well.
    ///
    /// - Parameters:
    ///   - rotateLockedTiles: Whether to rotate locked tiles. Defaults to false.
    public func shuffle(rotateLockedTiles: Bool = false) {
        var rng = SystemRandomNumberGenerator()

        shuffle(using: &rng, rotateLockedTiles: rotateLockedTiles)
    }

    /// Shuffle the rotation of the tiles according to a given random number
    /// generator, optionally specifying whether to rotate locked tiles as well.
    ///
    /// - Parameters:
    ///   - rng: The random number generator that will be used to derive the random
    ///   orientation of the tiles.
    ///   - rotateLockedTiles: Whether to rotate locked tiles. Defaults to false.
    public func shuffle<RNG: RandomNumberGenerator>(
        using rng: inout RNG,
        rotateLockedTiles: Bool = false
    ) {

        let orientations = Tile.Orientation.allCases

        for y in 0..<columns {
            for x in 0..<rows {
                if grid[row: y, column: x].isLocked && !rotateLockedTiles {
                    continue
                }

                grid[row: y, column: x].orientation =
                    orientations.randomElement(using: &rng) ?? .north
            }
        }
    }

    /// Returns a string representing the current grid as a game ID that can be
    /// loaded into Simon Tatham's implementation of Net at
    /// https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/net.html
    internal func gameId() -> String {
        var gameId = "\(rows)x\(columns)\(grid.wrapping ? "w" : ""):"

        for y in 0..<rows {
            for x in 0..<columns {
                // Tile, encoded as an integer
                var tile: Int = 0

                for port in grid[row: y, column: x].ports {
                    switch port {
                    case .top:
                        tile |= EncodedTileConstants.upBitcode
                    case .right:
                        tile |= EncodedTileConstants.rightBitcode
                    case .bottom:
                        tile |= EncodedTileConstants.downBitcode
                    case .left:
                        tile |= EncodedTileConstants.leftBitcode
                    }
                }

                gameId.append(String(tile, radix: 16))
            }
        }

        return gameId
    }

    private func checkIsInvalid() -> Bool {
        // Detect locked tiles facing barriers or other locked tiles that have no
        // connecting ports between them
        for row in 0..<rows {
            for column in 0..<columns {
                let tile = grid[row: row, column: column]
                guard tile.isLocked else {
                    continue
                }

                let barriers = grid.barriersForTile(atColumn: column, row: row)

                for port in tile.ports {
                    if barriers.contains(port) {
                        return true
                    }

                    // Detect neighbor tiles that are locked as well but the current
                    // tile has an edge pointing towards them while they do not
                    let neighbor = grid.columnRowByMoving(column: column, row: row, direction: port)
                    let neighborTile = grid[row: neighbor.row, column: neighbor.column]
                    if neighborTile.isLocked && !neighborTile.ports.contains(port.opposite) {
                        return true
                    }
                }
            }
        }

        let networks = Network.fromLockedTiles(onGrid: grid)

        // Detect closed sub-networks that do not contain the whole grid
        if let closedNetwork = networks.first(where: { $0.isClosed(onGrid: grid) }) {
            if !closedNetwork.isCompleteNetwork(ofGrid: grid) {
                return true
            }
        }

        return networks.contains { $0.hasLoops(onGrid: grid) }
    }

    // TODO: Consider replacing implementation with simple a Network creation
    // followed by a check on its structure, taking into consideration the
    // performance penalty that that may incur.
    private func checkIsSolved() -> Bool {
        var tilesToCheck: [(x: Int, y: Int, incomingPort: EdgePort?)] = [(0, 0, nil)]
        var tilesChecked: [(x: Int, y: Int)] = []

        // Checks a tile into the tilesToCheck array in case it has a given port
        // available. Returns `true` if the tile has been checked before, signaling
        // a loop.
        func checkTile(atX x: Int, y: Int, port: EdgePort) -> Bool {
            guard x >= 0 && x < columns && y >= 0 && y < rows else {
                return false
            }

            guard !tilesChecked.contains(where: { $0 == (x, y) }) else {
                return true
            }

            if grid[row: y, column: x].ports.contains(port) {
                tilesToCheck.append((x, y, port))
            }

            return false
        }

        while !tilesToCheck.isEmpty {
            let current = tilesToCheck.removeFirst()
            tilesChecked.append((current.x, current.y))

            let tile = grid[row: current.y, column: current.x]

            let barriers = grid.barriersForTile(atColumn: current.x, row: current.y)

            // Check in all four directions if a tile with a matching port
            // is connected with an available port on the tile
            for port in tile.ports where port != current.incomingPort && !barriers.contains(port) {
                let next = grid.columnRowByMoving(
                    column: current.x,
                    row: current.y,
                    direction: port
                )

                if checkTile(atX: next.column, y: next.row, port: port.opposite) {
                    return false
                }
            }
        }

        // Check all tiles are represented in the tiles that where traversed.
        for y in 0..<rows {
            for x in 0..<columns {
                if !tilesChecked.contains(where: { $0 == (x, y) }) {
                    return false
                }
            }
        }

        return true
    }
}

/// Represents the direction of rotation for a tile
public enum RotationDirection {
    /// Alias for `counterClockwise`
    static let left = counterClockwise
    /// Alias for `clockwise`
    static let right = clockwise

    case clockwise
    case counterClockwise
}
