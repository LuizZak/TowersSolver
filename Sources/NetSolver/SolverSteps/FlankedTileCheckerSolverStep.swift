/// Analyzes grid configurations where a tile is flanked by end points such as
/// bellow:
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
///                ...
///    ─┼───────┼───┼───┼───────┼─
///     │       │   │ * │       │
///     ├───■   │   │   │   ■   │
///     │       │   │   │   │   │
/// ...─┼───────┼───┴───┼───┼───┼─ ...
///     │       │       │   │   │
///     ├───╮   ├───■   ├───╯   │
///     │   │   │       │       │
///    ─┼───┴───┼───────┼───────┼─
///                ...
///
/// Also handled are cases where a corner piece is flanked by two end points:
///                ...
///    ─┼───┼───┼───────┼─
///     │   │   │       │
///     │   │   │   ■   │
///     │   │   │   │   │
/// ...─┼───┴───┼───┼───┼─ ...
///     │       │   │ * │
///     ├───■   ├───╯   │
///     │       │       │
///    ─┼───────┼───────┼─
///        ...

public class FlankedTileCheckerSolverStep: NetSolverStep {
    func apply(on grid: Grid, delegate: NetSolverDelegate) -> [GridAction] {
        var actions: [GridAction] = []

        for tileCoords in grid.tileCoordinates {
            let tile = grid[tileCoords]

            // Check if the tile is flanked by three end points surrounding it
            var surrounding = grid.surroundingTiles(column: tileCoords.column, row: tileCoords.row)
            let index = surrounding.partition(by: { $0.tile.kind != .endPoint })

            guard surrounding.count == 4 else {
                continue
            }

            let possibleOrientations: Set<Tile.Orientation>

            switch index {
            // Flanked by two end points - ignore if tile being checked is not a
            // corner piece
            case 2 where tile.kind == .L:
                let flankedSides = surrounding[..<index].map(\.edge)
                guard flankedSides.count == 2 else {
                    continue
                }

                // Only consider cases where the flanked sides are 90º of each
                // other
                guard flankedSides[0].opposite != flankedSides[1] else {
                    continue
                }

                // Consider only orientations that do not include both flanked
                // sides
                possibleOrientations =
                    Set(Tile.Orientation.allCases)
                    .normalizedByPortSet(onTileKind: tile.kind)
                    .filter { orientation in
                        Tile.portsForTile(kind: tile.kind, orientation: orientation) != Set(flankedSides)
                    }

            // Flanked by three end points
            case 3:
                let freeSide = surrounding[index].edge

                possibleOrientations =
                    tile.orientations(includingPorts: [freeSide])
                    .normalizedByPortSet(onTileKind: tile.kind)
            
                // Make a quick check for an invalid grid while we're here
                let unavailable = delegate.unavailableIncomingPortsForTile(atColumn: tileCoords.column, row: tileCoords.row)
                if unavailable.contains(freeSide) {
                    return [.markAsInvalid]
                }
            
            default:
                continue
            }

            let possible = delegate.possibleOrientationsForTile(atColumn: tileCoords.column, row: tileCoords.row)
            if possibleOrientations == possible {
                continue
            }

            if possibleOrientations.count == 1, let o = possibleOrientations.first {
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
                        Set(Tile.Orientation.allCases).subtracting(possibleOrientations)
                    )
                )
            }
        }

        return actions
    }
}
