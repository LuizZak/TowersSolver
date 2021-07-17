private func ascii(for char: UnicodeScalar) -> Int {
    return Int(char.value)
}

/// Generator for Net game grids.
public class NetGridGenerator {
    public let rows: Int
    public let columns: Int
    
    internal(set) public var grid: Grid
    
    public init(rows: Int, columns: Int, wrapping: Bool = false) {
        self.rows = rows
        self.columns = columns
        
        grid = Grid(rows: rows, columns: columns, wrapping: wrapping)
    }
    
    public func loadFromGameID(_ state: String) {
        var index = state.startIndex
        
        func charAtIndex(_ index: String.Index) -> Int? {
            state[index].asciiValue.map(Int.init)
        }
        func charAtIndexMatches(_ index: String.Index, char: UnicodeScalar) -> Bool {
            charAtIndex(index) == ascii(for: char)
        }
        
        for y in 0..<rows {
            for x in 0..<columns {
                defer { _ = state.formIndex(&index, offsetBy: 1, limitedBy: state.endIndex) }
                
                guard let char = charAtIndex(index) else { continue }
                
                let charInt: Int
                
                switch char {
                // Tiles
                case ascii(for: "0")...ascii(for: "9"):
                    charInt = char - ascii(for: "0")
                case ascii(for: "a")...ascii(for: "f"):
                    charInt = char - ascii(for: "a") + 10
                case ascii(for: "A")...ascii(for: "F"):
                    charInt = char - ascii(for: "A") + 10
                    
                default:
                    charInt = 0
                }
                
                // Barriers
                while index < state.index(before: state.endIndex),
                      charAtIndexMatches(state.index(after: index), char: "h")
                        || charAtIndexMatches(state.index(after: index), char: "v") {
                    
                    // TODO: Add support for barriers
                    // Since we don't support barriers yet, just skip the
                    // character, for now.
                    index = state.index(after: index)
                    
                    // Original barrier decoding code from Simon Tatham's
                    // Puzzle Collection's net.c source code, here for reference
                    // for decoding barriers later
                    /*
                     while (*desc == 'h' || *desc == 'v') {
                         int x2, y2, d1, d2;
                         if (*desc == 'v')
                             d1 = R;
                         else
                             d1 = D;
                         
                         OFFSET(x2, y2, x, y, d1, state);
                         d2 = F(d1);
                         
                         barrier(state, x, y) |= d1;
                         barrier(state, x2, y2) |= d2;
                         
                         desc++;
                     }
                     */
                }
                
                if let tile = NetGridGenerator.tileFromEncoded(charInt) {
                    grid[row: y, column: x] = tile
                }
            }
        }
    }
}

extension NetGridGenerator {
    static func tileFromEncoded(_ value: Int) -> Tile? {
        let edgePorts = edgePortsFromEncoded(value)
        guard !edgePorts.isEmpty && edgePorts.count < 4 else {
            return nil
        }
        
        guard var tile = Tile.fromPorts(edgePorts) else {
            return nil
        }
        
        if value & EncodedTileConstants.lockedBitcode != 0 {
            tile.isLocked = true
        }
        
        return tile
    }
    
    static func edgePortsFromEncoded(_ value: Int) -> Set<EdgePort> {
        var ports: Set<EdgePort> = []
        
        if value & EncodedTileConstants.rightBitcode != 0 {
            ports.insert(.right)
        }
        if value & EncodedTileConstants.upBitcode != 0 {
            ports.insert(.top)
        }
        if value & EncodedTileConstants.leftBitcode != 0 {
            ports.insert(.left)
        }
        if value & EncodedTileConstants.downBitcode != 0 {
            ports.insert(.bottom)
        }
        
        return ports
    }
}

/// Constants for tile  decoding
enum EncodedTileConstants {
    static let rightBitcode = 0x01
    static let upBitcode = 0x02
    static let leftBitcode = 0x04
    static let downBitcode = 0x08
    static let lockedBitcode = 0x10
}
