private let dxs: [Int] = [  0,  1, 1, 1, 0, -1, -1, -1 ]
private let dys: [Int] = [ -1, -1, 0, 1, 1,  1,  0, -1 ]

/// A Signpost game grid
public struct Grid {
    private var _cache: InternalCache

    /// Matrix of tiles, stored as [columns][rows]
    private(set) public var tiles: [[Tile]] = []

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
        (0..<tileCount).map { self[sequential: $0] }
    }

    /// Returns a list of coordinates for each tile in `self.tiles`.
    public var tileCoordinates: [Coordinates] {
        (0..<tileCount).map(_indexToColumnRow(_:))
    }

    /// Returns a list of numbers, one per tile in the order of `self.tileCoordinates`,
    /// with each entry representing the computed number of the tile based either
    /// on its hint or its connection to another hinted tile.
    ///
    /// An entry is `nil` if it has no hints and is not connected to a hinted tile.
    public var tileNumbers: [Int?] {
        tileCoordinates.map(effectiveNumberForTile(_:))
    }

    /// Indexes into the list of tiles sequentially, where each tile maps as
    /// column + row * (columns)
    public subscript(sequential index: Int) -> Tile {
        get {
            let coords = _indexToColumnRow(index)

            return self[coords]
        }
        set {
            ensureUnique()
            _cache.invalidate()
            
            let coords = _indexToColumnRow(index)

            self[coords] = newValue
        }
    }

    public subscript(column column: Int, row row: Int) -> Tile {
        get {
            self[column: column][row]
        }
        set {
            ensureUnique()
            _cache.invalidate()
            
            self[column: column][row] = newValue
        }
    }

    public subscript(coordinates: Coordinates) -> Tile {
        get {
            self[column: coordinates.column, row: coordinates.row]
        }
        set {
            ensureUnique()
            _cache.invalidate()
            
            self[column: coordinates.column, row: coordinates.row] = newValue
        }
    }

    public subscript(column column: Int) -> [Tile] {
        get {
            tiles[column]
        }
        set {
            ensureUnique()
            _cache.invalidate()

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

        self._cache = InternalCache(columns: columns)

        initGrid()
    }

    private mutating func ensureUnique() {
        if !isKnownUniquelyReferenced(&_cache) {
            _cache = _cache.copy()
        }
    }

    private mutating func initGrid() {
        ensureUnique()
        _cache.invalidate()

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
    ///
    /// Result is `nil` if tile is not a hint and is not connected to a numbered
    /// tile.
    public func effectiveNumberForTile(_ coordinates: Coordinates) -> Int? {
        effectiveNumberForTile(column: coordinates.column, row: coordinates.row)
    }

    /// Returns the effective numerical value for a tile on the given coordinates.
    /// Effective numbers include numbers that are part of the original hints
    /// as well as numbers deduced from following blank signposts until a numbered
    /// one is reached.
    ///
    /// Result is `nil` if tile is not a hint and is not connected to a numbered
    /// tile.
    public func effectiveNumberForTile(column: Int, row: Int) -> Int? {
        let tile = self[column: column, row: row]
        if let solution = tile.solution {
            return solution
        }

        if let cached = _cache.getTileNumber(column: column, row: row) {
            return cached
        }

        func cacheAndReturn(column: Int, row: Int, _ value: Int?) -> Int? {
            _cache.setTileNumber(column: column, row: row, number: value)
            return value
        }

        func cacheAndReturn(_ coordinates: Coordinates, _ value: Int?) -> Int? {
            _cache.setTileNumber(column: coordinates.column, row: coordinates.row, number: value)
            return value
        }

        func cacheAndReturn(_ value: Int?) -> Int? {
            cacheAndReturn(column: column, row: row, value)
        }

        var counter: Int
        var visitedNodes: [Coordinates]

        // Search forwards
        counter = -1
        visitedNodes = [Coordinates(column: column, row: row)]

        var next = tileConnectedFrom(column: column, row: row)
        while let n = next {
            defer { counter -= 1 }

            let tile = self[n]
            if let solution = tile.solution {
                // Cache visited tiles too
                while let visit = visitedNodes.first {
                    _=cacheAndReturn(visit, solution - visitedNodes.count)
                    visitedNodes.removeFirst()
                }

                return cacheAndReturn(solution + counter)
            }

            visitedNodes.append(n)

            next = tileConnectedFrom(column: n.column, row: n.row)
        }

        // Search backwards
        counter = 1
        visitedNodes = [Coordinates(column: column, row: row)]

        var prev = tileConnectedTo(column: column, row: row)
        while let p = prev {
            defer { counter += 1 }

            let tile = self[p]
            if let solution = tile.solution {
                // Cache visited tiles too
                while let visit = visitedNodes.first {
                    _=cacheAndReturn(visit, solution + visitedNodes.count)
                    visitedNodes.removeFirst()
                }

                return cacheAndReturn(solution + counter)
            }

            visitedNodes.append(p)

            prev = tileConnectedTo(column: p.column, row: p.row)
        }

        return cacheAndReturn(nil)
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

    func tileConnectedFrom(_ coordinates: Coordinates) -> Coordinates? {
        tileConnectedFrom(column: coordinates.column, row: coordinates.row)
    }

    func tileConnectedFrom(column: Int, row: Int) -> Coordinates? {
        self[column: column, row: row].connectedTo
    }
    
    func tileConnectedTo(_ coordinates: Coordinates) -> Coordinates? {
        tileConnectedTo(column: coordinates.column, row: coordinates.row)
    }

    func tileConnectedTo(column: Int, row: Int) -> Coordinates? {
        let coordinates = Coordinates(column: column, row: row)
        for coord in tileCoordinates where coord != coordinates {
            let tile = self[coord]

            if tile.connectedTo == coordinates {
                return coord
            }
        }

        return nil
    }

    /// Returns a list of tiles, beginning from a given column/row, traveling
    /// in a given orientation until the bounds of the grid are reached.
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

        let newCoord = Coordinates(column: column + dx, row: row + dy)

        assert(newCoord != Coordinates(column: column, row: row), "newCoord != Coordinates(column: column, row: row)")

        return newCoord
    }

    private func _indexToColumnRow(_ index: Int) -> Coordinates {
        let column = index % columns
        let row = index / columns

        return Coordinates(column: column, row: row)
    }

    private class InternalCache {
        private var _tileNumbers: [Int: Int?] = [:]

        let columns: Int

        init(columns: Int) {
            self.columns = columns
        }

        func copy() -> InternalCache {
            let copy = InternalCache(columns: columns)
            copy._tileNumbers = _tileNumbers
            return copy
        }

        func getTileNumber(column: Int, row: Int) -> Int?? {
            _tileNumbers[_columnRowToIndex(column: column, row: row)]
        }

        func setTileNumber(column: Int, row: Int, number: Int?) {
            _tileNumbers[_columnRowToIndex(column: column, row: row)] = number
        }

        func invalidate() {
            _tileNumbers.removeAll()
        }

        private func _columnRowToIndex(column: Int, row: Int) -> Int {
            row * columns + column
        }
    }
}

extension Grid: Equatable {
    public static func == (lhs: Grid, rhs: Grid) -> Bool {
        lhs.columns == rhs.columns && lhs.rows == rhs.rows && lhs.tiles == rhs.tiles
    }
}
