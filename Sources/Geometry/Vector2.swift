/// A floating-point 2D vector
public typealias Vertex = Vector2<Float>

/// An integer 2D vector
public typealias IntPoint = Vector2<Int>

/// A protocol for vector types
public protocol VectorType {
    associatedtype Coordinate: Comparable

    var x: Coordinate { get }
    var y: Coordinate { get }
}

/// Represents a vertex that has up to 4 cardinal connections to other vertices.
public struct Vector2<T: Comparable>: VectorType {
    public var x: T
    public var y: T

    @inlinable
    public init(x: T, y: T) {
        self.x = x
        self.y = y
    }

    @inlinable
    public static func < (lhs: Vector2, rhs: Vector2) -> Bool {
        return lhs.x < rhs.x && lhs.y < rhs.y
    }

    @inlinable
    public static func <= (lhs: Vector2, rhs: Vector2) -> Bool {
        return lhs.x <= rhs.x && lhs.y <= rhs.y
    }

    @inlinable
    public static func > (lhs: Vector2, rhs: Vector2) -> Bool {
        return lhs.x > rhs.x && lhs.y > rhs.y
    }

    @inlinable
    public static func >= (lhs: Vector2, rhs: Vector2) -> Bool {
        return lhs.x >= rhs.x && lhs.y >= rhs.y
    }
}

// MARK: - Equatable / Hashable
extension Vector2: Equatable where T: Equatable {}
extension Vector2: Hashable where T: Hashable {}

// MARK: - Basic operators
extension Vector2 where T: Numeric {
    @inlinable
    public static func + (lhs: Vector2, rhs: Vector2) -> Vector2 {
        return Vector2(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    @inlinable
    public static func += (lhs: inout Vector2, rhs: Vector2) {
        lhs = lhs + rhs
    }

    @inlinable
    public static func - (lhs: Vector2, rhs: Vector2) -> Vector2 {
        return Vector2(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    @inlinable
    public static func -= (lhs: inout Vector2, rhs: Vector2) {
        lhs = lhs - rhs
    }

    @inlinable
    public static func * (lhs: Vector2, rhs: Vector2) -> Vector2 {
        return Vector2(x: lhs.x * rhs.x, y: lhs.y * rhs.y)
    }

    @inlinable
    public static func *= (lhs: inout Vector2, rhs: Vector2) {
        lhs = lhs * rhs
    }

    @inlinable
    public static func * (lhs: Vector2, rhs: T) -> Vector2 {
        return Vector2(x: lhs.x * rhs, y: lhs.y * rhs)
    }

    @inlinable
    public static func *= (lhs: inout Vector2, rhs: T) {
        lhs = lhs * rhs
    }
}

// MARK: - Signed operators
extension Vector2 where T: SignedNumeric {
    @inlinable
    public static prefix func - (lhs: Vector2) -> Vector2 {
        return Vector2(x: -lhs.x, y: -lhs.y)
    }

    /// Returns a perpendicular vector to this Vector2
    @inlinable
    public func perpendicular() -> Vector2 {
        return Vector2(x: -y, y: x)
    }
}

// MARK: - Binary Integers
extension Vector2 where T: BinaryInteger {
    @inlinable
    public static var zero: Vector2 {
        return Vector2(x: T(), y: T())
    }

    @inlinable
    public static var one: Vector2 {
        return Vector2(x: T(1), y: T(1))
    }

    @inlinable
    public static func / (lhs: Vector2, rhs: Vector2) -> Vector2 {
        return Vector2(x: lhs.x / rhs.x, y: lhs.y / rhs.y)
    }

    @inlinable
    public static func /= (lhs: inout Vector2, rhs: Vector2) {
        lhs = lhs / rhs
    }

    @inlinable
    public static func / (lhs: Vector2, rhs: T) -> Vector2 {
        return Vector2(x: lhs.x / rhs, y: lhs.y / rhs)
    }

    @inlinable
    public static func /= (lhs: inout Vector2, rhs: T) {
        lhs = lhs / rhs
    }
}

// MARK: - Floating Point Numbers
extension Vector2 where T: FloatingPoint {
    @inlinable
    public static var zero: Vector2 {
        return Vector2(x: T(0), y: T(0))
    }

    @inlinable
    public static var one: Vector2 {
        return Vector2(x: T(1), y: T(1))
    }

    @inlinable
    public init(x: Int, y: Int) {
        self.init(x: T(x), y: T(y))
    }

    @inlinable
    public static func / (lhs: Vector2, rhs: Vector2) -> Vector2 {
        return Vector2(x: lhs.x / rhs.x, y: lhs.y / rhs.y)
    }

    @inlinable
    public static func /= (lhs: inout Vector2, rhs: Vector2) {
        lhs = lhs / rhs
    }

    @inlinable
    public static func / (lhs: Vector2, rhs: T) -> Vector2 {
        return Vector2(x: lhs.x / rhs, y: lhs.y / rhs)
    }

    @inlinable
    public static func /= (lhs: inout Vector2, rhs: T) {
        lhs = lhs / rhs
    }
}

// MARK: - General methods

/// Returns the minimal vector across two vectors.
/// The returned Vector2 has the smallest x,y coordinates of both vectors.
@inlinable
public func min<T: Comparable>(_ a: Vector2<T>, _ b: Vector2<T>) -> Vector2<T> {
    var res = a

    res.x = min(a.x, b.x)
    res.y = min(a.y, b.y)

    return res
}

/// Returns the minimal vector across two vectors.
/// The returned Vector2 has the largest x,y coordinates of both vectors.
@inlinable
public func max<T: Comparable>(_ a: Vector2<T>, _ b: Vector2<T>) -> Vector2<T> {
    var res = a

    res.x = max(a.x, b.x)
    res.y = max(a.y, b.y)

    return res
}

/// Returns the minimal vector across the given vectors.
/// The returned Vector2 has the smallest x,y coordinates found on the vectors
/// list.
@inlinable
public func min<T: Comparable>(_ a: Vector2<T>, _ b: Vector2<T>, _ rem: Vector2<T>...) -> Vector2<T>
{
    return rem.reduce(min(a, b), min)
}

/// Returns the maximal vector across the given vectors.
/// The returned Vector2 has the largest x,y coordinates found on the vectors
/// list.
@inlinable
public func max<T: Comparable>(_ a: Vector2<T>, _ b: Vector2<T>, _ rem: Vector2<T>...) -> Vector2<T>
{
    return rem.reduce(max(a, b), max)
}
