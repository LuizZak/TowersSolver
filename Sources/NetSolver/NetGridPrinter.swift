import Console

public class NetGridPrinter: ConsolePrintBuffer {
    public func printGrid(grid: Grid) {
        resetBuffer()
        let availableWidth = bufferWidth - 2
        let availableHeight = bufferHeight - 2
        
        putRect(x: 0, y: 0, w: availableWidth, h: availableHeight)
        
        let cellWidth = availableWidth / grid.columns
        let cellHeight = availableHeight / grid.rows
        
        for y in 0..<grid.rows {
            for x in 0..<grid.columns {
                printTile(grid.tiles[y][x],
                          x: x * cellWidth, y: y * cellHeight,
                          width: cellWidth, height: cellHeight)
                
                putRect(x: x * cellWidth, y: y * cellHeight,
                        w: cellWidth, h: cellHeight)
            }
        }
        
        joinBoxLines()
        print()
    }
    
    private func printTile(_ tile: Tile, x: Int, y: Int, width: Int, height: Int) {
        
    }
}
