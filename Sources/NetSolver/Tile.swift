/// A Net tile
public struct Tile: Equatable {
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

extension Tile {
    /// Represents the type of a Net tile.
    ///
    /// - `I`: The straight line piece, connecting two opposing edges.
    /// - `L`: The corner piece, connecting two adjacent edges.
    /// - `T`: The 'T' piece, connecting three edges.
    /// - `endPoint`: The square piece with only one connected edge, representing
    /// a dead end.
    ///
    /// - seealso: `Orientation`
    public enum Kind {
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
    public enum Orientation: Int, CaseIterable, CustomStringConvertible {
        /// - For I piece: Vertical; connects top and bottom.
        /// - For L piece: Top and right sides connected; a letter 'L'.
        /// - For T piece: Left, top and right sides connected
        /// - For end piece: Pointing up.
        case north

        /// - For I piece: Horizontal; connects left and right.
        /// - For L piece: Right and bottom sides connected.
        /// - For T piece: Top, right and bottom sides connected.
        /// - For end piece: Pointing right
        case east

        /// - For I piece: Vertical; connects top and bottom.
        /// - For L piece: bottom and left sides connected.
        /// - For T piece: Right, bottom and left sides connected; a letter 'T'.
        /// - For end piece: Pointing down.
        case south

        /// - For I piece: Horizontal; connects left and right.
        /// - For L piece: Left and top sides connected.
        /// - For T piece: Bottom, left and top sides connected.
        /// - For end piece: Pointing left.
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
