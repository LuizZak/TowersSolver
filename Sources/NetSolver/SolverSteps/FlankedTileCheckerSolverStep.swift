/// Analyzes grid configurations where a tile is flanked by three end points such
/// as bellow:
///
///                    ...
///    ─┼───────┼───┼───┼───────┼───┼───┼─
///     │       │   │ *1│       │   │   │ 
///     ├───■   ├───┤   │   ■   │   ╰───┤ 
///     │       │   │   │   │   │       │ 
/// ...─┼───────┼───┴───┼───┼───┼───────┼─ ...
///     │       │       │   │ *2│       │ 
///     ├───╮   ├───■   ├───╯   │   ■   │ 
///     │   │   │       │       │   │   │ 
///    ─┼───┴───┼───────┼───────┼───┴───┼─
///                    ...
///
/// In cases such as these, the triple tile (*1) can disconsider a south (T-shaped)
/// orientation, while the curved tile (*2) can disconsider orientations that
/// include an exit port at the top, as both of those cases would result in short
/// fully closed networks that are invalid.
/// 
/// This solver step also deals with I tiles flanked by three tiles by locking
/// them according to which side avoids connecting the two adjacent end points
/// directly.
///                    ...
///    ─┼───────┼───┼───┼───────┼─
///     │       │   │ *1│       │
///     ├───■   │   │   │   ■   │
///     │       │   │   │   │   │
/// ...─┼───────┼───┴───┼───┼───┼─ ...
///     │       │       │   │   │
///     ├───╮   ├───■   ├───╯   │
///     │   │   │       │       │
///    ─┼───┴───┼───────┼───────┼─
///                    ...
///

public class FlankedTileCheckerSolverStep: NetSolverStep {
    func apply(on grid: Grid, delegate: NetSolverDelegate) -> [GridAction] {
        var actions: [GridAction] = []

        for tileCoords in grid.tileCoordinates {
            let tile = grid[tileCoords]

            // Check if the tile is flanked by three end points surrounding it
            var surrounding = grid.surroundingTiles(column: tileCoords.column, row: tileCoords.row)
            let index = surrounding.partition(by: { $0.tile.kind != .endPoint })

            guard surrounding.count == 4 && index == 3 else {
                continue
            }

            let freeSide = surrounding[index].edge

            let orientations =
                tile.orientations(includingPorts: [freeSide])
                .normalizedByPortSet(onTileKind: tile.kind)

            // Make a quick check for an invalid grid while we're here
            let unavailable = delegate.unavailableIncomingPortsForTile(atColumn: tileCoords.column, row: tileCoords.row)
            if unavailable.contains(freeSide) {
                return [.markAsInvalid]
            }

            let possible = delegate.possibleOrientationsForTile(atColumn: tileCoords.column, row: tileCoords.row)
            if orientations == possible {
                continue
            }

            if orientations.count == 1, let o = orientations.first {
                actions.append(
                    .lockOrientation(
                        column: tileCoords.column,
                        row: tileCoords.row,
                        orientation: o
                    )
                )
            } else {
                actions.append(
                    .markImpossibleOrientations(
                        column: tileCoords.column,
                        row: tileCoords.row,
                        Set(Tile.Orientation.allCases).subtracting(orientations)
                    )
                )
            }
        }

        return actions
    }
}
