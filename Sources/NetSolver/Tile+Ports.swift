extension Tile {
    /// Returns the set of edge ports that are available for this tile in its
    /// current orientation.
    ///
    /// - seeAlso: `kind`
    /// - seeAlso: `orientation`
    var ports: Set<EdgePort> {
        return Self.portsForTile(kind: kind, orientation: orientation)
    }
    
    /// Returns all available ports that are common across the given orientations
    /// for this tile's kind
    func commonAvailablePorts(orientations: Set<Tile.Orientation>) -> Set<EdgePort> {
        let portsSet = orientations.map { orientation -> Set<EdgePort> in
            Tile.portsForTile(kind: kind, orientation: orientation)
        }
        return portsSet.reduce(Set(EdgePort.allCases), { $0.intersection($1) })
    }
    
    /// Returns all unavailable ports that are common across the given orientations
    /// for this tile's kind
    func commonUnavailablePorts(orientations: Set<Tile.Orientation>) -> Set<EdgePort> {
        let portsSet = orientations.map { orientation -> Set<EdgePort> in
            Tile.portsForTile(kind: kind, orientation: orientation)
        }
        return portsSet.reduce(Set(EdgePort.allCases), { $0.subtracting($1) })
    }
}
    
extension Tile {
    /// Returns the set of edge ports that are available for a given combination
    /// of tile kind and orientation
    static func portsForTile(kind: Tile.Kind, orientation: Tile.Orientation) -> Set<EdgePort> {
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
    static func fromPorts(_ ports: Set<EdgePort>) -> Tile? {
        // Sort incoming ports to simplify switching over the values
        let normalizedPorts = ports.sorted()
        
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
