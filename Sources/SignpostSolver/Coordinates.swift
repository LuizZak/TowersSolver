/// Represents the coordinates for a tile in a Signpost grid.
public struct Coordinates: Hashable {
    public var column: Int
    public var row: Int

    public init(column: Int, row: Int) {
        self.column = column
        self.row = row
    }

    public init(_ coords: (column: Int, row: Int)) {
        self.column = coords.column
        self.row = coords.row
    }
}
