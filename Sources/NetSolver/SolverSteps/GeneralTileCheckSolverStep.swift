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
        
        let orientations =
            delegate
            .possibleOrientationsForTile(atColumn: column, row: row)
            .normalizedByPortSet(onTileKind: tile.kind)
        
        let required = delegate.requiredPortsForTile(atColumn: column, row: row)
        let unavailableOutgoing =
            delegate.guaranteedOutgoingUnavailablePortsForTile(atColumn: column, row: row)
            .union(delegate.unavailableIncomingPortsForTile(atColumn: column, row: row))
        
        // If required set has items in common with guaranteed unavailable set,
        // the grid is invalid.
        if !required.isDisjoint(with: unavailableOutgoing) {
            delegate.markIsInvalid()
            return []
        }
        
        // Detect cases where only a single orientation satisfies all required
        // ports at the same time
        let satisfyingOrientations =
            orientations.filter {
                Tile.portsForTile(kind: tile.kind, orientation: $0)
                    .isSuperset(of: required)
            }
        
        
        if satisfyingOrientations.count == 1, let first = satisfyingOrientations.first {
            return [
                .lockOrientation(column: column, row: row, orientation: first)
            ]
        }
        
        // Remove from possible orientations set orientations that have ports
        // that are unavailable
        let toExclude =
            tile
            .orientations(excludingPorts: unavailableOutgoing)
            .symmetricDifference(orientations)
        
        // If no orientations remain, mark as invalid
        if toExclude == Set(Tile.Orientation.allCases) {
            delegate.markIsInvalid()
            return []
        }
        // If only one orientation remains, lock tile
        if toExclude.count == Tile.Orientation.allCases.count - 1 {
            let remaining = Set(Tile.Orientation.allCases).subtracting(toExclude)
            
            if remaining.count == 1, let first = remaining.first {
                return [
                    .lockOrientation(column: column, row: row, orientation: first)
                ]
            }
        }
        if !toExclude.isEmpty {
            return [
                .markImpossibleOrientations(column: column, row: row, toExclude)
            ]
        }
        
        return []
    }
}
