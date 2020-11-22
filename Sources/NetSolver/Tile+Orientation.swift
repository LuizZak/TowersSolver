extension Tile {
    /// Returns a list of orientations where a specified kind of tile does not
    /// have the provided set of ports available.
    ///
    /// - Parameters:
    ///   - kind: The kind of the tile to test
    ///   - excludingPorts: Ports where resulting orientation of the specified
    ///   kind are not available
    /// - Returns: A list of orientations where the tile kind does not offer
    /// the provided ports
    static func orientationsForKind(kind: Kind, excludingPorts: Set<EdgePort>) -> [Orientation] {
        return Orientation.allCases.filter { orientation -> Bool in
            let tile = Tile(kind: kind, orientation: orientation)
            return excludingPorts.isDisjoint(with: tile.ports)
        }
    }
}
