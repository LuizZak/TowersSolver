/// Encodes information about actions to perform on a grid cell
enum GridAction: Equatable {
    /// Signals that a grid has an invalid state and cannot be solved
    case markAsInvalid
    
    /// Locks orientation of a tile at a given column/row
    case lockOrientation(column: Int, row: Int, orientation: Tile.Orientation)
    
    /// Marks that a tile at a given column/row to have none of the provided
    /// ports as ingoing
    case markUnavailableIngoing(column: Int, row: Int, Set<EdgePort>)
    
    /// Marks a set of orientations as not possible for a tile at a given column/row
    case markImpossibleOrientations(column: Int, row: Int, Set<Tile.Orientation>)
}
