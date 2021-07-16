/// A Net game grid
public struct Grid {
    /// Matrix of tiles, stored as [rows][columns]
    internal(set) public var tiles: [[Tile]] = []
    
    /// Whether the grid wraps around so tiles can connect with tiles on the
    /// opposite end of the grid.
    internal(set) public var wrapping: Bool
    
    /// Returns the number of tiles on this grid
    public var tileCount: Int {
        return rows * columns
    }
    
    /// The number of horizontal rows on this grid
    public let rows: Int
    /// The number of vertical rows on this grid
    public let columns: Int
    
    // TODO: Consider reverting indices order so it reads column x row as the rest
    // of the APIs
    public subscript(row row: Int, column column: Int) -> Tile {
        get {
            return self[row: row][column]
        }
        set {
            self[row: row][column] = newValue
        }
    }
    
    public subscript(row row: Int) -> [Tile] {
        get {
            return tiles[row]
        }
        set {
            tiles[row] = newValue
        }
    }
    
    /// Initializes a new Grid instance
    ///
    /// - Parameters:
    ///   - rows: The number of horizontal rows on the grid. Must be greater than
    ///   0.
    ///   - columns: The number of vertical columns on the grid. Must be greater
    ///   than 0.
    ///   - wrapping: Whether the grid wraps around so tiles can connect with
    ///   tiles on the opposite end of the grid.
    ///
    /// - precondition: `rows > 0 && columns > 0`
    public init(rows: Int, columns: Int, wrapping: Bool = false) {
        precondition(rows > 0, "Must have at least one row")
        precondition(columns > 0, "Must have at least one column")
        
        self.rows = rows
        self.columns = columns
        self.wrapping = wrapping
        
        initGrid()
    }
    
    private mutating func initGrid() {
        tiles.removeAll()
        
        for _ in 0..<rows {
            let row = Array(repeating: Tile(kind: .I, orientation: .north), count: columns)
            
            tiles.append(row)
        }
    }
    
    /// Returns `true` if the given column/row combination represents a valid
    /// tile in this grid.
    public func isWithinBounds(column: Int, row: Int) -> Bool {
        return column >= 0 && row >= 0 && column < columns && row < rows
    }
    
    /// Returns whether two tiles are neighbors on the grid.
    /// Tiles are neighbors if they share an edge, or are located in the same column
    /// or row at opposite ends of the grid, in case the grid is wrapping.
    ///
    /// Neighbor detection ignores barriers, except for barriers placed for
    /// non-wrapping grids.
    public func areNeighbors(atColumn1 column1: Int, row1: Int, column2: Int, row2: Int) -> Bool {
        guard isWithinBounds(column: column1, row: row1),
              isWithinBounds(column: column2, row: row2) else {
            return false
        }
        
        // Order the coordinates to make comparisons easier
        let columnLeft = min(column1, column2)
        let columnRight = max(column1, column2)
        
        let rowTop = min(row1, row2)
        let rowBottom = max(row1, row2)
        
        if columnLeft == columnRight {
            if rowBottom == rowTop + 1 {
                return true
            }
            if wrapping && rowTop == 0 && rowBottom == (rows - 1) {
                return true
            }
        }
        if rowTop == rowBottom {
            if columnRight == columnLeft + 1 {
                return true
            }
            if wrapping && columnLeft == 0 && columnRight == (columns - 1) {
                return true
            }
        }
        
        return false
    }
    
    /// Returns a list of the four tiles surrounding a tile at a given column/row,
    /// along with the corresponding direction of the tile as an edge port from
    /// the center tile.
    ///
    /// For tiles that are at the corners of the grid, the surrounding tiles list
    /// includes tiles that are wrapped around the grid on the opposite sides.
    public func surroundingTiles(column: Int, row: Int) -> [(tile: Tile, edge: EdgePort)] {
        func fetch(_ edgePort: EdgePort) -> (Tile, EdgePort) {
            let (c, r) = columnRowByMoving(column: column, row: row, direction: edgePort)
            
            return (self[row: r, column: c], edgePort)
        }
        
        return [
            fetch(.top),
            fetch(.right),
            fetch(.bottom),
            fetch(.left)
        ]
    }
    
    /// Returns the column/row that results from moving from a given column/row
    /// at a specified edge port.
    ///
    /// If querying tiles at the edge of the grid with a direction that points to
    /// out-of-bounds, the resulting column/row are wrapped around to the
    /// opposite side of the grid.
    public func columnRowByMoving(column: Int, row: Int, direction: EdgePort) -> (column: Int, row: Int) {
        var column = column
        var row = row
        
        switch direction {
        case .top:
            row -= 1
            if row < 0 {
                row = rows - 1
            }
        case .left:
            column -= 1
            if column < 0 {
                column = columns - 1
            }
        case .bottom:
            row += 1
            if row >= rows {
                row = 0
            }
        case .right:
            column += 1
            if column >= columns {
                column = 0
            }
        }
        
        return (column, row)
    }
    
    /// Returns a set of edges that are barred for a tile at a given column/row
    /// combination.
    ///
    /// Includes barriers for outer edge tiles for non-wrapping grids.
    public func barriersForTile(atColumn column: Int, row: Int) -> Set<EdgePort> {
        var result: Set<EdgePort> = []
        
        // Report barriers for tiles that are surrounding the edges of the grid
        // if this grid is non-wrapping
        if !wrapping {
            if column == 0 {
                result.insert(.left)
            }
            if row == 0 {
                result.insert(.top)
            }
            if column == columns - 1 {
                result.insert(.right)
            }
            if row == rows - 1 {
                result.insert(.bottom)
            }
        }
        
        return result
    }
    
    /// Returns the edge port that connects the first tile to the second.
    /// In case the tiles are not neighbors, `nil` is returned, instead.
    ///
    /// Tiles that are adjacent across grid bounds on wrapped grids are detected
    /// as well.
    ///
    /// Edge port ignores tile kinds and orientations and operates solely on
    /// coordinates.
    public func edgePort(from tile1: (column: Int, row: Int), to tile2: (column: Int, row: Int)) -> EdgePort? {
        guard areNeighbors(atColumn1: tile1.column, row1: tile1.row, column2: tile2.column, row2: tile2.row) else {
            return nil
        }
        
        // Horizontal neighbors
        if tile1.row == tile2.row {
            if tile1.column == tile2.column - 1 {
                return .right
            }
            if tile1.column == tile2.column + 1 {
                return .left
            }
            
            // Wrapping grid detection
            if wrapping {
                if tile1.column == columns - 1 && tile2.column == 0 {
                    return .right
                }
                if tile1.column == 0 && tile2.column == columns - 1 {
                    return .left
                }
            }
        }
        
        // Vertical neighbors
        if tile1.column == tile2.column {
            if tile1.row == tile2.row - 1 {
                return .bottom
            }
            if tile1.row == tile2.row + 1 {
                return .top
            }
            
            // Wrapping grid detection
            if wrapping {
                if tile1.row == rows - 1 && tile2.row == 0 {
                    return .bottom
                }
                if tile1.row == 0 && tile2.row == rows - 1 {
                    return .top
                }
            }
        }
        
        return nil
    }
}

// MARK: Network <-> Grid interaction helper functions
extension Grid {
    /// Returns the tile for a given network coordinate.
    ///
    /// - precondition: ``coordinate.column``/``coordinate.row`` are within bounds
    /// of grid size
    func tile(fromCoordinate coordinate: Network.Coordinate) -> Tile {
        return self[row: coordinate.row, column: coordinate.column]
    }
}
