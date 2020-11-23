/// A Net game grid
public struct Grid {
    /// Matrix of tiles, nested in [y][x] fashion
    var tiles: [[Tile]] = []
    
    let rows: Int
    let columns: Int
    
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
        
        for _ in 0..<columns {
            let row = Array(repeating: Tile(kind: .I, orientation: .north), count: rows)
            
            tiles.append(row)
        }
    }
}
