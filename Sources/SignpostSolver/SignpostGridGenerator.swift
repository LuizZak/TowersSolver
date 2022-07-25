/// A Signpost grid generator
public class SignpostGridGenerator {
    private static let dirMax = 9

    public let rows: Int
    public let columns: Int

    internal(set) public var grid: Grid

    public init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns

        grid = Grid(rows: rows, columns: columns)
    }

    public func loadFromGameID(_ gameId: String) {
        var index = gameId.startIndex

        func ascii(for char: UnicodeScalar) -> Int {
            return Int(char.value)
        }
        func charAtIndex(_ index: String.Index) -> Int? {
            gameId[index].asciiValue.map(Int.init)
        }
        func charAtIndexMatches(_ index: String.Index, char: UnicodeScalar) -> Bool {
            charAtIndex(index) == ascii(for: char)
        }

        var num: Int = 0, i: Int = 0

        while index < gameId.endIndex {
            defer { _ = gameId.formIndex(&index, offsetBy: 1, limitedBy: gameId.endIndex) }
            
            if i >= grid.tileCount {
                print("Game description longer than expected")
                return
            }

            guard let char = charAtIndex(index) else { continue }

            let charInt: Int?

            switch char {
            // Tiles
            case ascii(for: "0")...ascii(for: "9"):
                charInt = char - ascii(for: "0")

            default:
                charInt = nil
            }

            if let charInt = charInt {
                num = num * 10 + charInt

                if num > grid.tileCount {
                    print("Number out of range of grid tiles: \(num)")
                    return
                }
            } else if let orientation = Tile.Orientation(rawValue: char - ascii(for: "a")) {
                if num > 0 {
                    if num == 1 {
                        grid[sequential: i].isStartTile = true
                    }
                    if num == grid.tileCount {
                        grid[sequential: i].isEndTile = true
                    }

                    grid[sequential: i].solution = num
                    num = 0
                }

                grid[sequential: i].orientation = orientation
                
                i += 1
            } else {
                print("Invalid character in game description: \(char)")
                return
            }
        }

        /*
        char c;
        int num = 0, i = 0;

        while (*desc) {
            if (i >= state->n) {
                msg = _("Game description longer than expected");
                goto done;
            }

            c = *desc;
            if (isdigit((unsigned char)c)) {
                num = (num*10) + (int)(c-'0');
                if (num > state->n) {
                    msg = _("Number out of range");
                    goto done;
                }
            } else if ((c-'a') >= 0 && (c-'a') < DIR_MAX) {
                state->nums[i] = num;
                state->flags[i] = num ? FLAG_IMMUTABLE : 0;
                num = 0;

                state->dirs[i] = c - 'a';
                i++;
            } else if (!*desc) {
                msg = _("Game description shorter than expected");
                goto done;
            } else {
                msg = _("Invalid character in game description");
                goto done;
            }
            desc++;
        }
        if (i < state->n) {
            msg = _("Game description shorter than expected");
            goto done;
        }
        */
    }
}
