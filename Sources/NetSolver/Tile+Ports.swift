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
    
    /// Returns a tile with a kind and orientation that matches the input ports.
    /// If the array of ports contains either zero, or greater than three indices
    /// the result is nil.
    static func tileForPorts(_ ports: [EdgePort]) -> Tile? {
        // Remove duplicates and sort result to simplify conversion
        let normalizedPorts = Set(ports).sorted()
        
        let kind: Tile.Kind
        let orientation: Tile.Orientation
        
        switch normalizedPorts.count {
        // End-points
        case 1:
            kind = .endPoint
            orientation = normalizedPorts[0].asOrientation
            
        // Corners and straight tile
        case 2:
            switch (normalizedPorts[0], normalizedPorts[1]) {
            // Corners
            case (.top, .right), (.right, .top):
                kind = .L
                orientation = .north
            case (.right, .bottom), (.bottom, .right):
                kind = .L
                orientation = .east
            case (.bottom, .left), (.left, .bottom):
                kind = .L
                orientation = .south
            case (.left, .top), (.top, .left):
                kind = .L
                orientation = .west
                
            // Straight pieces
            case (.top, .bottom), (.bottom, .top):
                kind = .I
                orientation = .north
            case (.right, .left), (.left, .right):
                kind = .I
                orientation = .east
            default:
                return nil
            }
            
        // Triple tile
        case 3:
            kind = .T
            
            switch (normalizedPorts[0], normalizedPorts[1], normalizedPorts[2]) {
            case (.top, .right, .left):
                orientation = .north
            case (.top, .right, .bottom):
                orientation = .east
            case (.right, .bottom, .left):
                orientation = .south
            case (.top, .bottom, .left):
                orientation = .west
            default:
                return nil
            }
            
        default:
            return nil
        }
        
        return Tile(kind: kind, orientation: orientation)
    }
}
