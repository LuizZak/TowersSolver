/// A view into a specific subset of a grid, whose contents can be rows or columns
/// of the grid, subsets of said rows or columns, single tiles, or a
/// random-access list of arbitrary tiles.
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
        case .singleTile:
            self.length = 1
        case .row:
            self.length = grid.columns
        case .column:
            self.length = grid.rows
        case .rowSubset(_, _, let length),
            .columnSubset(_, _, let length):
            self.length = length
        case .arbitrary(let coords):
            precondition(!coords.isEmpty, "\(Self.self): Source.arbitrary(coords): coords cannot be empty.")
            self.length = coords.count
        }
    }

    @usableFromInline
    enum Source {
        case singleTile(Grid.CoordinateType)
        case row(Int)
        case column(Int)
        case rowSubset(row: Int, startColumn: Int, length: Int)
        case columnSubset(column: Int, startRow: Int, length: Int)
        case arbitrary([Grid.CoordinateType])
    }
}

extension GridTileView where Grid.CoordinateType == Coordinates {
    /// Returns the indexing coordinate for the grid cell at a given position
    /// within this `GridTileView`.
    ///
    /// Indexing outside the bounds of `self.startIndex` and `self.endIndex`
    /// extrapolate the index linearly, and may lead to invalid coordinates on
    /// the underlying grid, unless this grid view references a singular tile or
    /// a random-access list of tiles, in which case the result is always capped.
    /// between `self.startIndex..<self.endIndex`.
    @inlinable
    public subscript(coordinateAt position: Int) -> Grid.CoordinateType {
        switch source {
        case .singleTile(let coord):
            return coord
        
        case .row(let row):
            return Coordinates(column: position, row: row)

        case .column(let column):
            return Coordinates(column: column, row: position)

        case .rowSubset(let row, let startColumn, _):
            return Coordinates(column: startColumn + position, row: row)

        case .columnSubset(let column, let startRow, _):
            return Coordinates(column: column, row: startRow + position)
        
        case .arbitrary(let coords):
            if position < 0 {
                return coords[0]
            }
            if position > coords.count {
                return coords[coords.count - 1]
            }

            return coords[position]
        }
    }

    /// Returns a list of coordinates that correspond to each tile in this grid
    /// tile view, in the same order as the tiles on this view.
    @inlinable
    public var coordinates: [Grid.CoordinateType] {
        switch source {
        case .singleTile(let coord):
            return [coord]

        case .row(let row):
            return (0..<grid.columns).map { column in
                .init(column: column, row: row)
            }

        case .column(let column):
            return (0..<grid.rows).map { row in
                .init(column: column, row: row)
            }

        case .rowSubset(let row, let startColumn, let length):
            return (startColumn..<(startColumn + length)).map { column in
                .init(column: column, row: row)
            }

        case .columnSubset(let column, let startRow, let length):
            return (startRow..<(startRow + length)).map { row in
                .init(column: column, row: row)
            }
        
        case .arbitrary(let coords):
            return coords
        }
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
        case .singleTile(let coord):
            precondition(position == 0, "\(Self.self)\(#function): Tile views with Source.singleTile cannot be indexed with values other than 0.")
            return grid[coord]
        
        case .row(let row):
            return grid[column: position, row: row]

        case .column(let column):
            return grid[column: column, row: position]

        case .rowSubset(let row, let startColumn, _):
            return grid[column: startColumn + position, row: row]

        case .columnSubset(let column, let startRow, _):
            return grid[column: column, row: startRow + position]
        
        case .arbitrary(let coords):
            return grid[coords[position]]
        }
    }

    /// Returns a subsection of this tile view, with only a specified range of
    /// indices available.
    ///
    /// The new tile view will have its own 0-based indexing system that is
    /// separate from this grid view's.
    ///
    /// The range may be the entire length of this tile view, in which case an
    /// exact copy of this view is returned.
    ///
    /// - precondition: `range` is not empty.
    /// - precondition: for all `index` in `range`, `self.indices.contains(index)`.
    public subscript(subViewInRange range: Range<Int>) -> Self {
        precondition(!range.isEmpty)
        precondition(range.allSatisfy(self.indices.contains), "range.allSatisfy(self.indices.contains)")

        switch source {
        case .singleTile:
            return self
        
        case .row(let row):
            return grid.tilesInRow(row, startColumn: range.lowerBound, length: range.count)

        case .column(let column):
            return grid.tilesInColumn(column, startRow: range.lowerBound, length: range.count)

        case .rowSubset(let row, let startColumn, _):
            return grid.tilesInRow(row, startColumn: startColumn + range.lowerBound, length: range.count)

        case .columnSubset(let column, let startRow, _):
            return grid.tilesInColumn(column, startRow: startRow + range.lowerBound, length: range.count)
        
        case .arbitrary(let coords):
            return grid.viewForCoordinates(coordinateList: coords[range])
        }
    }

    /// Returns a subsection of this tile view, with only a specified range of
    /// indices available.
    ///
    /// The new tile view will have its own 0-based indexing system that is
    /// separate from this grid view's.
    ///
    /// The range may be the entire length of this tile view, in which case an
    /// exact copy of this view is returned.
    ///
    /// - precondition: for all `index` in `range`, `self.indices.contains(index)`.
    public subscript(subViewInRange range: ClosedRange<Int>) -> Self {
        precondition(range.allSatisfy(self.indices.contains), "range.allSatisfy(self.indices.contains)")

        switch source {
        case .singleTile:
            return self
        
        case .row(let row):
            return grid.tilesInRow(row, startColumn: range.lowerBound, length: range.count)

        case .column(let column):
            return grid.tilesInColumn(column, startRow: range.lowerBound, length: range.count)

        case .rowSubset(let row, let startColumn, _):
            return grid.tilesInRow(row, startColumn: startColumn + range.lowerBound, length: range.count)

        case .columnSubset(let column, let startRow, _):
            return grid.tilesInColumn(column, startRow: startRow + range.lowerBound, length: range.count)
        
        case .arbitrary(let coords):
            return grid.viewForCoordinates(coordinateList: coords[range])
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
