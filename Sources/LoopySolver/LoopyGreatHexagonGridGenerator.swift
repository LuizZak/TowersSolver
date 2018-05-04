// Sourcing information: Based on Puzzle Games' 'grid.c' implementation by Simon
// Tatham et al.

/*
#define GREATHEX_TILESIZE 18
/* Vector for side of triangle - ratio is close to sqrt(3) */
#define GREATHEX_A 15
#define GREATHEX_B 26
*/

/// Generates a Great Hexagonal-shaped lattice with hexagons interleaved with
/// squares and triangles.
public class LoopyGreatHexagonGridGenerator: LoopyGridGenerator {
    private let tileSize = 18
    // Vector for side of triangle - ratio is close to sqrt(3)
    private let greatHexA = 15
    private let greatHexB = 26
    
    public var width: Int
    public var height: Int
    
    private var hints: [Int: Int] = [:]
    
    public init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }
    
    public func setHint(faceIndex index: Int, hint: Int?) {
        hints[index] = hint
    }
    
    public func generate() -> LoopyGrid {
        let a = greatHexA
        let b = greatHexB
        
        var grid = LoopyGrid()
        
        for y in 0..<height {
            for x in 0..<width {
                // centre of hexagon
                let px = (3 * a + b) * x
                var py = (2 * a + 2 * b) * y
                
                if x % 2 != 0 {
                    py += a + b
                }
                
                /* hexagon */
                grid.createFace(withVertexIndices: [
                    grid.addOrGetVertex(x: px - a, y: py - b),
                    grid.addOrGetVertex(x: px + a, y: py - b),
                    grid.addOrGetVertex(x: px + 2*a, y: py),
                    grid.addOrGetVertex(x: px + a, y: py + b),
                    grid.addOrGetVertex(x: px - a, y: py + b),
                    grid.addOrGetVertex(x: px - 2*a, y: py),
                ])
                
                /* square below left */
                if ((x > 0) && (((x % 2) == 0) || (y < height - 1))) {
                    grid.createFace(withVertexIndices: [
                        grid.addOrGetVertex(x: px - 2*a, y: py),
                        grid.addOrGetVertex(x: px - a, y: py + b),
                        grid.addOrGetVertex(x: px - a - b, y: py + a + b),
                        grid.addOrGetVertex(x: px - 2*a - b, y: py + a)
                    ])
                }
                
                /* Triangle below left */
                if ((x > 0) && (y < height - 1)) {
                    grid.createFace(withVertexIndices: [
                        grid.addOrGetVertex(x: px - a, y: py + b),
                        grid.addOrGetVertex(x: px - a, y: py + 2*a + b),
                        grid.addOrGetVertex(x: px - a - b, y: py + a + b)
                    ])
                }
                
                /* square below hexagon */
                if (y < height - 1) {
                    grid.createFace(withVertexIndices: [
                        grid.addOrGetVertex(x: px - a, y: py + b),
                        grid.addOrGetVertex(x: px + a, y: py + b),
                        grid.addOrGetVertex(x: px + a, y: py + 2*a + b),
                        grid.addOrGetVertex(x: px - a, y: py + 2*a + b),
                    ])
                }
                
                /* Triangle below right */
                if ((x < width - 1) && (y < height - 1)) {
                    grid.createFace(withVertexIndices: [
                        grid.addOrGetVertex(x: px + a, y: py + b),
                        grid.addOrGetVertex(x: px + a + b, y: py + a + b),
                        grid.addOrGetVertex(x: px + a, y: py + 2*a + b)
                    ])
                }
                
                /* square below right */
                if ((x < width - 1) && (((x % 2) == 0) || (y < height - 1))) {
                    grid.createFace(withVertexIndices: [
                        grid.addOrGetVertex(x: px + 2*a, y: py),
                        grid.addOrGetVertex(x: px + 2*a + b, y: py + a),
                        grid.addOrGetVertex(x: px + a + b, y: py + a + b),
                        grid.addOrGetVertex(x: px + a, y: py + b)
                    ])
                }
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
