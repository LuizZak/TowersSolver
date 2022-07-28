/// A polygon is a sequence of vertices organized as a non-intersecting set of
/// edges.
public struct Polygon<T: Numeric & Comparable & Hashable> {
    public typealias Vector = Vector2<T>

    public var vertices: [Vector] {
        didSet {
            self.recalculateBounds()
        }
    }

    /// Minimum rectangle capable of fitting all vertices for this polygon.
    /// Updated whenever `self.vertices` is updated.
    private(set) public var bounds: RectangleOf<T>

    public init(vertices: [Vector]) {
        self.vertices = vertices
        self.bounds = RectangleOf(boundsFor: vertices)
    }

    public init() {
        self.vertices = []
        self.bounds = RectangleOf(boundsFor: [])
    }

    public mutating func addVertex(_ vertex: Vector) {
        vertices.append(vertex)
    }

    private mutating func recalculateBounds() {
        bounds = RectangleOf(boundsFor: vertices)
    }
}

extension Polygon where T: FloatingPoint {

    /// Returns whether a global point is inside this body
    public func contains(_ pt: Vector) -> Bool {
        guard vertices.count > 2, var v1 = vertices.last else {
            return false
        }

        // Check if the point is inside the AABB
        if !self.bounds.contains(pt) {
            return false
        }

        // basic idea: draw a line from the point to a point known to be outside
        // the body. count the number of lines in the polygon it intersects.
        // if that number is odd, we are inside.
        // if it's even, we are outside.
        // in this implementation we will always use a line that moves off in
        // the X direction from the point to simplify things.
        let endPt = Vector(x: bounds.maximum.x, y: pt.y) + Vector(x: 1, y: 0)

        // line we are testing against goes from pt -> endPt.
        var inside = false

        // If the line lies to the left of the body, apply the test going from
        // the point to the left this way we may end up reducing the total
        // amount of edges to test against.
        // This basic assumption may not hold for every body, but for most
        // bodies (specially round), this may hold true most of the time.
        for v2 in vertices {
            defer {
                v1 = v2
            }

            // perform check now...

            // The edge lies completely to the left of our imaginary line
            if v1.x < pt.x && v2.x < pt.x {
                continue
            }

            // Check if the edge crosses the imaginary horizontal line from
            // top to bottom or bottom to top
            if ((v1.y < pt.y) && (v2.y > pt.y)) || ((v1.y > pt.y) && (v2.y < pt.y)) {
                // this line crosses the test line at some point... does it
                // do so within our test range?
                let slope = (v2.x - v1.x) / (v2.y - v1.y)
                let hitX = v1.x + ((pt.y - v1.y) * slope)

                if (hitX >= pt.x) && (hitX <= endPt.x) {
                    inside = !inside
                }
            }
        }

        return inside
    }
}
