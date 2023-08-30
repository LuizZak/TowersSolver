import Geometry

/// Represents an atomic change on a pattern grid.
public enum PatternMove {
    /// Returns the list of affected tile coordinates that are referenced by this
    /// move.
    public var affectedTileCoordinates: [PatternGrid.CoordinateType] {
        switch self {
        case .markAsDark(let gridTiles),
            .markAsLight(let gridTiles),
            .markAsUndecided(let gridTiles):
            return gridTiles.coordinates
        }
    }

    /// A move where a subset of grid tiles are marked as dark.
    case markAsDark(_ gridTiles: GridTileView<PatternGrid>)

    /// A move where a subset of grid tiles are marked as light.
    case markAsLight(_ gridTiles: GridTileView<PatternGrid>)

    /// A move where a subset of grid tiles are marked as undecided.
    case markAsUndecided(_ gridTiles: GridTileView<PatternGrid>)

    /// Returns the result of applying this move to given grid.
    public func applied(to grid: PatternGrid) -> PatternGrid {
        var result = grid

        switch self {
        case .markAsDark(let tiles):
            for coord in tiles.coordinates {
                result[coord].state = .dark
            }
        
        case .markAsLight(let tiles):
            for coord in tiles.coordinates {
                result[coord].state = .light
            }
        
        case .markAsUndecided(let tiles):
            for coord in tiles.coordinates {
                result[coord].state = .undecided
            }
        }

        return result
    }
}

extension Sequence where Element == PatternMove {
    /// Returns the result of applying each `PatternMove` in this sequence to a
    /// given grid.
    public func applied(to grid: PatternGrid) -> PatternGrid {
        self.reduce(grid, { $1.applied(to: $0) })
    }
}
