/// A Signpost tile
public struct Tile: Equatable {
    /// Represents the orientation of the tile.
    public var orientation: Orientation

    /// A solution for this tile's signpost number.
    public var solution: Int?

    /// The connection state for this tile.
    public var connectionState: ConnectionState = .unconnected

    public var connectedTo: Grid.Coordinates? {
        switch connectionState {
        case .unconnected:
            return nil
        case .connectedTo(let column, let row):
            return (column, row)
        }
    }

    /// `true` if the tile is the start signpost for the grid it is contained within.
    public var isStartTile: Bool

    /// `true` if the tile is the end signpost for the grid it is contained within.
    public var isEndTile: Bool

    /// Represents the connection state for this tile.
    public enum ConnectionState: Hashable {
        case unconnected
        case connectedTo(column: Int, row: Int)
    }
}
