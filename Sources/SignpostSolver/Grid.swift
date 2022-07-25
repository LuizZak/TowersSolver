/// A Signpost game grid
public struct Grid: Equatable {
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
            let row = Array(repeating: Tile(orientation: .north, isEndTile: false), count: columns)

            tiles.append(row)
        }
    }

    private func _indexToColumnRow(_ index: Int) -> (column: Int, row: Int) {
        let column = index % columns
        let row = index / columns

        return (column, row)
    }
}
