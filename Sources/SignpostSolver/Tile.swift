/// A Signpost tile
public struct Tile: Equatable {
    /// Represents the orientation of the tile.
    public var orientation: Orientation

    /// A solution for this tile's signpost number.
    public var solution: Int?

    /// `true` if the tile is the start signpost for the grid it is contained within.
    public var isStartTile: Bool

    /// `true` if the tile is the end signpost for the grid it is contained within.
    public var isEndTile: Bool
}
