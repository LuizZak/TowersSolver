import Console

public class PatternGridPrinter: ConsolePrintBuffer {
    /// Initializes a grid printer with a buffer capable of rendering the given
    /// grid with each cell has 4 characters of width and 2 of height.
    public convenience init(bufferForGrid grid: PatternGrid) {
        self.init(
            bufferWidth: PatternGridPrinter.bufferWidth(for: grid),
            bufferHeight: PatternGridPrinter.bufferHeight(for: grid)
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
                char: "?",
                color: nil,
                x: x,
                y: y,
                w: width,
                h: height
            )
        
        case .dark:
            fillRect(
                char: "▋",
                color: nil,
                x: x,
                y: y,
                w: width,
                h: height
            )

        case .light:
            fillRect(
                char: " ",
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
            (0..<grid.rows)
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
