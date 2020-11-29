/// Checks ports of an endpoint against other neighboring endpoints or barriers,
/// marking the tile as solved if all but one port point to a non-barrier and/or
/// non-endpoint.
struct EndPointNeighborsSolverStep: NetSolverStep {
    var column: Int
    var row: Int
    
    func apply(on grid: Grid, delegate: NetSolverDelegate) -> [GridAction] {
        let tile = grid[row: row, column: column]
        if tile.isLocked {
            return []
        }
        
        let unavailable =
            delegate
            .unavailableIncomingPortsForTile(atColumn: column, row: row)
        
        let available =
            Set(EdgePort.allCases)
            .subtracting(unavailable)
        
        let surrounding =
            grid
            .surroundingTiles(column: column, row: row)
            .filter { available.contains($0.edge) }
        
        // Restrict possible rotations away from neighboring end-points and barriers
        let endPointOrientations =
            surrounding
            .filter { $0.tile.kind == .endPoint }
            .map { $0.edge.asOrientation }
        
        return [
            .markImpossibleOrientations(column: column, row: row, Set(endPointOrientations))
        ]
    }
}
