import Console

public class LightUpGridPrinter: ConsolePrintBuffer {
    private static let _wallTileChar: Character = "█"
    private static let _emptyTileChar: Character = " "
    private static let _lightTileChar: Character = "◌"
    private static let _markTileChar: Character = "▪"

    private var _edgePatterns: [GridEdgePattern] = []

    /// Initializes a grid printer with a buffer capable of rendering the given
    /// grid with each cell has 4 characters of width and 2 of height.
    public convenience init(bufferForGrid grid: LightUpGrid) {
        self.init(
            bufferWidth: LightUpGridPrinter.bufferWidth(for: grid),
            bufferHeight: LightUpGridPrinter.bufferHeight(for: grid)
        )

        _initializeEdgePatterns()
    }

    private func _initializeEdgePatterns() {
        typealias State = GridEdgePattern.StateMatch

        func addRule(
            state: State,
            left: State = .any,
            topLeft: State = .any,
            top: State = .any,
            topRight: State = .any,
            leftEdge: Character? = nil,
            topLeftCorner: Character? = nil,
            topEdge: Character? = nil,
            topRightCorner: Character? = nil
        ) {
            
            _edgePatterns.append(
                .init(
                    stateMatch: state,
                    leftStateMatch: left,
                    topLeftStateMatch: topLeft,
                    topStateMatch: top,
                    topRightStateMatch: topRight,
                    leftEdge: leftEdge,
                    topLeftCorner: topLeftCorner,
                    topEdge: topEdge,
                    topRightCorner: topRightCorner
                )
            )
        }

        // Wall tiles
        addRule(
            state: .wall,
            left: .wall,
            leftEdge: Self._wallTileChar
        )
        addRule(
            state: .wall,
            top: .wall,
            topEdge: Self._wallTileChar
        )
        addRule(
            state: .wall,
            left: .wall,
            topLeft: .wall,
            top: .wall,
            topLeftCorner: Self._wallTileChar
        )
        // Edge between space -> wall tiles
        addRule(
            state: .wall,
            left: .nonWall,
            leftEdge: "▐"
        )
        addRule(
            state: .wall,
            left: .nonWall,
            topLeft: .nonWall,
            top: .wall,
            topLeftCorner: "▐"
        )
        addRule(
            state: .wall,
            top: .nonWall,
            topEdge: "▄"
        )
        addRule(
            state: .wall,
            left: .wall,
            topLeft: .nonWall,
            top: .nonWall,
            topLeftCorner: "▄"
        )
        // Corners
        addRule(
            state: .wall,
            left: .nonWall,
            topLeft: .nonWall,
            top: .nonWall,
            topLeftCorner: "▗"
        )
        addRule(
            state: .wall,
            left: .space,
            topLeft: .wall,
            top: .space,
            topLeftCorner: "▚"
        )
        addRule(
            state: .wall,
            left: .space,
            topLeft: .wall,
            top: .wall,
            topLeftCorner: "▜"
        )
        addRule(
            state: .wall,
            left: .wall,
            topLeft: .space,
            top: .wall,
            topLeftCorner: "▟"
        )
        addRule(
            state: .wall,
            left: .wall,
            topLeft: .wall,
            top: .space,
            topLeftCorner: "▙"
        )

        // Light tiles
        // Edge between dark -> light tiles
        addRule(
            state: .nonWall,
            left: .wall,
            leftEdge: "▌"
        )
        addRule(
            state: .nonWall,
            top: .wall,
            topEdge: "▀"
        )
        addRule(
            state: .nonWall,
            left: .wall,
            topLeft: .wall,
            top: .nonWall,
            topLeftCorner: "▌"
        )
        addRule(
            state: .nonWall,
            left: .wall,
            topLeft: .nonWall,
            top: .nonWall,
            topLeftCorner: "▖"
        )
        // Corners
        addRule(
            state: .nonWall,
            left: .wall,
            topLeft: .wall,
            top: .wall,
            topLeftCorner: "▛"
        )
        addRule(
            state: .nonWall,
            left: .nonWall,
            topLeft: .wall,
            top: .nonWall,
            topLeftCorner: "▘"
        )
        addRule(
            state: .nonWall,
            left: .nonWall,
            topLeft: .nonWall,
            top: .wall,
            topLeftCorner: "▝"
        )
        addRule(
            state: .nonWall,
            left: .nonWall,
            topLeft: .wall,
            top: .wall,
            topLeftCorner: "▀"
        )
        addRule(
            state: .nonWall,
            left: .wall,
            topLeft: .space,
            top: .wall,
            topLeftCorner: "▞"
        )
    }

    public func printGrid(grid: LightUpGrid) {
        resetBuffer()
        let startX = LightUpGridPrinter.startGridX(for: grid)
        let startY = LightUpGridPrinter.startGridY(for: grid)

        let gridWidth = bufferWidth - startX - 2
        let gridHeight = bufferHeight - startY - 2

        putRect(x: startX, y: startY, w: gridWidth, h: gridHeight)

        let cellWidth = gridWidth / grid.columns
        let cellHeight = gridHeight / grid.rows

        // Print grid cells
        for y in 0..<grid.rows {
            for x in 0..<grid.columns {
                let isLit = grid.isLit(.init(column: x, row: y))

                printTile(
                    grid[column: x, row: y],
                    color: isLit ? .yellow : nil,
                    x: startX + x * cellWidth,
                    y: startY + y * cellHeight,
                    width: cellWidth,
                    height: cellHeight
                )
            }
        }

        joinBoxLines()

        func stateAt(x: Int, y: Int) -> LightUpTile.State? {
            if x < 0 || y < 0 || x >= grid.columns || y >= grid.rows {
                return nil
            }

            return grid[column: x, row: y].state
        }

        // Print joiners for dark cells across grid boundaries
        
        for y in 0...grid.rows {
            for x in 0...grid.columns {
                let boxX = startX + x * cellWidth
                let boxY = startY + y * cellHeight

                for pattern in self._edgePatterns {
                    if pattern.matches(column: x, row: y, in: grid) {
                        pattern.apply(
                            buffer: self,
                            cellX: boxX,
                            cellY: boxY,
                            cellWidth: cellWidth,
                            cellHeight: cellHeight
                        )
                    }
                }
            }
        }

        print()
    }

    private func printTile(
        _ tile: LightUpTile,
        color: ConsoleColor? = nil,
        x: Int,
        y: Int,
        width: Int,
        height: Int
    ) {

        switch tile.state {
        case .wall(let hint):
            fillRect(
                char: Self._wallTileChar,
                color: color,
                x: x,
                y: y,
                w: width,
                h: height
            )

            if let hint {
                putString(
                    hint.description,
                    color: color,
                    x: x + width / 2,
                    y: y + height / 2
                )
            }

        case .space(let contents):
            fillRect(
                char: Self._emptyTileChar,
                color: color,
                x: x,
                y: y,
                w: width,
                h: height
            )

            switch contents {
            case .empty:
                break

            case .light:
                putChar(
                    Self._lightTileChar,
                    color: color,
                    x: x + width / 2,
                    y: y + height / 2
                )

            case .marker:
                putChar(
                    Self._markTileChar,
                    color: color,
                    x: x + width / 2,
                    y: y + height / 2
                )
            }
        }

        // Draw surrounding tile lines
        putRect(x: x, y: y, w: width, h: height)
    }

    /// For performing matching square-like pattern matching to the grid pattern.
    struct GridEdgePattern {
        typealias State = LightUpTile.State

        var stateMatch: StateMatch

        var leftStateMatch: StateMatch = .any
        var topLeftStateMatch: StateMatch = .any
        var topStateMatch: StateMatch = .any
        var topRightStateMatch: StateMatch = .any

        var leftEdge: Character?
        var topLeftCorner: Character?
        var topEdge: Character?
        var topRightCorner: Character?

        func matches(column: Int, row: Int, in grid: LightUpGrid) -> Bool {
            func stateOffset(dx: Int, dy: Int) -> LightUpTile.State? {
                let x = column + dx
                let y = row + dy

                if x < 0 || y < 0 || x >= grid.columns || y >= grid.rows {
                    return nil
                }

                return grid[column: x, row: y].state
            }

            if !stateMatch.matches(stateOffset(dx: 0, dy: 0)) {
                return false
            }

            if !leftStateMatch.matches(stateOffset(dx: -1, dy: 0)) {
                return false
            }
            if !topLeftStateMatch.matches(stateOffset(dx: -1, dy: -1)) {
                return false
            }
            if !topStateMatch.matches(stateOffset(dx: 0, dy: -1)) {
                return false
            }
            if !topRightStateMatch.matches(stateOffset(dx: 1, dy: -1)) {
                return false
            }

            return true
        }

        func apply(
            buffer: ConsolePrintBuffer,
            cellX: Int,
            cellY: Int,
            cellWidth: Int,
            cellHeight: Int
        ) {

            if let leftEdge = leftEdge, cellHeight > 1 {
                for y in (cellY + 1)..<(cellY + cellHeight) {
                    buffer.putChar(leftEdge, x: cellX, y: y)
                }
            }
            if let topLeftCorner = topLeftCorner {
                buffer.putChar(topLeftCorner, x: cellX, y: cellY)
            }
            if let topEdge = topEdge, cellWidth > 1 {
                for x in (cellX + 1)..<(cellX + cellWidth) {
                    buffer.putChar(topEdge, x: x, y: cellY)
                }
            }
            if let topRightCorner = topRightCorner {
                buffer.putChar(topRightCorner, x: cellX + cellWidth, y: cellY)
            }
        }

        enum StateMatch {
            /// Matches wall tiles
            case wall

            /// Matches any tile that is not wall, including out-of-bounds
            case nonWall
            
            /// Matches space tiles
            case space
            
            /// Matches any tile (except out-of-bounds)
            case anyInBounds

            /// Matches out-of-bounds tiles
            case outOfBounds

            /// Matches any tiles (in or out of bounds)
            case any

            /// Matches no tiles (in or out of bounds)
            case none

            func matches(_ state: LightUpTile.State?) -> Bool {
                switch self {
                case .any:
                    return true
                
                case .none:
                    return false

                case .anyInBounds:
                    return state != nil

                case .wall:
                    switch state {
                    case .wall:
                        return true
                    default:
                        return false
                    }
                
                case .nonWall:
                    switch state {
                    case .wall:
                        return false
                    default:
                        return true
                    }

                case .space:
                    switch state {
                    case .space:
                        return true
                    default:
                        return false
                    }

                case .outOfBounds:
                    return state == nil
                }
            }
        }
    }
}

extension LightUpGridPrinter {
    static func bufferWidth(for grid: LightUpGrid) -> Int {
        return 
            cellWidth(for: grid) * grid.columns
            + startGridX(for: grid)
            + 2 // Right padding for newline
    }

    static func bufferHeight(for grid: LightUpGrid) -> Int {
        return
            cellHeight(for: grid) * grid.rows
            + startGridY(for: grid)
            + 2 // End padding
    }

    static func startGridX(for grid: LightUpGrid) -> Int {
        0
    }

    static func startGridY(for grid: LightUpGrid) -> Int {
        0
    }

    static func cellWidth(for grid: LightUpGrid) -> Int {
        4
    }

    static func cellHeight(for grid: LightUpGrid) -> Int {
        2
    }
}
