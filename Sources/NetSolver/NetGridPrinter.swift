import Console

public class NetGridPrinter: ConsolePrintBuffer {
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
                printTile(grid[row: y, column: x],
                          x: x * cellWidth, y: y * cellHeight,
                          width: cellWidth, height: cellHeight)
            }
        }
        
        joinBoxLines()
        print()
    }
    
    private func printTile(_ tile: Tile, x: Int, y: Int, width: Int, height: Int) {
        // Print a "*" at the top-left of locked tiles
        if tile.isLocked {
            put("*", x: x + 1, y: y + 1)
        }
        
        let centerX = x + width / 2
        let centerY = y + height / 2
        
        // Draw tile connections
        for port in tile.ports {
            switch port {
            case .top:
                putVerticalLine("│", x: centerX, y: y, h: height / 2)
            case .left:
                putHorizontalLine("─", x: x, y: centerY, w: width / 2)
            case .bottom:
                putVerticalLine("│", x: centerX, y: centerY, h: height / 2)
            case .right:
                putHorizontalLine("─", x: centerX, y: centerY, w: width / 2)
            }
        }
        
        // Draw center box in case this tile is an endpoint
        if tile.kind == .endPoint {
            put("■", color: .cyan, x: centerX, y: centerY)
        }
        
        // Draw surrounding tile lines
        putRect(x: x, y: y, w: width, h: height)
    }
}
