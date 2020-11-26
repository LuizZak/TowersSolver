extension Tile {
    /// Returns a list of orientations where this tile does not have the provided
    /// set of ports available.
    ///
    /// - Parameters:
    ///   - excludedPorts: Ports where resulting orientation of the specified
    ///   kind are not available
    /// - Returns: A list of orientations where this tile does not offer the
    /// provided ports
    func orientations(excludingPorts excludedPorts: Set<EdgePort>) -> Set<Orientation> {
        return Self.orientationsForKind(kind: kind, excludingPorts: excludedPorts)
    }
    
    /// Returns a list of orientations where a specified kind of tile does not
    /// have the provided set of ports available.
    ///
    /// - Parameters:
    ///   - kind: The kind of the tile to test
    ///   - excludedPorts: Ports where resulting orientation of the specified
    ///   kind are not available
    /// - Returns: A list of orientations where the tile kind does not offer
    /// the provided ports
    static func orientationsForKind(kind: Kind, excludingPorts excludedPorts: Set<EdgePort>) -> Set<Orientation> {
        return Set(Orientation.allCases.filter { orientation -> Bool in
            let tile = Tile(kind: kind, orientation: orientation)
            return excludedPorts.isDisjoint(with: tile.ports)
        })
    }
}

extension Tile.Orientation {
    /// Returns the edge port equivalent to this edge port, rotated counter-clockwise
    /// 90 degrees
    var leftRotated: Tile.Orientation {
        switch self {
        case .north: return .west
        case .east:  return .north
        case .south: return .east
        case .west:  return .south
        }
    }
    
    /// Returns the edge port equivalent to this edge port, rotated clockwise
    /// 90 degrees
    var rightRotated: Tile.Orientation {
        switch self {
        case .north: return .east
        case .east:  return .south
        case .south: return .west
        case .west:  return .north
        }
    }
    
    /// Rotates this orientation in-place counter-clockwise.
    mutating func rotateLeft() {
        self = self.leftRotated
    }
    
    /// Rotates this orientation in-place clockwise.
    mutating func rotateRight() {
        self = self.rightRotated
    }
}
