extension Tile {
    /// Returns a list of orientations where this tile has the provided set of
    /// ports available.
    ///
    /// - Parameters:
    ///   - excludedPorts: Ports where resulting orientation of the specified
    ///   kind are available
    /// - Returns: A list of orientations where this tile offers the provided
    /// ports
    func orientations(includingPorts includedPorts: Set<EdgePort>) -> Set<Orientation> {
        return Self.orientationsForKind(kind: kind, includingPorts: includedPorts)
    }

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

    /// Returns a list of orientations where a specified kind of tile has the
    /// provided set of ports available.
    ///
    /// - Parameters:
    ///   - kind: The kind of the tile to test
    ///   - includedPorts: Ports where resulting orientation of the specified
    ///   kind are available
    /// - Returns: A list of orientations where the tile kind offers the provided
    /// ports
    static func orientationsForKind(kind: Kind, includingPorts includedPorts: Set<EdgePort>) -> Set<
        Orientation
    > {
        return Set(
            Orientation.allCases.filter { orientation -> Bool in
                let tile = Tile(kind: kind, orientation: orientation)
                return tile.ports.isSuperset(of: includedPorts)
            }
        )
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
    static func orientationsForKind(kind: Kind, excludingPorts excludedPorts: Set<EdgePort>) -> Set<
        Orientation
    > {
        return Set(
            Orientation.allCases.filter { orientation -> Bool in
                let tile = Tile(kind: kind, orientation: orientation)
                return excludedPorts.isDisjoint(with: tile.ports)
            }
        )
    }
}

extension Tile.Orientation {
    /// Returns the edge port equivalent to this edge port, rotated counter-clockwise
    /// 90 degrees
    var leftRotated: Tile.Orientation {
        switch self {
        case .north: return .west
        case .east: return .north
        case .south: return .east
        case .west: return .south
        }
    }

    /// Returns the edge port equivalent to this edge port, rotated clockwise
    /// 90 degrees
    var rightRotated: Tile.Orientation {
        switch self {
        case .north: return .east
        case .east: return .south
        case .south: return .west
        case .west: return .north
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

extension Set where Element == Tile.Orientation {
    /// From this set of orientations, returns a normalized set where no two
    /// orientations result in the same set of ports being available, when the
    /// orientations are used to rotate a tile of a given kind.
    ///
    /// A preference for picking north/east over south/west is present, in case
    /// they represent the same set of ports.
    func normalizedByPortSet(onTileKind kind: Tile.Kind) -> Set<Tile.Orientation> {
        var presentPortSets: Set<Set<EdgePort>> = []

        // Pair up orientations with their respective ports
        var portsSetPair = self.map {
            (orientation: $0, portSet: Tile.portsForTile(kind: kind, orientation: $0))
        }
        portsSetPair.sort(by: { $0.0.rawValue < $1.0.rawValue })

        var resultOrientations: Set<Tile.Orientation> = []

        // For each orientation -> port set, insert into the resulting set only
        // if no previous orientation provided the same set of ports.
        for pair in portsSetPair where !presentPortSets.contains(pair.portSet) {
            presentPortSets.insert(pair.portSet)
            resultOrientations.insert(pair.orientation)
        }

        return resultOrientations
    }
}
