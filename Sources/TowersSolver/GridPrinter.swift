import Console
import Foundation

/// Helper for printing grids to the console using ASCII text.
public class GridPrinter: ConsolePrintBuffer {
    public convenience init(forGrid grid: Grid) {
        self.init(
            bufferWidth: GridPrinter.bufferWidth(for: grid),
            bufferHeight: GridPrinter.bufferHeight(for: grid)
        )
    }
}

extension GridPrinter {
    public static func cellWidth(for grid: Grid) -> Int {
        6
    }

    public static func cellHeight(for grid: Grid) -> Int {
        4
    }

    public static func bufferWidth(for grid: Grid) -> Int {
        2 + cellWidth(for: grid) * grid.size + 4
    }

    public static func bufferHeight(for grid: Grid) -> Int {
        1 + GridPrinter.cellHeight(for: grid) * grid.size + 2
    }

    public func printGrid(grid: Grid) {
        resetBuffer()

        // For visual hint
        let heights = Array("▁▂▃▄▅▆▇█")

        let originX = 2
        let originY = 1

        let w = GridPrinter.cellWidth(for: grid)
        let h = GridPrinter.cellHeight(for: grid)

        let totalW = grid.size * w
        let totalH = grid.size * h

        for gy in 0..<grid.size {
            let y = gy * h + originY

            if grid.visibilities.left[gy] != 0 {
                putString(grid.visibilities.left[gy].description, x: originX - 2, y: y + h / 2)
            }

            if grid.visibilities.right[gy] != 0 {
                putString(
                    grid.visibilities.right[gy].description,
                    x: totalW + originX + 2,
                    y: y + h / 2
                )
            }

            for gx in 0..<grid.size {
                let x = gx * w + originX

                putRect(x: x, y: y, w: w, h: h)

                // Fill cell contents
                switch grid.cellAt(x: gx, y: gy) {
                case .empty:
                    break
                case .hint(let set):
                    for (i, h) in set.sorted().enumerated() {
                        let _cx = x + 1 + (i * 2) % (w - 1)
                        let _cy = y + 1 + (i * 2) / (w - 1)

                        putString(h.description, x: _cx, y: _cy)
                    }
                case .solved(let value):
                    // Draw a small visual representation of the (relative) height
                    var offset = Int((Float(value) / Float(grid.size)) * Float(heights.count) - 1)
                    offset = max(0, min(heights.count - 1, offset))
                    let hGlyph = heights[offset]

                    fillRect(char: hGlyph, x: x + 1, y: y + h - 1, w: w - 1, h: 1)

                    putString(value.description, x: x + w / 2, y: y + h / 2)
                }

                if gy == 0 {
                    if grid.visibilities.top[gx] != 0 {
                        putString(
                            grid.visibilities.top[gx].description,
                            x: x + w / 2,
                            y: originY - 1
                        )
                    }
                    if grid.visibilities.bottom[gx] != 0 {
                        putString(
                            grid.visibilities.bottom[gx].description,
                            x: x + w / 2,
                            y: totalH + originY + 1
                        )
                    }
                }
            }
        }

        joinBoxLines()
        print()
    }

    public static func printGrid(grid: Grid, colorized: Bool = true) {
        let printer = GridPrinter(forGrid: grid)
        printer.colorized = colorized
        printer.printGrid(grid: grid)
    }
}
