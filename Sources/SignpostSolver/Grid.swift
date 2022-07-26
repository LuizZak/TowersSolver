private let dxs: [Int] = [  0,  1, 1, 1, 0, -1, -1, -1 ]
private let dys: [Int] = [ -1, -1, 0, 1, 1,  1,  0, -1 ]

/// A Signpost game grid
public struct Grid: Equatable {
    /// A typealias for the underlying coordinate type of each tile in this grid.
    public typealias Coordinates = (column: Int, row: Int)

    /// Matrix of tiles, stored as [columns][rows]
    internal(set) public var tiles: [[Tile]] = []

    /// Returns the number of tiles on this grid
    public var tileCount: Int {
        return rows * columns
    }

    /// The number of horizontal rows on this grid
    public let rows: Int
    /// The number of vertical rows on this grid
    public let columns: Int

    /// Returns a list of the tiles from this grid laid out sequentially, where
    /// each tile maps as column + row * (columns)
    public var tilesSequential: [Tile] {
        return (0..<tileCount).map {
            self[sequential: $0]
        }
    }

    /// Returns a list of coordinates for each tile in `self.tiles`.
    public var tileCoordinates: [Coordinates] {
        return (0..<tileCount).map(_indexToColumnRow(_:))
    }

    /// Indexes into the list of tiles sequentially, where each tile maps as
    /// column + row * (columns)
    public subscript(sequential index: Int) -> Tile {
        get {
            let (column, row) = _indexToColumnRow(index)

            return self[column: column, row: row]
        }
        set {
            let (column, row) = _indexToColumnRow(index)

            self[column: column, row: row] = newValue
        }
    }

    public subscript(column column: Int, row row: Int) -> Tile {
        get {
            return self[column: column][row]
        }
        set {
            self[column: column][row] = newValue
        }
    }

    public subscript(coordinates: Coordinates) -> Tile {
        get {
            return self[column: coordinates.column, row: coordinates.row]
        }
        set {
            self[column: coordinates.column, row: coordinates.row] = newValue
        }
    }

    public subscript(column column: Int) -> [Tile] {
        get {
            return tiles[column]
        }
        set {
            tiles[column] = newValue
        }
    }

    /// Initializes a new Grid instance
    ///
    /// - Parameters:
    ///   - rows: The number of horizontal rows on the grid. Must be greater than
    ///   0.
    ///   - columns: The number of vertical columns on the grid. Must be greater
    ///   than 0.
    ///
    /// - precondition: `rows > 0 && columns > 0`
    public init(rows: Int, columns: Int) {
        precondition(rows > 0, "Must have at least one row")
        precondition(columns > 0, "Must have at least one column")

        self.rows = rows
        self.columns = columns

        initGrid()
    }

    private mutating func initGrid() {
        tiles.removeAll()

        for _ in 0..<rows {
            let row = Array(repeating: Tile(orientation: .north, isStartTile: false, isEndTile: false), count: columns)

            tiles.append(row)
        }
    }

    /// Returns the effective numerical value for a tile on the given coordinates.
    /// Effective numbers include numbers that are part of the original hints
    /// as well as numbers deduced from following blank signposts until a numbered
    /// one is reached.
    public func effectiveNumberForTile(column: Int, row: Int) -> Int? {
        let tile = self[column: column, row: row]
        if let solution = tile.solution {
            return solution
        }

        var counter: Int

        // Search forwards
        counter = -1

        var next = tileConnectedFrom(column: column, row: row)
        while let n = next {
            defer { counter -= 1 }

            let tile = self[n]
            if let solution = tile.solution {
                return solution + counter
            }

            next = tileConnectedFrom(column: n.column, row: n.row)
        }

        // Search backwards
        counter = 1

        var prev = tileConnectedTo(column: column, row: row)
        while let p = prev {
            defer { counter += 1 }

            let tile = self[p]
            if let solution = tile.solution {
                return solution + counter
            }

            prev = tileConnectedTo(column: p.column, row: p.row)
        }

        return nil
    }

    /// Returns `true` if the given column/row combination represents a valid
    /// tile in this grid.
    public func isWithinBounds(column: Int, row: Int) -> Bool {
        return column >= 0 && row >= 0 && column < columns && row < rows
    }

    /// Returns a list of all tiles that a tile at a given column/row is pointing
    /// towards.
    public func tileCoordsPointedBy(column: Int, row: Int) -> [Coordinates] {
        guard isWithinBounds(column: column, row: row) else {
            return []
        }

        let tile = self[column: column, row: row]

        return _allTilesFrom(column: column, row: row, orientation: tile.orientation)
    }

    /// Returns a list of all tiles that point to a given tile coordinate.
    public func tileCoordsPointingTowards(column: Int, row: Int) -> [Coordinates] {
        guard isWithinBounds(column: column, row: row) else {
            return []
        }

        var result: [Coordinates] = []

        for orientation in Tile.Orientation.allCases {
            for tile in _allTilesFrom(column: column, row: row, orientation: orientation) {
                if self[tile].orientation == orientation.reversed {
                    result.append(tile)
                }
            }
        }

        return result
    }

    func tileConnectedFrom(column: Int, row: Int) -> Coordinates? {
        self[column: column, row: row].connectedTo
    }

    func tileConnectedTo(column: Int, row: Int) -> Coordinates? {
        for coord in tileCoordinates where coord != (column, row) {
            let tile = self[coord]

            if let connected = tile.connectedTo, connected == (column, row) {
                return coord
            }
        }

        return nil
    }

    /// Returns a list of tiles, beginning from a given column/row, traveling
    /// in a given orientation until the end of the grid is reached.
    ///
    /// The tile under (column, row) is not included in the result.
    private func _allTilesFrom(column: Int, row: Int, orientation: Tile.Orientation) -> [Coordinates] {
        guard isWithinBounds(column: column, row: row) else {
            return []
        }

        var current = _stepDirection(column: column, row: row, orientation: orientation)
        var result: [Coordinates] = []

        while isWithinBounds(column: current.column, row: current.row) {
            result.append(current)

            current = _stepDirection(column: current.column, row: current.row, orientation: orientation)
        }

        return result
    }

    /// Returns a new pair of coordinates that represent the coordinates that
    /// result from walking the given coordinates one tile in a given orientation.
    private func _stepDirection(column: Int, row: Int, orientation: Tile.Orientation) -> Coordinates {
        let dx = dxs[orientation.rawValue]
        let dy = dys[orientation.rawValue]

        let newCoord = (column + dx, row + dy)

        assert(newCoord != (column, row), "newCoord != (column, row)")

        return newCoord
    }

    private func _indexToColumnRow(_ index: Int) -> (column: Int, row: Int) {
        let column = index % columns
        let row = index / columns

        return (column, row)
    }
}
