import Console

public class SignpostGridPrinter: ConsolePrintBuffer {
    public override init(bufferWidth: Int, bufferHeight: Int) {
        super.init(bufferWidth: bufferWidth, bufferHeight: bufferHeight)
    }

    /// Initializes a grid printer with a buffer capable of rendering a grid of
    /// given size where each cell has 8 characters of width and 4 of height.
    public init(bufferForGridWidth width: Int, height: Int) {
        super.init(bufferWidth: width * 8 + 2, bufferHeight: height * 4 + 2)
    }

    public func printGrid(grid: Grid) {
        resetBuffer()
        let availableWidth = bufferWidth - 2
        let availableHeight = bufferHeight - 2

        putRect(x: 0, y: 0, w: availableWidth, h: availableHeight)

        let cellWidth = availableWidth / grid.columns
        let cellHeight = availableHeight / grid.rows

        for y in 0..<grid.rows {
            for x in 0..<grid.columns {

                printTile(
                    grid[column: x, row: y],
                    x: x * cellWidth,
                    y: y * cellHeight,
                    width: cellWidth,
                    height: cellHeight
                )
            }
        }

        joinBoxLines()
        print()
    }

    private func printTile(
        _ tile: Tile,
        x: Int,
        y: Int,
        width: Int,
        height: Int
    ) {
        // Draw surrounding tile lines
        putRect(x: x, y: y, w: width, h: height)

        // Draw tile number, if available
        if let solution = tile.solution {
            putString(solution.description, x: x + 2, y: y + 1)
        } else {
            put("•", x: x + 2, y: y + height - 1)
        }

        // Draw orientation arrow or star, for end tile
        let orientationIcon: UnicodeScalar

        if tile.isEndTile {
            orientationIcon = "*"
        } else {
            switch tile.orientation {
            case .north:
                orientationIcon = "↑"

            case .northEast:
                orientationIcon = "↗"

            case .east:
                orientationIcon = "→"

            case .southEast:
                orientationIcon = "↘"

            case .south:
                orientationIcon = "↓"

            case .southWest:
                orientationIcon = "↙"

            case .west:
                orientationIcon = "←"

            case .northWest:
                orientationIcon = "↖"
            }
        }

        put(orientationIcon, x: x + width - 2, y: y + height - 1)
    }
}
