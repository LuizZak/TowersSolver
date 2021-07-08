/// Solver step which cross-checks possible orientations with available and
/// unavailable ingoing ports, reducing the possible orientation set.
///
/// End results can be a reduction of possible orientations, or a lock in case
/// only one possible orientation was detected.
///
/// Also marks grids as invalid, in case the possible orientation set is
/// incompatible with guaranteed incoming edges or required outgoing edges.
struct GeneralTileCheckSolverStep: NetSolverStep {
    var column: Int
    var row: Int
    
    func apply(on grid: Grid, delegate: NetSolverDelegate) -> [GridAction] {
        let tile = grid[row: row, column: column]
        guard !tile.isLocked else {
            return []
        }
        
        let required = delegate.requiredPortsForTile(atColumn: column, row: row)
        let unavailableOutgoing =
            delegate.guaranteedOutgoingUnavailablePortsForTile(atColumn: column, row: row)
            .union(delegate.unavailableIncomingPortsForTile(atColumn: column, row: row))
        
        // If required set has items in common with guaranteed unavailable set,
        // the grid is invalid.
        if !required.isDisjoint(with: unavailableOutgoing) {
            return [.markAsInvalid]
        }
        
        // If unavailable incoming ports match all available orientations of a
        // tile, the grid is invalid.
        if tile.orientations(excludingPorts: unavailableOutgoing).isEmpty {
            return [.markAsInvalid]
        }
        
        let possible = delegate.possibleOrientationsForTile(atColumn: column, row: row)
        
        // Report impossible orientations of the tile based on the required ports
        let remainingSet =
            tile.orientations(includingPorts: required)
            .intersection(
                tile.orientations(excludingPorts: unavailableOutgoing)
            )
        
        let reversedRemaining = possible
            .subtracting(remainingSet)
            .normalizedByPortSet(onTileKind: tile.kind)
        
        if !reversedRemaining.isEmpty {
            // Detect ports that will become unavailable when the set of impossible
            // orientations is reported and propagate them to neighboring tiles
            var unavailablePorts = tile.commonUnavailablePorts(orientations: remainingSet)
            
            // Remove from set ports that are already reported as unavailable
            unavailablePorts
                .subtract(delegate.unavailableIncomingPortsForTile(atColumn: column, row: row))
            
            let actionsForNeighboringTiles: [GridAction] = unavailablePorts.sorted().map {
                let (col, row) = grid.columnRowByMoving(column: column, row: row, direction: $0)
                
                return .markUnavailableIngoing(column: col, row: row, [$0.opposite])
            }
            
            return [
                .markImpossibleOrientations(column: column, row: row, reversedRemaining)
            ] + actionsForNeighboringTiles
        }
        
        return []
    }
}
