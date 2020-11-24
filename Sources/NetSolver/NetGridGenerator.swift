private func ascii(for char: UnicodeScalar) -> Int {
    return Int(char.value)
}

// #define index(state, a, x, y) ( a[(y) * (state)->width + (x)] )
// #define tile(state, x, y)     index(state, (state)->tiles, x, y)
// #define barrier(state, x, y)  index(state, (state)->barriers, x, y)

/// Generator for Net game grids.
public class NetGridGenerator {
    let rows: Int
    let columns: Int
    
    public init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
    }
    
    public func loadGameState(_ state: String) {
        var index = state.startIndex
        
        for y in 0..<rows {
            for x in 0..<columns {
                defer { index = state.index(after: index) }
                
                guard let char = state[index].asciiValue.map(Int.init) else { continue }
                
                let charInt: Int
                
                switch char {
                case ascii(for: "0")...ascii(for: "9"):
                    charInt = char - ascii(for: "0")
                case ascii(for: "a")...ascii(for: "f"):
                    charInt = char - ascii(for: "a") + 10
                case ascii(for: "A")...ascii(for: "F"):
                    charInt = char - ascii(for: "A") + 10
                default:
                    continue
                }
                
                
            }
        }
        
        /*
        for (y = 0; y < h; y++) {
            for (x = 0; x < w; x++) {
                if (*desc >= '0' && *desc <= '9')
                    tile(state, x, y) = *desc - '0';
                else if (*desc >= 'a' && *desc <= 'f')
                    tile(state, x, y) = *desc - 'a' + 10;
                else if (*desc >= 'A' && *desc <= 'F')
                    tile(state, x, y) = *desc - 'A' + 10;
                if (*desc)
                    desc++;
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
            }
        }
        */
    }
}

extension NetGridGenerator {
    static func tileForEncoded(_ value: Int) -> Tile? {
        /* Direction and other bitfields */
        let r = 0x01
        let u = 0x02
        let l = 0x04
        let d = 0x08
        let locked = 0x10
        let active = 0x20
        
        if value == 0 {
            return nil
        }
        
        return nil
    }
}
