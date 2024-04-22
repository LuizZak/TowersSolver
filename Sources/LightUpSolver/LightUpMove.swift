import Geometry

/// Represents an atomic change on a light up grid.
public enum LightUpMove {
    /// Returns the list of affected tile coordinates that are referenced by this
    /// move.
    public var affectedTileCoordinates: [LightUpGrid.CoordinateType] {
        switch self {
        case .markAsMarker(let gridTiles),
            .markAsLight(let gridTiles),
            .markAsEmpty(let gridTiles):

            return gridTiles.coordinates
        }
    }

    /// A move where a subset of grid tiles are marked as a maker.
    case markAsMarker(_ gridTiles: GridTileView<LightUpGrid>)

    /// A move where a subset of grid tiles are marked as light.
    case markAsLight(_ gridTiles: GridTileView<LightUpGrid>)

    /// A move where a subset of grid tiles are marked as empty.
    case markAsEmpty(_ gridTiles: GridTileView<LightUpGrid>)

    /// Returns the result of applying this move to given grid.
    public func applied(to grid: LightUpGrid) -> LightUpGrid {
        var result = grid

        switch self {
        case .markAsMarker(let tiles):
            for coord in tiles.coordinates {
                switch result[coord].state {
                case .space(.empty):
                    result[coord].state = .space(.marker)
                
                default:
                    break
                }
            }
        
        case .markAsLight(let tiles):
            for coord in tiles.coordinates {
                switch result[coord].state {
                case .space(.empty):
                    result[coord].state = .space(.light)
                
                default:
                    break
                }
            }
        
        case .markAsEmpty(let tiles):
            for coord in tiles.coordinates {
                switch result[coord].state {
                case .space:
                    result[coord].state = .space(.empty)
                
                default:
                    break
                }
            }
        }

        return result
    }
}

extension Sequence where Element == LightUpMove {
    /// Returns the result of applying each `LightUpMove` in this sequence to a
    /// given grid.
    public func applied(to grid: LightUpGrid) -> LightUpGrid {
        self.reduce(grid, { $1.applied(to: $0) })
    }
}
