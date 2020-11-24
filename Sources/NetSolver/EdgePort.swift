/// Represents an edge port, where a line can connect to.
public enum EdgePort: Int {
    case top
    case right
    case bottom
    case left
}

extension EdgePort: Comparable {
    public static func < (lhs: EdgePort, rhs: EdgePort) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

public extension EdgePort {
    /// Returns the opposite edge for this edge port, that is, inverting top
    /// to bottom/left to right and vice-versa
    var opposite: EdgePort {
        switch self {
        case .top:    return .bottom
        case .right:  return .left
        case .bottom: return .top
        case .left:   return .right
        }
    }
    
    /// Returns the edge port equivalent to this edge port, rotated counter-clockwise
    /// 90 degrees
    var leftRotated: EdgePort {
        switch self {
        case .top:    return .left
        case .right:  return .top
        case .bottom: return .right
        case .left:   return .bottom
        }
    }
    
    /// Returns the edge port equivalent to this edge port, rotated clockwise
    /// 90 degrees
    var rightRotated: EdgePort {
        switch self {
        case .top:    return .right
        case .right:  return .bottom
        case .bottom: return .left
        case .left:   return .top
        }
    }
}

public extension EdgePort {
    /// Returns the equivalent orientation for this edge port
    var asOrientation: Tile.Orientation {
        switch self {
        case .top:
            return .north
        case .right:
            return .east
        case .bottom:
            return .south
        case .left:
            return .west
        }
    }
}

public extension Tile.Orientation {
    /// Returns the equivalent edge port for this orientation
    var asEdgePort: EdgePort {
        switch self {
        case .north:
            return .top
        case .east:
            return .right
        case .south:
            return .bottom
        case .west:
            return .left
        }
    }
}
