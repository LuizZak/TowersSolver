import Geometry

/// A Signpost tile
public struct Tile: Equatable {
    /// Represents the orientation of the tile.
    public var orientation: Orientation

    /// A solution for this tile's signpost number.
    public var solution: Int?

    /// The connection state for this tile.
    public var connectionState: ConnectionState = .unconnected

    public var connectedTo: Coordinates? {
        get {
            switch connectionState {
            case .unconnected:
                return nil
            case .connectedTo(let coords):
                return coords
            }
        }
        set {
            if let newValue = newValue {
                connectionState = .connectedTo(newValue)
            } else {
                connectionState = .unconnected
            }
        }
    }

    /// `true` if the tile is the start signpost for the grid it is contained within.
    public var isStartTile: Bool

    /// `true` if the tile is the end signpost for the grid it is contained within.
    public var isEndTile: Bool

    /// Represents the connection state for this tile.
    public enum ConnectionState: Hashable {
        case unconnected
        case connectedTo(Coordinates)
    }
}
