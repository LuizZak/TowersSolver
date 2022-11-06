/// Represents a standard set of coordinates for a tile in a regular square grid.
public struct Coordinates: Hashable {
    /// Gets a default coordinate pointing to the top-left tile in a grid.
    public static let zero: Coordinates = Coordinates(column: 0, row: 0)

    public var column: Int
    public var row: Int

    @inlinable
    public init(column: Int, row: Int) {
        self.column = column
        self.row = row
    }

    @inlinable
    public init(_ coords: (column: Int, row: Int)) {
        self.column = coords.column
        self.row = coords.row
    }
}
