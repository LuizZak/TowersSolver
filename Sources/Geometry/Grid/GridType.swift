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

    /// Returns a list of tiles that map to the given list of grid coordinates on
    /// this grid.
    ///
    /// - precondition: for all `coord` in `S`, `self.isWithinBounds(coord) == true`.
    subscript<S: Sequence<CoordinateType>>(coordinateList: S) -> [TileType] { get }

    /// Returns all the tiles contained within a given row within this grid in
    /// an indexable tile view.
    func tilesInRow(_ row: Int) -> GridTileView<Self>

    /// Returns a subset of the tiles contained within a given row within this
    /// grid in an indexable tile view.
    func tilesInRow(_ row: Int, startColumn: Int, length: Int) -> GridTileView<Self>

    /// Returns all the tiles contained within a given column within this grid
    /// in an indexable tile view.
    func tilesInColumn(_ column: Int) -> GridTileView<Self>

    /// Returns a subset of the tiles contained within a given column within this
    /// grid in an indexable tile view.
    func tilesInColumn(_ column: Int, startRow: Int, length: Int) -> GridTileView<Self>

    /// Returns a grid tile view that exposes a single tile at a given coordinate.
    ///
    /// - precondition: `self.isWithinBounds(column: column, row: row) == true`.
    func viewForTile(column: Int, row: Int) -> GridTileView<Self>

    /// Returns a grid tile view that exposes a single tile at a given coordinate.
    ///
    /// - precondition: `self.isWithinBounds(coord) == true`.
    func viewForTile(_ coords: CoordinateType) -> GridTileView<Self>

    /// Returns a grid tile view that represent the given list of grid coordinates.
    ///
    /// - precondition: for all `coord` in `S`, `self.isWithinBounds(coord) == true`.
    func viewForCoordinates<S: Sequence<CoordinateType>>(coordinateList: S) -> GridTileView<Self>

    /// Returns `true` if the given column/row combination map to a valid tile
    /// in this grid.
    func isWithinBounds(column: Int, row: Int) -> Bool

    /// Returns `true` if the given coordinates map to a valid tile in this grid.
    func isWithinBounds(_ coords: CoordinateType) -> Bool

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
    subscript<S: Sequence<CoordinateType>>(coordinateList: S) -> [TileType] {
        coordinateList.map({ self[$0] })
    }

    @inlinable
    func tilesInRow(_ row: Int) -> GridTileView<Self> {
        .init(grid: self, source: .row(row))
    }

    @inlinable
    func tilesInRow(_ row: Int, startColumn: Int, length: Int) -> GridTileView<Self> {
        .init(
            grid: self,
            source: .rowSubset(row: row, startColumn: startColumn, length: length)
        )
    }

    @inlinable
    func tilesInColumn(_ column: Int) -> GridTileView<Self> {
        .init(grid: self, source: .column(column))
    }

    @inlinable
    func tilesInColumn(_ column: Int, startRow: Int, length: Int) -> GridTileView<Self> {
        .init(
            grid: self,
            source: .columnSubset(column: column, startRow: startRow, length: length)
        )
    }

    @inlinable
    func viewForTile(_ coords: CoordinateType) -> GridTileView<Self> {
        precondition(self.isWithinBounds(coords), "self.isWithinBounds(coords)")

        return .init(grid: self, source: .singleTile(coords))
    }

    @inlinable
    func viewForCoordinates<S: Sequence<CoordinateType>>(coordinateList: S) -> GridTileView<Self> {
        let coords = Array(coordinateList)
        precondition(coords.allSatisfy(self.isWithinBounds(_:)), "\(coords).allSatisfy(self.isWithinBounds(_:))")

        return .init(grid: self, source: .arbitrary(coords))
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

    @inlinable
    func viewForTile(column: Int, row: Int) -> GridTileView<Self> {
        self.viewForTile(.init(column: column, row: row))
    }

    @inlinable
    func isWithinBounds(_ coords: CoordinateType) -> Bool {
        return isWithinBounds(column: coords.column, row: coords.row)
    }
}
