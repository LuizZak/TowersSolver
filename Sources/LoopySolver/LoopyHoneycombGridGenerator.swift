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

    /// Returns the ID of the face that will be generated at a specified coordinate
    public func faceId(atX x: Int, y: Int) -> LoopyGrid.FaceId {
        .init(y * width + x)
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

        let a = honeyA
        let b = honeyB

        for y in 0..<height {
            for x in 0..<width {
                // face centre
                let cx = 3 * a * x
                let cy = 2 * b * y + (x % 2) * b

                let faceId = grid.createFace(withVertexIndices: [
                    grid.addOrGetVertex(x: cx - a, y: cy - b),
                    grid.addOrGetVertex(x: cx + a, y: cy - b),
                    grid.addOrGetVertex(x: cx + 2 * a, y: cy),
                    grid.addOrGetVertex(x: cx + a, y: cy + b),
                    grid.addOrGetVertex(x: cx - a, y: cy + b),
                    grid.addOrGetVertex(x: cx - 2 * a, y: cy),
                ])

                assert(faceId == self.faceId(atX: x, y: y), "\(faceId) == \(self.faceId(atX: x, y: y))")
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
