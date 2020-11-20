/// A Net tile
public struct Tile {
    public var orientation: Orientation
    public var kind: Kind
    
    public init(orientation: Orientation, kind: Kind) {
        self.orientation = orientation
        self.kind = kind
    }
}

public extension Tile {
    /// Represents the orientation of a Net tile.
    ///
    /// - For I pieces, north and south represent a vertical orientation, while
    /// east and west represent the vertical orientation;
    /// - For L pieces, north has the corner piece rotated with the top and right
    /// connected, with east, south and west rotating the tile 90 degrees
    /// clockwise;
    /// - For T pieces, north has the left, top and right sides connected, with
    /// east, south and west rotating the tile 90 degrees;
    /// - For square pieces, the orientation represent the side of the tile with
    /// the connection exposed.
    ///
    /// - seealso: `Kind`
    enum Orientation {
        case north
        case east
        case south
        case west
    }
    
    /// Represents the type of a Net tile.
    ///
    /// - `I`: The straight line piece, connecting two opposing edges.
    /// - `L`: The corner piece, connecting two adjacent edges.
    /// - `T`: The 'T' piece, connecting three edges.
    /// - `square`: The square piece with only one connected edge, representing
    /// a 'deadend'.
    ///
    /// - seealso: `Orientation`
    enum Kind {
        case I
        case L
        case T
        case square
    }
}
