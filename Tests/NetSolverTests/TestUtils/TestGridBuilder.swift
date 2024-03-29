@testable import NetSolver

/// Grid builder that can be used to create grid setups for unit tests
class TestGridBuilder {
    let generator: NetGridGenerator

    init(columns: Int, rows: Int) {
        self.generator = NetGridGenerator(columns: columns, rows: rows)
    }

    func fromGameID(_ gameId: String) -> TestGridBuilder {
        generator.loadFromGameID(gameId)
        return self
    }

    /// Sets all tiles of the grid to the specified tile kind and orientation
    /// combination.
    /// Other information about the tiles, like locked state, is not reset.
    func setAllTiles(kind: Tile.Kind, orientation: Tile.Orientation) -> TestGridBuilder {
        for row in 0..<generator.rows {
            for column in 0..<generator.columns {
                generator.grid[column: column, row: row].kind = kind
                generator.grid[column: column, row: row].orientation = orientation
            }
        }

        return self
    }

    func setTile(
        _ column: Int,
        _ row: Int,
        kind: Tile.Kind,
        orientation: Tile.Orientation,
        locked: Bool = false
    ) -> TestGridBuilder {

        self.setTileKind(column, row, kind: kind)
            .setTileOrientation(column, row, orientation: orientation)
            .setTileLocked(column, row, locked)
    }

    func setTileKind(_ column: Int, _ row: Int, kind: Tile.Kind) -> TestGridBuilder {
        generator.grid[column: column, row: row].kind = kind

        return self
    }

    func setTileOrientation(_ column: Int, _ row: Int, orientation: Tile.Orientation)
        -> TestGridBuilder
    {
        generator.grid[column: column, row: row].orientation = orientation

        return self
    }

    func setTileLocked(_ column: Int, _ row: Int, _ locked: Bool) -> TestGridBuilder {
        generator.grid[column: column, row: row].isLocked = locked

        return self
    }

    func setAllTilesLocked(_ locked: Bool) -> TestGridBuilder {
        for row in 0..<generator.rows {
            for column in 0..<generator.columns {
                generator.grid[column: column, row: row].isLocked = locked
            }
        }

        return self
    }

    func lockTile(atColumn column: Int, row: Int) -> TestGridBuilder {
        return setTileLocked(column, row, true)
    }

    func unlockTile(atColumn column: Int, row: Int) -> TestGridBuilder {
        return setTileLocked(column, row, false)
    }

    func setWrapping(_ wrapping: Bool) -> TestGridBuilder {
        generator.grid.wrapping = wrapping

        return self
    }

    func build() -> Grid {
        generator.grid
    }
}
