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
    ///   1.
    ///   - columns: The number of vertical columns on the grid. Must be greater
    ///   than 1.
    ///
    /// - precondition: `rows > 1 && columns > 1`
    public init(rows: Int, columns: Int) {
        precondition(rows > 1, "Must have more than one row")
        precondition(columns > 1, "Must have more than one column")
        
        self.rows = rows
        self.columns = columns
        
        initGrid()
    }
    
    private mutating func initGrid() {
        tiles.removeAll()
        
        for _ in 0..<columns {
            let row = Array(repeating: Tile(orientation: .north, kind: .I), count: rows)
            
            tiles.append(row)
        }
    }
}
