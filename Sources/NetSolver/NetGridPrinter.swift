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
        
        let centerX = grid.columns / 2
        let centerY = grid.rows / 2
        
        let centerNetwork =
            Network.allConnectedStartingFrom(column: centerX,
                                             row: centerY,
                                             onGrid: grid)
        
        putRect(x: 0, y: 0, w: availableWidth, h: availableHeight)
        
        let cellWidth = availableWidth / grid.columns
        let cellHeight = availableHeight / grid.rows
        
        for y in 0..<grid.rows {
            for x in 0..<grid.columns {
                let isCenter = x == centerX && y == centerY
                let isActive = centerNetwork.hasTile(forColumn: x, row: y)
                
                printTile(grid[row: y, column: x],
                          x: x * cellWidth, y: y * cellHeight,
                          width: cellWidth, height: cellHeight,
                          isCenter: isCenter,
                          isActive: isActive)
            }
        }
        
        joinBoxLines()
        print()
    }
    
    private func printTile(_ tile: Tile,
                           x: Int, y: Int,
                           width: Int, height: Int,
                           isCenter: Bool,
                           isActive: Bool) {
        
        // Print a "*" at the top-left of locked tiles
        if tile.isLocked {
            put("*", x: x + 1, y: y + 1)
        }
        
        let centerX = x + width / 2
        let centerY = y + height / 2
        
        let color: ConsoleColor? = isActive ? .cyan : nil
        
        // Draw tile connections
        for port in tile.ports {
            switch port {
            case .top:
                putVerticalLine("│",
                                color: color,
                                x: centerX,
                                y: y,
                                h: height / 2)
                
            case .left:
                putHorizontalLine("─",
                                  color: color,
                                  x: x,
                                  y: centerY,
                                  w: width / 2)
                
            case .bottom:
                putVerticalLine("│",
                                color: color,
                                x: centerX,
                                y: centerY,
                                h: height / 2)
                
            case .right:
                putHorizontalLine("─",
                                  color: color,
                                  x: centerX,
                                  y: centerY,
                                  w: width / 2)
            }
        }
        
        // Draw center box in case this tile is an endpoint
        if tile.kind == .endPoint || isCenter {
            put("■", color: .cyan, x: centerX, y: centerY)
        }
        
        // Draw surrounding tile lines
        putRect(x: x, y: y, w: width, h: height)
    }
}
