/// Metadata used alongside grids to store solver logic-specific information
struct GridMetadata {
    private let rows: Int
    private let columns: Int
    
    /// Tile metadata, stored as [rows][columns]
    private var metadata: [[TileMetadata]]
    
    init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
        
        metadata = []
        
        initMedatada()
    }
    
    init(forGrid grid: Grid) {
        self.init(rows: grid.rows, columns: grid.columns)
    }
    
    private mutating func initMedatada() {
        metadata.removeAll()
        
        for _ in 0..<rows {
            metadata.append(Array(repeating: TileMetadata(), count: columns))
        }
    }
    
    private func metadata(atColumn column: Int, row: Int) -> TileMetadata {
        return metadata[row][column]
    }
    
    /// Returns a set of ports which are guaranteed to be available as a result
    /// of combination of available ports across all allowed available orientations
    /// for a tile at a specified column/row combination.
    ///
    /// - seeAlso: guaranteedUnavailablePorts(column:row:)
    func guaranteedAvailablePorts(column: Int, row: Int) -> Set<EdgePort> {
        return metadata(atColumn: column, row: row).guaranteedAvailable
    }
    
    /// Returns a set of ports which are guaranteed to not be available as a
    /// result of combination of unavailable ports across all allowed orientations
    /// for a tile at a specified column/row combination.
    ///
    /// - seeAlso: guaranteedAvailablePorts(column:row:)
    func guaranteedUnavailablePorts(column: Int, row: Int) -> Set<EdgePort> {
        return metadata(atColumn: column, row: row).guaranteedUnavailable
    }
}

private extension GridMetadata {
    /// Metadata for a tile on a grid
    struct TileMetadata {
        var guaranteedAvailable: Set<EdgePort> = []
        var guaranteedUnavailable: Set<EdgePort> = []
        var allowedOrientations: Set<Tile.Orientation> = Set(Tile.Orientation.allCases)
    }
}
