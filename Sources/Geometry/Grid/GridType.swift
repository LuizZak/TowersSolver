/// Represents a square grid type, with regular column/rows.
public protocol GridType {
    /// The type for each tile within this grid.
    associatedtype TileType

    /// The type for representing coordinates within this grid.
    associatedtype CoordinateType = Coordinates

    /// Returns the number of tiles on this grid
    var tileCount: Int { get }

    /// The number of horizontal rows on this grid
    var rows: Int { get }

    /// The number of vertical rows on this grid
    var columns: Int { get }

    /// Returns a list of the tiles from this grid laid out sequentially, where
    /// each tile maps as column + row * (columns)
    var tilesSequential: [TileType] { get }

    /// Returns a list of coordinates for each tile in `self.tiles`.
    var tileCoordinates: [CoordinateType] { get }

    /// Indexes into the list of tiles sequentially, where each tile maps as
    /// column + row * (columns)
    subscript(sequential index: Int) -> TileType { get set }

    /// Gets or sets a tile on a given coordinate within this grid.
    subscript(coordinates: CoordinateType) -> TileType { get set }

    /// Gets or sets a tile on a given coordinate within this grid.
    subscript(column column: Int, row row: Int) -> TileType { get set }

    /// Gets or sets a list of tiles within a given column within this grid.
    subscript(column column: Int) -> [TileType] { get set }

    /// Returns all the tiles contained within a given row within this grid.
    func tilesInRow(_ row: Int) -> [TileType]

    /// Returns all the tiles contained within a given column within this grid.
    func tilesInColumn(_ column: Int) -> [TileType]

    /// Returns `true` if the given column/row combination represents a valid
    /// tile in this grid.
    func isWithinBounds(column: Int, row: Int) -> Bool

    /// Requests that a given sequential index be converted to a coordinate
    /// within this grid.
    func indexToColumnRow(_ index: Int) -> CoordinateType

    /// Requests that the given coordinates be converted to a sequential index
    /// within this grid.
    func coordinatesToIndex(_ coordinates: CoordinateType) -> Int
}

public extension GridType {
    var tileCount: Int {
        rows * columns
    }

    var tilesSequential: [TileType] {
        (0..<tileCount).map { self[sequential: $0] }
    }

    var tileCoordinates: [CoordinateType] {
        (0..<tileCount).map(indexToColumnRow(_:))
    }

    subscript(sequential index: Int) -> TileType {
        get {
            let coords = indexToColumnRow(index)
            return self[coords]
        }
        set {
            let coords = indexToColumnRow(index)
            self[coords] = newValue
        }
    }

    func tilesInRow(_ row: Int) -> [TileType] {
        (0..<columns).map { self[column: $0, row: row] }
    }

    func tilesInColumn(_ column: Int) -> [TileType] {
        self[column: column]
    }

    func isWithinBounds(column: Int, row: Int) -> Bool {
        return column >= 0 && row >= 0 && column < columns && row < rows
    }
}

public extension GridType where CoordinateType == Coordinates {
    func indexToColumnRow(_ index: Int) -> Coordinates {
        let column = index % columns
        let row = index / columns

        return Coordinates(column: column, row: row)
    }

    func coordinatesToIndex(_ coordinates: Coordinates) -> Int {
        coordinates.row * columns + coordinates.column
    }
}
