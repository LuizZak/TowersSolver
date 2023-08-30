/// A Pattern game tile.
public struct PatternTile: Hashable {
    /// The state for this tile.
    public var state: State

    /// Describes the state of a tile in a pattern grid.
    public enum State {
        /// Tile is in undecided state.
        case undecided
        
        /// Tile is light.
        case light

        /// Tile is dark.
        case dark

        /// Returns `true` iff `self == .light`.
        @inlinable
        public var isSeparator: Bool {
            self == .light
        }
    }
}
