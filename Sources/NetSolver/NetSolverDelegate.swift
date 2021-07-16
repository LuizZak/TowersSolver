/// Delegate for a solver which can be used to query information about a grid and
/// enqueuesolver steps.
protocol NetSolverDelegate {
    /// The metadata for the current solver grid.
    var metadata: GridMetadata { get }
    
    /// Enqueues a given solver step so it can be performed later.
    func enqueue(_ step: NetSolverStep)
    
    /// Returns a list of networks for the currently locked tile on the grid
    func lockedTileNetworks() -> [Network]
    
    /// Returns a set of possible orientations for a tile at a given column/row
    /// combination.
    ///
    /// Possible orientation sets for tiles start as all four cardinal directions,
    /// and are reduced as solver steps make passes through a grid via
    /// ``GridAction.markImpossibleOrientations``, being reduced to only one
    /// orientation when a tile is solved.
    func possibleOrientationsForTile(atColumn column: Int, row: Int) -> Set<Tile.Orientation>
    
    /// Returns a set of ports that are required to be available for a tile at a
    /// given column/row combination.
    ///
    /// Ports that are required to be available are influenced by neighboring
    /// tiles that are either locked or have orientation restrictions which force
    /// the port pointing to the tile to always be required.
    func requiredPortsForTile(atColumn column: Int, row: Int) -> Set<EdgePort>
    
    /// Returns a set of ports that are unavailable for a tile at a given column/row
    /// combination.
    ///
    /// Ports can be unavailable in case a barrier is currently present between
    /// a surrounding tile, or if a surrounding tile is locked in an orientation
    /// which has no connecting ports available to the tile at the given column/row.
    func unavailableIncomingPortsForTile(atColumn column: Int, row: Int) -> Set<EdgePort>
    
    /// Returns the set of outgoing ports which are guaranteed to be available
    /// for a tile at a given column/row combination.
    ///
    /// Guaranteed outgoing ports include ones that where marked on the metadata,
    /// or outgoing ports for locked tiles.
    func guaranteedOutgoingAvailablePortsForTile(atColumn column: Int, row: Int) -> Set<EdgePort>
    
    /// Returns the set of outgoing ports which are guaranteed to be unavailable
    /// for a tile at a given column/row combination.
    ///
    /// Guaranteed outgoing ports include ones that where marked on the metadata,
    /// or missing outgoing ports for locked tiles.
    func guaranteedOutgoingUnavailablePortsForTile(atColumn column: Int, row: Int) -> Set<EdgePort>
}
