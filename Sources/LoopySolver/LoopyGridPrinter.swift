import Console
import Foundation
import Geometry

#if os(macOS)
    import Darwin.C
#else
    import Glibc
#endif

/// Helper for printing grids to the console using ASCII text.
public class LoopyGridPrinter: ConsolePrintBuffer {
    /// Whether to print the faces' indices alongside their hint value
    public var printFaceIndices: Bool = false

    /// Whether to print the edges' indices in the center point of their span
    public var printEdgeIndices: Bool = false

    /// Whether to print the vertices' indices in place of the dot symbol
    public var printVertexIndices: Bool = false

    /// Whether to colorize output
    public var colorized: Bool = true

    /// Color to use when printing the marked line path to the console
    private var lineColor: ConsoleColor = .magenta

    public override init(bufferWidth: Int, bufferHeight: Int) {
        super.init(bufferWidth: bufferWidth, bufferHeight: bufferHeight)
    }

    public init(bufferWidth: Int, bufferHeight: Int, printEdgeIndices: Bool, printFaceIndices: Bool = false, printVertexIndices: Bool = false) {
        super.init(bufferWidth: bufferWidth, bufferHeight: bufferHeight)

        self.printEdgeIndices = printEdgeIndices
        self.printFaceIndices = printFaceIndices
        self.printVertexIndices = printVertexIndices
    }

    /// Creates a buffer fit for printing a square grid of columnSize x rowSize
    /// sized cells, with a given column/row count.
    public convenience init(
        squareGridColumns columns: Int,
        rows: Int,
        columnSize: Int = 4,
        rowSize: Int = 2,
        printEdgeIndices: Bool = false,
        printFaceIndices: Bool = false,
        printVertexIndices: Bool = false
    ) {
        let width = columns * columnSize + 2
        let height = rows * rowSize + 1

        self.init(
            bufferWidth: width,
            bufferHeight: height,
            printEdgeIndices: printEdgeIndices,
            printFaceIndices: printFaceIndices,
            printVertexIndices: printVertexIndices
        )
    }

    /// Creates a buffer fit for printing a honeycomb grid of columnSize x rowSize
    /// sized cells, with a given column/row count.
    ///
    /// Column and row sizes are rounded up before being fed to the underlying
    /// initializer as integers
    public convenience init(
        honeycombGridColumns columns: Int,
        rows: Int,
        columnSize: Double = 6.181818,
        rowSize: Double = 4.2,
        printEdgeIndices: Bool = false,
        printFaceIndices: Bool = false,
        printVertexIndices: Bool = false
    ) {
        let width = (Double(columns) * columnSize).rounded(.up) + 2
        let height = (Double(rows) * rowSize).rounded(.up) + 1

        self.init(
            bufferWidth: Int(width),
            bufferHeight: Int(height),
            printEdgeIndices: printEdgeIndices,
            printFaceIndices: printFaceIndices,
            printVertexIndices: printVertexIndices
        )
    }

    private func _color(_ color: ConsoleColor?) -> ConsoleColor? {
        colorized ? color : nil
    }

    public func printGrid(grid: LoopyGrid) {
        printGrid(grid: grid, width: bufferWidth - 2, height: bufferHeight - 1)
    }

    public func printGrid(grid: LoopyGrid, width: Int, height: Int) {
        resetBuffer()

        if grid.vertices.count == 0 {
            Swift.print("No vertices on grid that was provided.")
            return
        }

        let minX = grid.vertices.map({ $0.x }).min()!
        let minY = grid.vertices.map({ $0.y }).min()!

        let gridWidth = totalWidth(for: grid)
        let gridHeight = totalHeight(for: grid)

        let availableWidth = Float(width)
        let availableHeight = Float(height)

        let toScreen = { (gridX: Float, gridY: Float) -> (x: Int, y: Int) in
            let x = (-minX + gridX) / gridWidth * availableWidth
            let y = (-minY + gridY) / gridHeight * availableHeight

            return (x: Int(x), y: Int(y))
        }

        for edge in grid.edgeIds {
            let (v1Index, v2Index) = grid.edgeVertices(forEdge: edge)
            let (v1, v2) = (grid.vertices[v1Index], grid.vertices[v2Index])

            let (x1, y1) = toScreen(v1.x, v1.y)
            let (x2, y2) = toScreen(v2.x, v2.y)

            if (x1, y1) != (x2, y2) {
                let scalars = lineCharacters(forState: grid.edgeState(forEdge: edge))

                bresenham(x1: x1, y1: y1, x2: x2, y2: y2) { plotX, plotY, angle in
                    let segment = normalLineSegment(forAngle: angle, angleSegments: scalars)

                    putString(segment.symbol, color: _color(segment.color), x: plotX, y: plotY)
                }
            }
        }

        for faceIndex in 0..<grid.faceIds.count {
            let poly = grid.polygonFor(face: faceIndex)

            // Print the face's hint at its geometrical center
            let center = poly.reduce(into: Vertex(x: 0, y: 0), +=) / Float(poly.count)

            let (x, y) = toScreen(center.x, center.y)

            var label: String = ""

            if let hint = grid.hintForFace(Face.Id(faceIndex)) {
                label = hint.description
            }

            let color: ConsoleColor? =
                grid.isFaceSolved(Face.Id(faceIndex)) ? .magenta : nil

            putString(label, color: _color(color), x: x, y: y)
        }

        // Draw vertices as small dots
        for (i, v) in grid.vertices.enumerated() {
            let (x, y) = toScreen(v.x, v.y)

            if printVertexIndices {
                putString(i.description, color: _color(lineColor), x: Int(x), y: Int(y))
                continue
            }

            if grid.markedEdges(forVertex: i) > 1 {
                putChar("•", color: _color(lineColor), x: Int(x), y: Int(y))
            } else {
                putChar("•", x: Int(x), y: Int(y))
            }
        }

        // Print face and edge indices after vertices to avoid overlaps

        if printFaceIndices {
            for faceIndex in 0..<grid.faceIds.count {
                let poly = grid.polygonFor(face: faceIndex)

                // Print the face's hint at its geometrical center
                let center = poly.reduce(into: Vertex(x: 0, y: 0), +=) / Float(poly.count)

                let (x, y) = toScreen(center.x, center.y)

                let color: ConsoleColor? =
                    grid.isFaceSolved(Face.Id(faceIndex)) ? .magenta : nil

                let label: String = "[\(faceIndex)]"

                if grid.hintForFace(Face.Id(faceIndex)) != nil {
                    putString(label, color: _color(color), x: x - 1, y: y + 1)
                } else {
                    putString(label, color: _color(color), x: x - 1, y: y)
                }
            }
        }

        if printEdgeIndices {
            for edge in grid.edgeIds {
                let (v1Index, v2Index) = grid.edgeVertices(forEdge: edge)
                let (v1, v2) = (grid.vertices[v1Index], grid.vertices[v2Index])

                let center = (v1 + v2) / 2
                let edgeIndexString = edge.edgeIndex.description
                var (x, y) = toScreen(center.x, center.y)
                x -= max(0, edgeIndexString.count / 2 - 1)

                putString(edgeIndexString, x: x, y: y)
            }
        }

        print()
    }

    internal func totalWidth(for grid: LoopyGrid) -> Float {
        if grid.vertices.count == 0 {
            return 0
        }

        let minX = grid.vertices.min(by: { $0.x < $1.x })!
        let maxX = grid.vertices.max(by: { $0.x < $1.x })!

        return maxX.x - minX.x
    }

    internal func totalHeight(for grid: LoopyGrid) -> Float {
        if grid.vertices.count == 0 {
            return 0
        }

        let minY = grid.vertices.min(by: { $0.y < $1.y })!
        let maxY = grid.vertices.max(by: { $0.y < $1.y })!

        return maxY.y - minY.y
    }

    private func lineCharacters(forState state: Edge.State) -> [LineSegmentChar] {
        #if !Xcode
        let useColors = colorized
        #else
        let useColor = false
        #endif

        if useColors {
            switch state {
            case .normal:
                return ["│", "/", "╱", "─", "╲", "\\", "│"]

            case .marked:
                return ["│", "/", "╱", "─", "╲", "\\", "│"].map {
                    LineSegmentChar(symbol: $0, color: lineColor)
                }

            case .disabled:
                return [" "]
            }
        } else {
            switch state {
            case .normal:
                return ["│", "/", "╱", "─", "╲", "\\", "│"]

            case .marked:
                return ["║", "//", "═", "\\\\", "║"]

            case .disabled:
                return [" "]
            }
        }
    }

    internal func normalLineSegment<T>(forAngle angle: Float, angleSegments: [T]) -> T {
        precondition(angleSegments.count > 0)

        // For an angle that goes from 270º to 90º (passing through 0/360º), turn
        // the angle 90º counterclockwise and normalize it between 0 and 180ª.
        // We then convert it into an index on the array above for the proper angle
        // character.
        let normalized: Float = (angle + .pi / 2).truncatingRemainder(dividingBy: .pi) / .pi

        let index = Int((normalized * Float(angleSegments.count - 1)).rounded(.toNearestOrEven))

        return angleSegments[index]
    }

    func bresenham(
        x1: Int,
        y1: Int,
        x2: Int,
        y2: Int,
        plot: (_ x: Int, _ y: Int, _ angle: Float) -> Void
    ) {

        var p1 = (x: x1, y: y1)
        var p2 = (x: x2, y: y2)

        // We need to handle the different octants differently
        let steep = abs(p2.y - p1.y) > abs(p2.x - p1.x)

        if steep {
            //Swizzle stuff around
            p1 = (x: p1.y, y: p1.x)
            p2 = (x: p2.y, y: p2.x)
        }
        if p2.x < p1.x {
            let tmp = p1
            p1 = p2
            p2 = tmp
        }

        let dx: Float
        let dy: Float

        if x2 > x1 {
            dx = Float(x2 - x1)
            dy = Float(y2 - y1)
        }
        else {
            dx = Float(x1 - x2)
            dy = Float(y1 - y2)
        }

        let angle = atan2f(dy, dx)

        internalBresenham(p1, p2, steep: steep) { point in
            plot(point.x, point.y, angle)
        }
    }

    func internalBresenham(
        _ p1: (x: Int, y: Int),
        _ p2: (x: Int, y: Int),
        steep: Bool,
        plot: ((x: Int, y: Int)) -> Void
    ) {

        let dX = p2.x - p1.x
        let dY = p2.y - p1.y

        let yStep = (dY >= 0) ? 1 : -1
        let slope = abs(Float(dY) / Float(dX))
        var error: Float = 0

        let x = p1.x
        var y = p1.y

        plot(steep ? (y, x) : (x, y))

        for x in x + 1...p2.x {
            error += slope
            if error >= 0.5 {
                y += yStep
                error -= 1
            }

            plot(steep ? (y, x) : (x, y))
        }
    }

    private struct LineSegmentChar: ExpressibleByStringLiteral {
        var symbol: String
        var color: ConsoleColor?

        init(symbol: String) {
            self.symbol = symbol
            self.color = nil
        }

        init(symbol: String, color: ConsoleColor?) {
            self.symbol = symbol
            self.color = color
        }

        init(stringLiteral value: String) {
            self.symbol = value
            self.color = nil
        }
    }
}
