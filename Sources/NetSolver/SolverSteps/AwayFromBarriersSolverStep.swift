/// Solver step which rotates tiles away from barriers, as well as the map edge,
/// in case the grid is non-wrapping.
struct AwayFromBarriersSolverStep: NetSolverStep, Equatable {
    var column: Int
    var row: Int

    func apply(on grid: Grid, delegate: NetSolverDelegate) -> [GridAction] {
        let tile = grid[row: row, column: column]
        if tile.isLocked {
            return []
        }

        let barriers = grid.barriersForTile(atColumn: column, row: row)

        let availableOrientations = tile.orientations(excludingPorts: barriers)

        // If no ports are available, mark this grid as invalid
        guard !availableOrientations.isEmpty else {
            return [.markAsInvalid]
        }

        // Check if only one orientation is available
        if availableOrientations.count == 1, let orientation = availableOrientations.first {
            return [
                .lockOrientation(column: column, row: row, orientation: orientation)
            ]
        }

        // If the available orientations all coincide with the same ports
        // being made available (like line pieces which are equivalent across
        // 180º rotations), mark any of the orientations as correct, picking
        // by precedence: north > east > south > west among the available
        // orientations.
        let portsSet = availableOrientations.normalizedByPortSet(onTileKind: tile.kind)

        // If ports set contains one element, it indicates all orientations provide
        // the same set of ports, and are thus equivalent.
        if portsSet.count == 1,
            let orientation = availableOrientations.min(by: { $0.rawValue < $1.rawValue })
        {
            return [
                .lockOrientation(column: column, row: row, orientation: orientation)
            ]
        }

        // Remove from the available set of orientations any orientation that is
        // blocked by barriers
        let currentOrientations = delegate.possibleOrientationsForTile(atColumn: column, row: row)

        let unavailable = currentOrientations.subtracting(availableOrientations)

        if !unavailable.isEmpty {
            return [
                .markImpossibleOrientations(column: column, row: row, unavailable)
            ]
        }

        return []
    }
}
