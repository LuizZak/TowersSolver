import Console
import Foundation

/// Helper for printing grids to the console using ASCII text.
public class LoopyGridPrinter: ConsolePrintBuffer {
    
    public static func cellWidth(for grid: Grid) -> Int {
        return 6
    }
    
    public static func cellHeight(for grid: Grid) -> Int {
        return 4
    }
}

public extension LoopyGridPrinter {
    
    public func printGrid(grid: Grid) {
        resetBuffer()
        
        let originX = 0
        let originY = 0
        
        let w = LoopyGridPrinter.cellWidth(for: grid)
        let h = LoopyGridPrinter.cellHeight(for: grid)
        
        for gy in 0..<grid.height {
            let y = gy * h + originY
            
            for gx in 0..<grid.width {
                let x = gx * w + originX
                
                putRect(x: x, y: y, w: w, h: h)
                
                // Fill cell contents
                let cell = grid.cell(atX: gx, y: gy)
                
                if let hint = cell.hint {
                    putString(hint.description, x: x + w / 2, y: y + h / 2)
                }
            }
        }
        
        joinBoxLines()
        
        // Draw in marked edges with special outline chars
        for gy in 0..<grid.height {
            let y = gy * h + originY
            
            for gx in 0..<grid.width {
                let x = gx * w + originX
                
                let cell = grid.cell(atX: gx, y: gy)
                
                putEdgeLines(cell, x: x, y: y, w: w, h: h)
            }
        }
        
        print()
    }
    
    internal func putEdgeLines(_ cell: Cell, x: Int, y: Int, w: Int, h: Int) {
        if cell.topEdge != .normal {
            putEdgeHorizontal(cell.topEdge, x: x + 1, y: y, w: w - 2)
        }
        if cell.bottomEdge != .normal {
            putEdgeHorizontal(cell.bottomEdge, x: x + 1, y: y + h, w: w - 2)
        }
        
        if cell.leftEdge != .normal {
            putEdgeVertical(cell.leftEdge, x: x, y: y + 1, h: h - 2)
        }
        if cell.rightEdge != .normal {
            putEdgeVertical(cell.leftEdge, x: x + w, y: y + 1, h: h - 2)
        }
    }
    
    internal func putEdgeHorizontal(_ state: EdgeState, x: Int, y: Int, w: Int) {
        putHorizontalLine(scalarForEdgeState(state, isHorizontal: true), x: x, y: y, w: w)
        
        if state == .disabled {
            putChar("x", x: x + w / 2, y: y)
        }
    }
    
    internal func putEdgeVertical(_ state: EdgeState, x: Int, y: Int, h: Int) {
        putVerticalLine(scalarForEdgeState(state, isHorizontal: false), x: x, y: y, h: h)
        
        if state == .disabled {
            putChar("x", x: x, y: y + h / 2)
        }
    }
    
    internal func scalarForEdgeState(_ state: EdgeState, isHorizontal: Bool) -> UnicodeScalar {
        if isHorizontal {
            switch state {
            case .marked:
                return "═"
            case .normal:
                return "-"
            case .disabled:
                return " " //"╌"
            }
        } else {
            switch state {
            case .marked:
                return "║"
            case .normal:
                return "|"
            case .disabled:
                return " " // "╎"
            }
        }
    }
    
    public static func printGrid(grid: Grid) {
        let printer = LoopyGridPrinter(bufferWidth: 80, bufferHeight: 35)
        printer.printGrid(grid: grid)
    }
}
