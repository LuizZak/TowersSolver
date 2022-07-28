/// Metadata used alongside grids to store solver logic-specific information
struct GridMetadata {
    private let rows: Int
    private let columns: Int

    /// Tile metadata, stored as [rows][columns]
    private var metadata: [[TileMetadata]]

    init(forGrid grid: Grid) {
        rows = grid.rows
        columns = grid.columns
        metadata = []

        initMetadata(grid: grid)
    }

    private mutating func initMetadata(grid: Grid) {
        metadata.removeAll()

        for row in 0..<rows {
            var r: [TileMetadata] = []

            for column in 0..<columns {
                r.append(TileMetadata(tile: grid[row: row, column: column]))
            }

            metadata.append(r)
        }
    }

    private func metadata(atColumn column: Int, row: Int) -> TileMetadata {
        return metadata[row][column]
    }

    mutating func setPossibleOrientations(
        column: Int,
        row: Int,
        _ orientations: Set<Tile.Orientation>
    ) {
        metadata[row][column].possibleOrientations = orientations
    }

    mutating func subtractPossibleOrientations(
        column: Int,
        row: Int,
        _ orientations: Set<Tile.Orientation>
    ) {
        metadata[row][column].possibleOrientations.subtract(orientations)
    }

    /// Returns the list of possible orientations for a tile at a given column/row
    /// combination.
    func possibleOrientations(column: Int, row: Int) -> Set<Tile.Orientation> {
        return metadata(atColumn: column, row: row).possibleOrientations
    }
}

extension GridMetadata {
    /// Metadata for a tile on a grid
    fileprivate struct TileMetadata {
        /// Kind of tile
        var kind: Tile.Kind

        /// Set of possible orientations for this tile
        var possibleOrientations: Set<Tile.Orientation> = Set(Tile.Orientation.allCases)

        init(tile: Tile) {
            kind = tile.kind
        }
    }
}
