import Geometry

/// Grid generator that generates loopy grid with regular square grid patterns.
public class LoopySquareGridGen: LoopyGridGenerator {
    public let width: Int
    public let height: Int
    
    /// Registered hints for cell faces
    internal var hints: [IntPoint: Int] = [:]
    
    public init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }
    
    /// Sets all hints at a given row to a given set of values
    ///
    /// - precondition: `hints.count == width`
    public func setHints(atRow y: Int, hints: [Int?]) {
        precondition(hints.count == width)
        
        for (x, hint) in hints.enumerated() {
            setHint(x: x, y: y, hint: hint)
        }
    }
    
    public func setHint(x: Int, y: Int, hint: Int?) {
        let pair = IntPoint(x: x, y: y)
        
        if let hint = hint {
            hints[pair] = hint
        } else {
            hints.removeValue(forKey: pair)
        }
    }
    
    public func hintForFace(atX x: Int, y: Int) -> Int? {
        let pair = IntPoint(x: x, y: y)
        return hints[pair]
    }
    
    public func generate() -> LoopyGrid {
        var grid = LoopyGrid()
        
        for y in 0...height {
            for x in 0...width {
                grid.addVertex(Vertex(x: x, y: y))
            }
        }
        
        let stride = width + 1
        
        for y in 0..<height {
            for x in 0..<width {
                let v1 = y * stride + x
                let v2 = y * stride + x + 1
                let v3 = (y + 1) * stride + x + 1
                let v4 = (y + 1) * stride + x
                
                let hint = hintForFace(atX: x, y: y)
                
                grid.createFace(withVertexIndices: [v1, v2, v3, v4], hint: hint)
            }
        }
        
        return grid
    }
}
