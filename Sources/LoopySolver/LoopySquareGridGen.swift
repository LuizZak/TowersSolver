/// Grid generator that generates loopy grid with regular square grid patterns.
public class LoopySquareGridGen: BaseLoopyGridGenerator {
    public let width: Int
    public let height: Int
    
    public init(width: Int, height: Int) {
        self.width = width
        self.height = height
        
        super.init(facesCount: width * height)
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
        let face = x + y * width
        
        super.setHint(faceIndex: face, hint: hint)
    }
    
    public func hintForFace(atX x: Int, y: Int) -> Int? {
        let face = x + y * width
        
        return hints[face]
    }
    
    public override func generate() -> LoopyGrid {
        var grid = LoopyGrid()
        
        for y in 0..<height {
            for x in 0..<width {
                let hint = hintForFace(atX: x, y: y)
                
                grid.createFace(withVertexIndices: [
                    grid.addOrGetVertex(x: x, y: y),
                    grid.addOrGetVertex(x: x + 1, y: y),
                    grid.addOrGetVertex(x: x + 1, y: y + 1),
                    grid.addOrGetVertex(x: x, y: y + 1)
                ], hint: hint)
            }
        }
        
        return grid
    }
}
