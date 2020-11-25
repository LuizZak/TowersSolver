/// A Net game grid
public struct Grid {
    /// Matrix of tiles, nested in [y][x] fashion
    internal(set) public var tiles: [[Tile]] = []
    
    /// Whether the grid wraps around so tiles can connect with tiles on the
    /// opposite end of the grid.
    internal(set) public var wrapping: Bool = false
    
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
        
        initGrid()
    }
    
    private mutating func initGrid() {
        tiles.removeAll()
        
        for _ in 0..<columns {
            let row = Array(repeating: Tile(kind: .I, orientation: .north), count: rows)
            
            tiles.append(row)
        }
    }
}
