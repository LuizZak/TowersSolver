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
    
    /// Returns a list of the four tiles surrounding a tile at a given column/row,
    /// along with the corresponding direction of the tile as an edge port from
    /// the center tile.
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
    /// Querying tiles at the edge of the grid with a direction that points to
    /// out-of-bounds, the resulting column or row are wrapped around to the
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
}
