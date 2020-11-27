@testable import NetSolver

/// Grid builder that can be used to create grid setups for unit tests
class TestGridBuilder {
    let generator: NetGridGenerator
    
    init(columns: Int, rows: Int) {
        self.generator = NetGridGenerator(rows: rows, columns: columns)
    }
    
    func fromGameID(_ gameId: String) -> TestGridBuilder {
        generator.loadFromGameID(gameId)
        return self
    }
    
    /// Sets all tiles of the grid to the specified tile kind and orientation
    /// combination.
    /// Other information about the tiles, like locked state, is not reset.
    func setAllTiles(kind: Tile.Kind, orientation: Tile.Orientation) -> TestGridBuilder {
        for row in 0..<generator.rows {
            for column in 0..<generator.columns {
                generator.grid[row: row, column: column].kind = kind
                generator.grid[row: row, column: column].orientation = orientation
            }
        }
        
        return self
    }
    
    func setTile(_ column: Int, _ row: Int, kind: Tile.Kind, orientation: Tile.Orientation) -> TestGridBuilder {
        self.setTileKind(column, row, kind: kind)
            .setTileOrientation(column, row, orientation: orientation)
    }
    
    func setTileKind(_ column: Int, _ row: Int, kind: Tile.Kind) -> TestGridBuilder {
        generator.grid[row: row, column: column].kind = kind
        
        return self
    }
    
    func setTileOrientation(_ column: Int, _ row: Int, orientation: Tile.Orientation) -> TestGridBuilder {
        generator.grid[row: row, column: column].orientation = orientation
        
        return self
    }
    
    func lockTile(atColumn column: Int, row: Int) -> TestGridBuilder {
        generator.grid[row: row, column: column].isLocked = true
        
        return self
    }
    
    func unlockTile(atColumn column: Int, row: Int) -> TestGridBuilder {
        generator.grid[row: row, column: column].isLocked = false
        
        return self
    }
    
    func setWrapping(_ wrapping: Bool) -> TestGridBuilder {
        generator.grid.wrapping = wrapping
        
        return self
    }
    
    func build() -> Grid {
        generator.grid
    }
}
