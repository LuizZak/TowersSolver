public extension Tile {
    /// Indicates the orientation of the arrow contained within a tile, as one of
    /// the cardinal directions as well as the diagonals.
    enum Orientation: Int, CustomStringConvertible {
        case north
        case northEast
        case east
        case southEast
        case south
        case southWest
        case west
        case northWest

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
