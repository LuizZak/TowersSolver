/// Encodes information about actions to perform on a grid cell
enum GridAction: Equatable {
    /// Locks orientation of a tile at a given column/row
    case lockOrientation(column: Int, row: Int, orientation: Tile.Orientation)
    /// Adds one or more guaranteed available ports to a tile at a given column/row
    case addGuaranteedAvailable(column: Int, row: Int, Set<EdgePort>)
    /// Removes one or more guaranteed available ports to a tile at a given column/row
    case removeGuaranteedAvailable(column: Int, row: Int, Set<EdgePort>)
    /// Adds one or more guaranteed unavailable ports to a tile at a given column/row
    case addGuaranteedUnavailable(column: Int, row: Int, Set<EdgePort>)
    /// Removes one or more guaranteed unavailable ports to a tile at a given column/row
    case removeGuaranteedUnavailable(column: Int, row: Int, Set<EdgePort>)
}


