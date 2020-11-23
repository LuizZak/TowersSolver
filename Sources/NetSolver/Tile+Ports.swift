extension Tile {
    /// Returns the list of edge ports that are available for this tile
    var ports: [EdgePort] {
        return Self.portsForTile(kind: kind, orientation: orientation)
    }
}
    
extension Tile {
    
    /// Returns the list of edge ports that are available for a given combination
    /// of tile kind and orientation
    static func portsForTile(kind: Tile.Kind, orientation: Tile.Orientation) -> [EdgePort] {
        let edgePort = orientation.asEdgePort
        
        switch kind {
        // I piece
        case .I:
            return [edgePort, edgePort.opposite]
        // L piece
        case .L:
            return [edgePort, edgePort.rightRotated]
        // T piece
        case .T:
            return [edgePort.leftRotated, edgePort, edgePort.rightRotated]
        // End piece
        case .endPoint:
            return [edgePort]
        }
    }
}
