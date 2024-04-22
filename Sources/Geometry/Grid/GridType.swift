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

    /// Returns `true` if the two given coordinates are orthogonally adjacent to
    /// each other in this grid.
    func areOrthogonallyAdjacent(_ coord1: CoordinateType, _ coord2: CoordinateType) -> Bool

    /// Returns `true` if the two given coordinates are diagonally adjacent to
    /// each other in this grid.
    func areDiagonallyAdjacent(_ coord1: CoordinateType, _ coord2: CoordinateType) -> Bool

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

    /// Returns a grid tile view that lists all the tiles that are orthogonal to
    /// a given tile coordinate, i.e. all other tiles that share a column or row
    /// with this tile.
    ///
    /// The resulting tile view has the tiles sorted from nearest to furthest on
    /// the left, top, right, and bottom sides, respectively.
    ///
    /// - precondition: `self.isWithinBounds(column: column, row: row) == true`.
    func tilesOrthogonalTo(column: Int, row: Int) -> GridTileView<Self>

    /// Returns a grid tile view that lists all the tiles that are orthogonal to
    /// a given tile coordinate, i.e. all other tiles that share a column or row
    /// with this tile.
    ///
    /// The resulting tile view has the tiles sorted from nearest to furthest on
    /// the left, top, right, and bottom sides, respectively.
    ///
    /// - precondition: `self.isWithinBounds(coords) == true`.
    func tilesOrthogonalTo(_ coords: CoordinateType) -> GridTileView<Self>

    /// Returns a grid tile view that lists the tiles that are orthogonally
    /// adjacent to a given tile coordinate.
    ///
    /// - precondition: `self.isWithinBounds(column: column, row: row) == true`.
    func tilesOrthogonallyAdjacentTo(column: Int, row: Int) -> GridTileView<Self>

    /// Returns a grid tile view that lists the tiles that are orthogonally
    /// adjacent to a given tile coordinate.
    ///
    /// - precondition: `self.isWithinBounds(coords) == true`.
    func tilesOrthogonallyAdjacentTo(_ coords: CoordinateType) -> GridTileView<Self>

    /// Returns a grid tile view that lists the tiles that are diagonally
    /// adjacent to a given tile coordinate.
    ///
    /// - precondition: `self.isWithinBounds(column: column, row: row) == true`.
    func tilesDiagonallyAdjacentTo(column: Int, row: Int) -> GridTileView<Self>

    /// Returns a grid tile view that lists the tiles that are diagonally
    /// adjacent to a given tile coordinate.
    ///
    /// - precondition: `self.isWithinBounds(coords) == true`.
    func tilesDiagonallyAdjacentTo(_ coords: CoordinateType) -> GridTileView<Self>

    /// Returns a grid tile view that lists all the tiles that are diagonal to a
    /// given tile coordinate.
    ///
    /// - precondition: `self.isWithinBounds(column: column, row: row) == true`.
    func tilesDiagonalTo(column: Int, row: Int) -> GridTileView<Self>

    /// Returns a grid tile view that lists all the tiles that are diagonal to a
    /// given tile coordinate.
    ///
    /// - precondition: `self.isWithinBounds(coords) == true`.
    func tilesDiagonalTo(_ coords: CoordinateType) -> GridTileView<Self>

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

    /// Returns coordinates that point to a given column/row in this grid.
    func makeCoordinates(column: Int, row: Int) -> CoordinateType

    /// Returns a shifted set of coordinates starting at `coords`, shifting by
    /// a specified number of rows/columns.
    ///
    /// If the resulting coordinates are out-of-bounds in this grid, `nil` is
    /// returned, instead.
    func shift(coords: CoordinateType, byColumn column: Int, row: Int) -> CoordinateType?
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
    func tilesOrthogonalTo(column: Int, row: Int) -> GridTileView<Self> {
        precondition(self.isWithinBounds(column: column, row: row), "self.isWithinBounds(coords)")

        var result: [CoordinateType] = []
        var current: CoordinateType

        // Left
        current = makeCoordinates(column: column, row: row)
        while let next = shift(coords: current, byColumn: -1, row: 0) {
            result.append(next)
            current = next
        }
        // Top
        current = makeCoordinates(column: column, row: row)
        while let next = shift(coords: current, byColumn: 0, row: -1) {
            result.append(next)
            current = next
        }
        // Right
        current = makeCoordinates(column: column, row: row)
        while let next = shift(coords: current, byColumn: 1, row: 0) {
            result.append(next)
            current = next
        }
        // Bottom
        current = makeCoordinates(column: column, row: row)
        while let next = shift(coords: current, byColumn: 0, row: 1) {
            result.append(next)
            current = next
        }

        return .init(grid: self, source: .arbitrary(result))
    }

    @inlinable
    func tilesDiagonalTo(column: Int, row: Int) -> GridTileView<Self> {
        precondition(self.isWithinBounds(column: column, row: row), "self.isWithinBounds(coords)")

        var result: [CoordinateType] = []
        var current: CoordinateType

        // Top left
        current = makeCoordinates(column: column, row: row)
        while let next = shift(coords: current, byColumn: -1, row: -1) {
            result.append(next)
            current = next
        }
        // Top right
        current = makeCoordinates(column: column, row: row)
        while let next = shift(coords: current, byColumn: -1, row: 1) {
            result.append(next)
            current = next
        }
        // Bottom left
        current = makeCoordinates(column: column, row: row)
        while let next = shift(coords: current, byColumn: -1, row: 1) {
            result.append(next)
            current = next
        }
        // Bottom right
        current = makeCoordinates(column: column, row: row)
        while let next = shift(coords: current, byColumn: 1, row: 1) {
            result.append(next)
            current = next
        }

        return .init(grid: self, source: .arbitrary(result))
    }

    @inlinable
    func tilesOrthogonallyAdjacentTo(column: Int, row: Int) -> GridTileView<Self> {
        precondition(self.isWithinBounds(column: column, row: row), "self.isWithinBounds(coords)")

        let center = makeCoordinates(column: column, row: row)
        let left = shift(coords: center, byColumn: -1, row: 0)
        let top = shift(coords: center, byColumn: 0, row: -1)
        let right = shift(coords: center, byColumn: 1, row: 0)
        let bottom = shift(coords: center, byColumn: 0, row: 1)

        let coords = [left, top, right, bottom].compactMap({$0})

        return .init(grid: self, source: .arbitrary(coords))
    }

    @inlinable
    func tilesDiagonallyAdjacentTo(column: Int, row: Int) -> GridTileView<Self> {
        precondition(self.isWithinBounds(column: column, row: row), "self.isWithinBounds(coords)")

        let center = makeCoordinates(column: column, row: row)
        let topLeft = shift(coords: center, byColumn: -1, row: -1)
        let topRight = shift(coords: center, byColumn: 1, row: -1)
        let bottomLeft = shift(coords: center, byColumn: -1, row: 1)
        let bottomRight = shift(coords: center, byColumn: 1, row: 1)

        let coords = [topLeft, topRight, bottomLeft, bottomRight].compactMap({$0})

        return .init(grid: self, source: .arbitrary(coords))
    }

    @inlinable
    func viewForTile(column: Int, row: Int) -> GridTileView<Self> {
        self.viewForTile(makeCoordinates(column: column, row: row))
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

    @inlinable
    func indexToColumnRow(_ index: Int) -> CoordinateType {
        let column = index % columns
        let row = index / columns

        return makeCoordinates(column: column, row: row)
    }
}

public extension GridType where CoordinateType == Coordinates {
    @inlinable
    func areOrthogonallyAdjacent(_ coord1: CoordinateType, _ coord2: CoordinateType) -> Bool {
        if coord1 == coord2 {
            return false
        }

        // Sharing row
        if coord1.row == coord2.row {
            return abs(coord2.column - coord1.column) == 1
        }
        // Sharing column
        if coord1.column == coord2.column {
            return abs(coord2.row - coord1.row) == 1
        }

        return false
    }

    @inlinable
    func areDiagonallyAdjacent(_ coord1: CoordinateType, _ coord2: CoordinateType) -> Bool {
        if coord1.column == coord2.column || coord1.row == coord2.row {
            return false
        }

        let dc = abs(coord2.column - coord1.column)
        let dr = abs(coord2.row - coord1.row)

        return dc == 1 && dr == 1
    }

    @inlinable
    func tilesOrthogonalTo(_ coords: CoordinateType) -> GridTileView<Self> {
        tilesOrthogonalTo(column: coords.column, row: coords.row)
    }

    @inlinable
    func tilesOrthogonallyAdjacentTo(_ coords: CoordinateType) -> GridTileView<Self> {
        tilesOrthogonallyAdjacentTo(column: coords.column, row: coords.row)
    }

    @inlinable
    func tilesDiagonalTo(_ coords: CoordinateType) -> GridTileView<Self> {
        tilesDiagonalTo(column: coords.column, row: coords.row)
    }

    @inlinable
    func tilesDiagonallyAdjacentTo(_ coords: CoordinateType) -> GridTileView<Self> {
        tilesDiagonallyAdjacentTo(column: coords.column, row: coords.row)
    }

    @inlinable
    func coordinatesToIndex(_ coordinates: Coordinates) -> Int {
        coordinates.row * columns + coordinates.column
    }

    @inlinable
    func isWithinBounds(_ coords: CoordinateType) -> Bool {
        return isWithinBounds(column: coords.column, row: coords.row)
    }

    @inlinable
    func makeCoordinates(column: Int, row: Int) -> CoordinateType {
        return Coordinates(column: column, row: row)
    }

    @inlinable
    func shift(coords: CoordinateType, byColumn column: Int, row: Int) -> CoordinateType? {
        let newCoords = makeCoordinates(column: coords.column + column, row: coords.row + row)

        if !isWithinBounds(newCoords) {
            return nil
        }

        return newCoords
    }
}
