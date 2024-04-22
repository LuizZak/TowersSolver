/// A tile in a light up grid.
public struct LightUpTile: Hashable {
    /// The state of this tile.
    public var state: State

    /// Returns `true` if this tile is a wall.
    /// 
    /// Alias for `self.state.isWall`.
    public var isWall: Bool {
        state.isWall
    }

    /// Returns `true` if this tile is a space, i.e. not a wall.
    /// 
    /// Alias for `self.state.isSpace`.
    public var isSpace: Bool {
        state.isSpace
    }

    /// Returns `true` if this tile is an empty tile with no marker or light.
    /// 
    /// Alias for `self.state.isEmpty`.
    public var isEmpty: Bool {
        state.isEmpty
    }

    /// Returns `true` if this tile is a marker.
    /// 
    /// Alias for `self.state.isMarker`.
    public var isMarker: Bool {
        state.isMarker
    }

    /// Returns `true` if this tile is a light.
    /// 
    /// Alias for `self.state.isLight`.
    public var isLight: Bool {
        state.isLight
    }

    /// Returns a hint associated with this tile, in case it is a wall tile.
    /// If no hint is associated, or this tile is not a wall, returns `nil`.
    /// 
    /// Alias for `self.state.hint`.
    public var hint: Int? {
        state.hint
    }

    public init(state: LightUpTile.State) {
        self.state = state
    }

    /// Represents a kind of a tile.
    public enum State: Hashable {
        /// A wall, optionally containing an integer hinting at the number of
        /// lights surrounding that wall.
        case wall(hint: Int? = nil)

        /// An empty space cell capable of containing a light, a marker, or nothing.
        case space(Contents)

        /// Returns `true` if `self` is a `State.wall` case.
        public var isWall: Bool {
            switch self {
            case .wall:
                return true
            default:
                return false
            }
        }

        /// Returns `true` if `self` is a `State.space` case.
        public var isSpace: Bool {
            return !isWall
        }

        /// Returns `true` if `self` is a `State.space(.empty)` case.
        public var isEmpty: Bool {
            switch self {
            case .space(.empty):
                return true
            default:
                return false
            }
        }

        /// Returns `true` if `self` is a `State.space(.marker)` case.
        public var isMarker: Bool {
            switch self {
            case .space(.marker):
                return true
            default:
                return false
            }
        }

        /// Returns `true` if `self` is a `State.space(.light)` case.
        public var isLight: Bool {
            switch self {
            case .space(.light):
                return true
            default:
                return false
            }
        }

        /// If this state is `State.wall()`, returns the inner hint associated
        /// value, otherwise returns `nil`.
        public var hint: Int? {
            switch self {
            case .wall(let hint):
                return hint
            default:
                return nil
            }
        }
    }

    /// Potential states for a `State.empty` tile.
    public enum Contents: Hashable {
        /// An empty cell with no marker or light. Default state for initialized
        /// empty cells.
        case empty

        /// A light.
        case light

        /// A marker. Does not alter the solution state of the grid, but can be
        /// used by a solver to indicate that this tile must not contain a light.
        case marker
    }
}

extension LightUpTile: CustomStringConvertible {
    public var description: String {
        switch state {
        case .space(.empty):
            return " "
        case .space(.light):
            return "💡"
        case .space(.marker):
            return "▪"
        case .wall(let hint?):
            return hint.description
        case .wall(nil):
            return "█"
        }
    }
}
