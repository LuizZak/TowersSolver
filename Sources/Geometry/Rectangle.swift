public typealias FloatRectangle = RectangleOf<Float>
public typealias IntRectangle = RectangleOf<Int>

/// Represents a axis-aligned rectangle on a 2D plane.
public struct RectangleOf<T: Numeric & Hashable & Comparable>: Hashable {
    public typealias Vector = Vector2<T>
    
    public var minimum: Vector
    public var maximum: Vector
    
    public var x: T {
        return minimum.x
    }
    public var y: T {
        return minimum.y
    }
    public var width: T {
        return maximum.x - minimum.x
    }
    public var height: T {
        return maximum.y - minimum.y
    }
    
    public var top: T { return minimum.y }
    public var right: T { return maximum.x }
    public var bottom: T { return maximum.y }
    public var left: T { return minimum.x }
    
    public init(minimum: Vector, maximum: Vector) {
        self.minimum = minimum
        self.maximum = maximum
    }
    
    public init(x: T, y: T, width: T, height: T) {
        self.init(minimum: Vector(x: x, y: y),
                  maximum: Vector(x: x + width, y: y + height))
    }
    
    public init(boundsFor points: [Vector]) {
        guard let first = points.first else {
            minimum = Vector(x: 0, y: 0)
            maximum = Vector(x: 0, y: 0)
            return
        }
        
        minimum = first
        maximum = first
        
        for v in points {
            minimum = min(minimum, v)
            maximum = max(maximum, v)
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(minimum)
        hasher.combine(minimum)
    }
    
    public static func ==(lhs: RectangleOf, rhs: RectangleOf) -> Bool {
        return lhs.minimum == rhs.minimum && lhs.maximum == rhs.maximum
    }
    
    /// Returns whether this rectangle intersects another given rectangle.
    /// Intersections are inclusive, so if two rectangles are touching at the
    /// edges they are reported as intersecting, too.
    public func intersects(with other: RectangleOf) -> Bool {
        return minimum <= other.maximum && maximum >= other.minimum
    }
    
    /// Returns whether this rectangle contains a given point
    public func contains(_ vector: Vector) -> Bool {
        return vector >= minimum && vector <= maximum
    }
    
    /// Returns whether the given rectangle is completely contained within this
    /// rectangle
    public func contains(rect: RectangleOf) -> Bool {
        return minimum <= rect.minimum && maximum >= rect.maximum
    }
}

extension RectangleOf where T: BinaryInteger {
    /// Gets the center of this rectangle
    public var center: Vector {
        return (minimum + maximum) / 2
    }
}

extension RectangleOf where T: FloatingPoint {
    /// Gets the center of this rectangle
    public var center: Vector {
        return (minimum + maximum) / 2
    }
}
