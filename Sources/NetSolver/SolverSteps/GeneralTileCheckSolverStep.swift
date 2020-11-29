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
        
        let remainingSet =
            tile.orientations(includingPorts: required)
            .intersection(
                tile.orientations(excludingPorts: unavailableOutgoing)
            )
            
        let reversedRemaining =
            Set(Tile.Orientation.allCases)
            .subtracting(remainingSet)
            .normalizedByPortSet(onTileKind: tile.kind)
        
        if !reversedRemaining.isEmpty {
            return [
                .markImpossibleOrientations(column: column, row: row, reversedRemaining)
            ]
        }
        
        return []
    }
}
