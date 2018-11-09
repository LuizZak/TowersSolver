// Sourcing information: Based on Puzzle Games' 'grid.c' implementation by Simon
// Tatham et al.

/// Generates a honeycomb-shaped lattice with hexagons interleaved across a uniform
/// grid.
public class LoopyHoneycombGridGenerator: BaseLoopyGridGenerator {
    private let tileSize: Int = 45
    // Vector for side of hexagon - ratio is close to sqrt(3)
    private let honeyA: Int = 15
    private let honeyB: Int = 26
    
    public var width: Int
    public var height: Int
    
    public init(width: Int, height: Int) {
        self.width = width
        self.height = height
        
        super.init(facesCount: width * height)
    }
    
    public override func generate() -> LoopyGrid {
        var grid = LoopyGrid()
        
        let a = honeyA
        let b = honeyB
        
        for y in 0..<height {
            for x in 0..<width {
                // face centre
                let cx = 3 * a * x
                let cy = 2 * b * y + (x % 2) * b
                
                grid.createFace(withVertexIndices: [
                    grid.addOrGetVertex(x: cx - a, y: cy - b),
                    grid.addOrGetVertex(x: cx + a, y: cy - b),
                    grid.addOrGetVertex(x: cx + 2 * a, y: cy),
                    grid.addOrGetVertex(x: cx + a, y: cy + b),
                    grid.addOrGetVertex(x: cx - a, y: cy + b),
                    grid.addOrGetVertex(x: cx - 2 * a, y: cy)
                ])
            }
        }
        
        for (face, hint) in hints {
            grid.withFace(face) {
                $0.hint = hint
            }
        }
        
        return grid
    }
}
