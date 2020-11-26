/// A solver step that locks a tile on a specified orientation, propagating the
/// locking effect across surrounding tiles.
struct TileLockingStep: NetSolverStep, Equatable {
    var column: Int
    var row: Int
    var orientation: Tile.Orientation
    
    init(column: Int, row: Int, orientation: Tile.Orientation) {
        self.column = column
        self.row = row
        self.orientation = orientation
    }
    
    func apply(on grid: Grid, delegate: NetSolverDelegate) -> Grid {
        // If current tile is already locked at provided orientation, skip the
        // rest of locking propagation
        if grid[row: row, column: column].isLocked
            && grid[row: row, column: column].orientation == orientation {
            
            return grid
        }
        
        var grid = grid
        
        grid[row: row, column: column].orientation = orientation
        grid[row: row, column: column].isLocked = true
        
        // TODO: Propagate checks across surrounding tiles
        
        return grid
    }
}
