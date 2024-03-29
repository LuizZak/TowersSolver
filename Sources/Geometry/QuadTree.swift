/// Represents a tree for a 2D bounded area that may be split across four equally
/// sized sub-areas recursively. Used to aid in spatial querying of data.
///
/// https://en.wikipedia.org/wiki/Quadtree
public class QuadTree<Value: QuadTreeValue> {
    public typealias RectangleType = RectangleOf<Value.NumberType>
    public typealias Quadrants = (
        topLeft: QuadTree, topRight: QuadTree, bottomRight: QuadTree, bottomLeft: QuadTree
    )

    /// Max number of elements before this quad tree nodes splits into sub-nodes
    public var maxElements: Int = 10

    /// Max number of recursive nodes allowed
    public var maxDepth: Int = 5

    /// Depth of this quad tree node.
    /// 1 = the root node.
    fileprivate(set) public var depth: Int = 1

    /// Bounds of this quad tree node.
    public var bounds: RectangleType

    /// List of values on this quad tree node
    public var values: [Value] = []

    /// Four sub-quadrants for this node, in top-left, top-right, bottom-right and
    /// bottom-left order.
    ///
    /// Is nil, if this node is not yet split into sub-nodes.
    public var quadrants: Quadrants?

    public init(bounds: RectangleOf<Value.NumberType>) {
        self.bounds = bounds
        values = []
    }

    public func addValue(_ value: Value) {
        if values.count < maxElements || depth == maxDepth {
            values.append(value)
            return
        }

        let quads = split()

        func verifyQuadrants(with work: (QuadTree) -> Bool) -> Bool {
            if work(quads.topLeft) || work(quads.topRight) || work(quads.bottomRight)
                || work(quads.bottomLeft)
            {
                return true
            }
            return false
        }

        let added =
            verifyQuadrants(with: { (quad) -> Bool in
                if quad.bounds.contains(rect: value.bounds) {
                    quad.addValue(value)
                    return true
                }

                return false
            })

        if added {
            return
        }

        // Did not fit in any of the sub-quadrants- add value to itself
        values.append(value)
    }

    internal func split() -> Quadrants {
        if let quadrants = quadrants {
            return quadrants
        }

        let width = bounds.width / 2
        let height = bounds.height / 2

        let q1 = RectangleType(x: 0, y: 0, width: width, height: height)
        let q2 = RectangleType(x: width, y: 0, width: width, height: height)
        let q3 = RectangleType(x: width, y: height, width: width, height: height)
        let q4 = RectangleType(x: 0, y: height, width: width, height: height)

        let quads = (
            QuadTree(bounds: q1), QuadTree(bounds: q2),
            QuadTree(bounds: q3), QuadTree(bounds: q4)
        )

        quads.0.depth = depth + 1
        quads.1.depth = depth + 1
        quads.2.depth = depth + 1
        quads.3.depth = depth + 1

        quadrants = quads

        return quads
    }
}

/// Represents a value with a representable bound value.
public protocol QuadTreeValue: Equatable {
    associatedtype NumberType where NumberType: FloatingPoint

    var bounds: RectangleOf<NumberType> { get }
}

/// Represents a value that has a coordinate, which gets represented as a 0-sized
/// rectangle.
public protocol QuadTreePointValue: QuadTreeValue {
    var vector: Vector2<NumberType> { get }
}

extension QuadTreePointValue {
    public var bounds: RectangleOf<NumberType> {
        return RectangleOf<NumberType>(minimum: vector, maximum: vector)
    }
}
