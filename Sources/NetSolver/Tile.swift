/// A Net tile
public struct Tile {
    public var kind: Kind
    public var orientation: Orientation
    
    /// Whether this tile has been marked as locked by the solver, indicating
    /// that it has been solved.
    public var isLocked: Bool
    
    public init(kind: Kind, orientation: Orientation, isLocked: Bool = false) {
        self.kind = kind
        self.orientation = orientation
        self.isLocked = isLocked
    }
}

public extension Tile {
    /// Represents the type of a Net tile.
    ///
    /// - `I`: The straight line piece, connecting two opposing edges.
    /// - `L`: The corner piece, connecting two adjacent edges.
    /// - `T`: The 'T' piece, connecting three edges.
    /// - `endPoint`: The square piece with only one connected edge, representing
    /// a dead end.
    ///
    /// - seealso: `Orientation`
    enum Kind {
        case I
        case L
        case T
        case endPoint
    }
    
    /// Represents the orientation of a Net tile.
    ///
    /// - For I pieces, north and south represent a vertical orientation, while
    /// east and west represent the vertical orientation;
    /// - For L pieces, north has the top and right connected, with east, south
    /// and west rotating the tile 90 degrees clockwise;
    /// - For T pieces, north has the left, top and right sides connected, with
    /// east, south and west rotating the tile 90 degrees clockwise;
    /// - For end pieces, the orientation represent the side of the tile with
    /// the connection exposed.
    ///
    /// - seealso: `Kind`
    enum Orientation: Int, CaseIterable, CustomStringConvertible {
        case north
        case east
        case south
        case west
        
        public var description: String {
            switch self {
            case .north:
                return "north"
            case .east:
                return "east"
            case .south:
                return "south"
            case .west:
                return "west"
            }
        }
    }
}
