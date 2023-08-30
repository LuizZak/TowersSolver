import Console

public class PatternGridPrinter: ConsolePrintBuffer {
    private static let _darkTileChar: Character = "█"
    private static let _lightTileChar: Character = " "
    private static let _undecidedTileChar: Character = "?"

    private var _edgePatterns: [GridEdgePattern] = []

    /// Initializes a grid printer with a buffer capable of rendering the given
    /// grid with each cell has 4 characters of width and 2 of height.
    public convenience init(bufferForGrid grid: PatternGrid) {
        self.init(
            bufferWidth: PatternGridPrinter.bufferWidth(for: grid),
            bufferHeight: PatternGridPrinter.bufferHeight(for: grid)
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

        // Dark tiles
        addRule(
            state: .dark,
            left: .dark,
            leftEdge: Self._darkTileChar
        )
        addRule(
            state: .dark,
            top: .dark,
            topEdge: Self._darkTileChar
        )
        addRule(
            state: .dark,
            left: .dark,
            topLeft: .dark,
            top: .dark,
            topLeftCorner: Self._darkTileChar
        )
        // Edge between light -> dark tiles
        addRule(
            state: .dark,
            left: .nonDark,
            leftEdge: "▐"
        )
        addRule(
            state: .dark,
            left: .nonDark,
            topLeft: .nonDark,
            top: .dark,
            topLeftCorner: "▐"
        )
        addRule(
            state: .dark,
            top: .nonDark,
            topEdge: "▄"
        )
        addRule(
            state: .dark,
            left: .dark,
            topLeft: .nonDark,
            top: .nonDark,
            topLeftCorner: "▄"
        )
        // Corners
        addRule(
            state: .dark,
            left: .nonDark,
            topLeft: .nonDark,
            top: .nonDark,
            topLeftCorner: "▗"
        )
        addRule(
            state: .dark,
            left: .lightOrUndecided,
            topLeft: .dark,
            top: .lightOrUndecided,
            topLeftCorner: "▚"
        )
        addRule(
            state: .dark,
            left: .lightOrUndecided,
            topLeft: .dark,
            top: .dark,
            topLeftCorner: "▜"
        )
        addRule(
            state: .dark,
            left: .dark,
            topLeft: .lightOrUndecided,
            top: .dark,
            topLeftCorner: "▟"
        )
        addRule(
            state: .dark,
            left: .dark,
            topLeft: .dark,
            top: .lightOrUndecided,
            topLeftCorner: "▙"
        )

        // Light tiles
        // Edge between dark -> light tiles
        addRule(
            state: .nonDark,
            left: .dark,
            leftEdge: "▌"
        )
        addRule(
            state: .nonDark,
            top: .dark,
            topEdge: "▀"
        )
        addRule(
            state: .nonDark,
            left: .dark,
            topLeft: .dark,
            top: .nonDark,
            topLeftCorner: "▌"
        )
        addRule(
            state: .nonDark,
            left: .dark,
            topLeft: .nonDark,
            top: .nonDark,
            topLeftCorner: "▖"
        )
        // Corners
        addRule(
            state: .nonDark,
            left: .dark,
            topLeft: .dark,
            top: .dark,
            topLeftCorner: "▛"
        )
        addRule(
            state: .nonDark,
            left: .nonDark,
            topLeft: .dark,
            top: .nonDark,
            topLeftCorner: "▘"
        )
        addRule(
            state: .nonDark,
            left: .nonDark,
            topLeft: .nonDark,
            top: .dark,
            topLeftCorner: "▝"
        )
        addRule(
            state: .nonDark,
            left: .nonDark,
            topLeft: .dark,
            top: .dark,
            topLeftCorner: "▀"
        )
        addRule(
            state: .nonDark,
            left: .dark,
            topLeft: .lightOrUndecided,
            top: .dark,
            topLeftCorner: "▞"
        )
    }

    public func printGrid(grid: PatternGrid) {
        resetBuffer()
        let startX = PatternGridPrinter.startGridX(for: grid)
        let startY = PatternGridPrinter.startGridY(for: grid)

        let gridWidth = bufferWidth - startX - 2
        let gridHeight = bufferHeight - startY - 2

        putRect(x: startX, y: startY, w: gridWidth, h: gridHeight)

        let cellWidth = gridWidth / grid.columns
        let cellHeight = gridHeight / grid.rows

        // Print hints
        let columnHintStart = (0..<grid.columns).map {
            grid.hintForColumn($0).runCount
        }.max() ?? 0

        for column in 0..<grid.columns {
            let hint = grid.hintForColumn(column)
            let centerX = startX + (column * cellWidth + cellWidth / 2)
            
            for (i, run) in hint.runs.enumerated() {
                let y = i - (hint.runCount - columnHintStart)

                putString(run.description, x: centerX, y: y)
            }
        }
        for row in 0..<grid.rows {
            let hint = grid.hintForRow(row)
            let centerY = startY + (row * cellHeight + cellHeight / 2)

            var x = startX - PatternGridPrinter.hintStringFor(row: row, in: grid).count - 1

            for run in hint.runs {
                putString(run.description, x: x, y: centerY)
                x += run.description.count + 1
            }
        }

        // Print grid cells
        for y in 0..<grid.rows {
            for x in 0..<grid.columns {
                printTile(
                    grid[column: x, row: y],
                    x: startX + x * cellWidth,
                    y: startY + y * cellHeight,
                    width: cellWidth,
                    height: cellHeight
                )
            }
        }

        joinBoxLines()

        func stateAt(x: Int, y: Int) -> PatternTile.State? {
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
        _ tile: PatternTile,
        x: Int,
        y: Int,
        width: Int,
        height: Int
    ) {

        switch tile.state {
        case .undecided:
            fillRect(
                char: Self._undecidedTileChar,
                color: nil,
                x: x,
                y: y,
                w: width,
                h: height
            )
        
        case .dark:
            fillRect(
                char: Self._darkTileChar,
                color: nil,
                x: x,
                y: y,
                w: width,
                h: height
            )

        case .light:
            fillRect(
                char: Self._lightTileChar,
                color: nil,
                x: x,
                y: y,
                w: width,
                h: height
            )
        }

        // Draw surrounding tile lines
        putRect(x: x, y: y, w: width, h: height)
    }

    /// For performing matching square-like pattern matching to the grid pattern.
    struct GridEdgePattern {
        typealias State = PatternTile.State

        var stateMatch: StateMatch

        var leftStateMatch: StateMatch = .any
        var topLeftStateMatch: StateMatch = .any
        var topStateMatch: StateMatch = .any
        var topRightStateMatch: StateMatch = .any

        var leftEdge: Character?
        var topLeftCorner: Character?
        var topEdge: Character?
        var topRightCorner: Character?

        func matches(column: Int, row: Int, in grid: PatternGrid) -> Bool {
            func stateOffset(dx: Int, dy: Int) -> PatternTile.State? {
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
            /// Matches dark tiles
            case dark

            /// Matches any tile that is not dark, including out-of-bounds
            case nonDark
            
            /// Matches light tiles
            case light

            /// Matches undecided tiles
            case undecided

            /// Matches light and undecided tiles, but not dark tiles
            case lightOrUndecided
            
            /// Matches any tile (except out-of-bounds)
            case anyInBounds

            /// Matches out-of-bounds tiles
            case outOfBounds

            /// Matches any tiles (in or out of bounds)
            case any

            /// Matches no tiles (in or out of bounds)
            case none

            func matches(_ state: PatternTile.State?) -> Bool {
                switch self {
                case .any:
                    return true
                
                case .none:
                    return false

                case .anyInBounds:
                    return state != nil

                case .dark:
                    return state == .dark
                
                case .nonDark:
                    return state != .dark

                case .light:
                    return state == .light

                case .undecided:
                    return state == .undecided

                case .lightOrUndecided:
                    return state == .light || state == .undecided

                case .outOfBounds:
                    return state == nil
                }
            }
        }
    }
}

extension PatternGridPrinter {
    static func bufferWidth(for grid: PatternGrid) -> Int {
        return 
            cellWidth(for: grid) * grid.columns
            + startGridX(for: grid)
            + 2 // Right padding for newline
    }

    static func bufferHeight(for grid: PatternGrid) -> Int {
        return
            cellHeight(for: grid) * grid.rows
            + startGridY(for: grid)
            + 2 // End padding
    }

    static func startGridX(for grid: PatternGrid) -> Int {
        // Find largest hint string for each row
        let largestRow =
            (0..<grid.rows)
            .map {
                hintStringFor(row: $0, in: grid)
            }
            .map { $0.count + 1 }
            .max() ?? 0

        return largestRow
    }

    static func startGridY(for grid: PatternGrid) -> Int {
        // Find largest hint string for each column
        let largestColumn =
            (0..<grid.columns)
            .map {
                grid.hintForColumn($0).runCount
            }
            .max() ?? 0
        
        return largestColumn
    }

    static func cellWidth(for grid: PatternGrid) -> Int {
        4
    }

    static func cellHeight(for grid: PatternGrid) -> Int {
        2
    }

    static func hintStringFor(row: Int, in grid: PatternGrid) -> String {
        let hints = grid.hintForRow(row)

        return hints.runs.map(\.description).joined(separator: " ")
    }
}
