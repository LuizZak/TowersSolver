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
    func tilesInRow(_ row: Int) -> GridTileView<Self>

    /// Returns all the tiles contained within a given column within this grid.
    func tilesInColumn(_ column: Int) -> GridTileView<Self>

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
    @inlinable
    var tileCount: Int {
        rows * columns
    }

    @inlinable
    var tilesSequential: [TileType] {
        (0..<tileCount).map { self[sequential: $0] }
    }

    @inlinable
    var tileCoordinates: [CoordinateType] {
        (0..<tileCount).map(indexToColumnRow(_:))
    }

    @inlinable
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

    @inlinable
    func tilesInRow(_ row: Int) -> GridTileView<Self> {
        .init(grid: self, source: .row(row))
    }

    @inlinable
    func tilesInColumn(_ column: Int) -> GridTileView<Self> {
        .init(grid: self, source: .column(column))
    }

    @inlinable
    func isWithinBounds(column: Int, row: Int) -> Bool {
        return column >= 0 && row >= 0 && column < columns && row < rows
    }
}

public extension GridType where CoordinateType == Coordinates {
    @inlinable
    func indexToColumnRow(_ index: Int) -> Coordinates {
        let column = index % columns
        let row = index / columns

        return Coordinates(column: column, row: row)
    }

    @inlinable
    func coordinatesToIndex(_ coordinates: Coordinates) -> Int {
        coordinates.row * columns + coordinates.column
    }
}

/// A view into a specific subset of a grid, whose contents can be rows or columns
/// of the grid.
public struct GridTileView<Grid: GridType> {
    @usableFromInline
    var grid: Grid

    @usableFromInline
    var source: Source

    @usableFromInline
    var length: Int

    @inlinable
    init(grid: Grid, source: Source) {
        self.grid = grid
        self.source = source

        switch source {
        case .row:
            self.length = grid.columns
        case .column:
            self.length = grid.rows
        }
    }

    @usableFromInline
    enum Source {
        case row(Int)
        case column(Int)
    }
}

extension GridTileView: Collection {
    public typealias Element = Grid.TileType
    public typealias Index = Int

    @inlinable
    public var startIndex: Int {
        0
    }

    @inlinable
    public var endIndex: Int {
        length
    }

    @inlinable
    public subscript(position: Int) -> Grid.TileType {
        switch source {
        case .row(let row):
            return grid[column: position, row: row]

        case .column(let column):
            return grid[column: column, row: position]
        }
    }

    @inlinable
    public func index(after i: Int) -> Int {
        i + 1
    }
}

extension GridTileView: BidirectionalCollection {
    @inlinable
    public func index(before i: Int) -> Int {
        i - 1
    }
}
