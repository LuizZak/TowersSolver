// Sourcing information: Based on Puzzle Games' 'grid.c' implementation by Simon
// Tatham et al.

/// Generates a honeycomb-shaped lattice with hexagons interleaved across a uniform
/// grid.
public class LoopyHoneycombGridGenerator: LoopyGridGenerator {
    private let tileSize: Int = 45
    // Vector for side of hexagon - ratio is close to sqrt(3)
    private let honeyA: Int = 15
    private let honeyB: Int = 26
    
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
    
    public func loadHints(from gameId: String) {
        hints = [:]
        
        var emptiesToMake = 0
        let chars = Array(gameId)
        var char = 0
        let faces = width * height
        
        for f in 0..<faces {
            if emptiesToMake > 0 {
                emptiesToMake -= 1
                hints[f] = nil
                continue
            }
            
            let charInt = Int(chars[char].unicodeScalars.first!.value)
            
            let n = charInt - Int(("0" as UnicodeScalar).value)
            let n2 = charInt - Int(("A" as UnicodeScalar).value) + 10
            
            if n >= 0 && n < 10 {
                hints[f] = n
            } else if n2 >= 10 && n2 < 36 {
                hints[f] = n2
            } else {
                let n3 = charInt - Int(("a" as UnicodeScalar).value) + 1
                emptiesToMake = n3 - 1
            }
            char += 1
        }
    }
    
    public func generate() -> LoopyGrid {
        var grid = LoopyGrid()
        
        let a = honeyA
        let b = honeyB
        
        for y in 0..<height {
            for x in 0..<width {
                // face centre
                let cx = 3 * a * x
                var cy = 2 * b * y
                if x % 2 == 1 {
                    cy += b
                }
                
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
