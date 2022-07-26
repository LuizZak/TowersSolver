public extension Tile {
    /// Indicates the orientation of the arrow contained within a tile, as one of
    /// the cardinal directions as well as the diagonals.
    enum Orientation: Int, CaseIterable, CustomStringConvertible {
        case north
        case northEast
        case east
        case southEast
        case south
        case southWest
        case west
        case northWest

        /// Returns the orientation that points to the opposite direction to
        /// this orientation.
        public var reversed: Orientation {
            switch self {
            case .north:
                return .south
            case .northEast:
                return .southWest
            case .east:
                return .west
            case .southEast:
                return .northWest
            case .south:
                return .north
            case .southWest:
                return .northEast
            case .west:
                return .east
            case .northWest:
                return .southEast
            }
        }

        public var description: String {
            switch self {
            case .north:
                return "north"
            case .northEast:
                return "northEast"
            case .east:
                return "east"
            case .southEast:
                return "southEast"
            case .south:
                return "south"
            case .southWest:
                return "southWest"
            case .west:
                return "west"
            case .northWest:
                return "northWest"
            }
        }
    }
}
