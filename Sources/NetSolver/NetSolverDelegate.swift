/// Delegate for a solver which can be used to enqueue subsequent solver steps.
protocol NetSolverDelegate {
    /// The metadata for the current solver grid.
    var metadata: GridMetadata { get }
    
    /// Marks the current grid as an invalid game.
    func markIsInvalid()
    
    /// Enqueues a given solver step so it can be performed later.
    func enqueue(_ step: NetSolverStep)
}

extension NetSolverDelegate {
    /// Enqueues a tile locking operation for a tile at a given column/row,
    /// with a given final orientation.
    ///
    /// Equivalent to:
    ///
    /// ```
    /// self.enqueue(TileLockingStep(column: column, row: row, orientation: orientation))
    /// ```
    func enqueueLock(atColumn column: Int, row: Int, orientation: Tile.Orientation) {
        enqueue(TileLockingStep(column: column, row: row, orientation: orientation))
    }
}
