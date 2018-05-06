/// A floating-point 2D vector
public typealias Vertex = Vector2<Float>

/// An integer 2D vector
public typealias IntPoint = Vector2<Int>

/// A protocol for vector types
public protocol VectorType {
    associatedtype Coordinate: Numeric & Hashable
    
    var x: Coordinate { get }
    var y: Coordinate { get }
}

/// Represents a vertex that has up to 4 cardinal connections to other vertices.
public struct Vector2<T: Numeric & Hashable>: Hashable, VectorType {
    public var x: T
    public var y: T
    
    public init(x: T, y: T) {
        self.x = x
        self.y = y
    }
}

// MARK: - Basic operators
public extension Vector2 {
    public static func +(lhs: Vector2, rhs: Vector2) -> Vector2 {
        return Vector2(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    public static func +=(lhs: inout Vector2, rhs: Vector2) {
        lhs = lhs + rhs
    }
    
    public static func -(lhs: Vector2, rhs: Vector2) -> Vector2 {
        return Vector2(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    public static func -=(lhs: inout Vector2, rhs: Vector2) {
        lhs = lhs - rhs
    }
    
    public static func *(lhs: Vector2, rhs: Vector2) -> Vector2 {
        return Vector2(x: lhs.x * rhs.x, y: lhs.y * rhs.y)
    }
    
    public static func *=(lhs: inout Vector2, rhs: Vector2) {
        lhs = lhs * rhs
    }
    
    public static func *(lhs: Vector2, rhs: T) -> Vector2 {
        return Vector2(x: lhs.x * rhs, y: lhs.y * rhs)
    }
    
    public static func *=(lhs: inout Vector2, rhs: T) {
        lhs = lhs * rhs
    }
}

// MARK: - Comparison
extension Vector2: Comparable where T: Comparable {
    public static func <(lhs: Vector2, rhs: Vector2) -> Bool {
        return lhs.x < rhs.x && lhs.y < rhs.y
    }
    
    public static func <=(lhs: Vector2, rhs: Vector2) -> Bool {
        return lhs.x <= rhs.x && lhs.y <= rhs.y
    }
    
    public static func >(lhs: Vector2, rhs: Vector2) -> Bool {
        return lhs.x > rhs.x && lhs.y > rhs.y
    }
    
    public static func >=(lhs: Vector2, rhs: Vector2) -> Bool {
        return lhs.x >= rhs.x && lhs.y >= rhs.y
    }
}

// MARK: - Signed operators
public extension Vector2 where T: SignedNumeric {
    public static prefix func -(lhs: Vector2) -> Vector2 {
        return Vector2(x: -lhs.x, y: -lhs.y)
    }
    
    /// Returns a perpendicular vector to this Vector2
    public func perpendicular() -> Vector2 {
        return Vector2(x: -y, y: x)
    }
}

// MARK: - Binary Integers
public extension Vector2 where T: BinaryInteger {
    public static var zero: Vector2 {
        return Vector2(x: T(), y: T())
    }
    
    public static var one: Vector2 {
        return Vector2(x: T(1), y: T(1))
    }
    
    public static func /(lhs: Vector2, rhs: Vector2) -> Vector2 {
        return Vector2(x: lhs.x / rhs.x, y: lhs.y / rhs.y)
    }
    
    public static func /=(lhs: inout Vector2, rhs: Vector2) {
        lhs = lhs / rhs
    }
    
    public static func /(lhs: Vector2, rhs: T) -> Vector2 {
        return Vector2(x: lhs.x / rhs, y: lhs.y / rhs)
    }
    
    public static func /=(lhs: inout Vector2, rhs: T) {
        lhs = lhs / rhs
    }
}

// MARK: - Floating Point Numbers
public extension Vector2 where T: FloatingPoint {
    public static var zero: Vector2 {
        return Vector2(x: T(0), y: T(0))
    }
    
    public static var one: Vector2 {
        return Vector2(x: T(1), y: T(1))
    }
    
    public init(x: Int, y: Int) {
        self.init(x: T(x), y: T(y))
    }
    
    public static func /(lhs: Vector2, rhs: Vector2) -> Vector2 {
        return Vector2(x: lhs.x / rhs.x, y: lhs.y / rhs.y)
    }
    
    public static func /=(lhs: inout Vector2, rhs: Vector2) {
        lhs = lhs / rhs
    }
    
    public static func /(lhs: Vector2, rhs: T) -> Vector2 {
        return Vector2(x: lhs.x / rhs, y: lhs.y / rhs)
    }
    
    public static func /=(lhs: inout Vector2, rhs: T) {
        lhs = lhs / rhs
    }
}

// MARK: - General methods

/// Returns the minimal vector across two vectors.
/// The returned Vector2 has the smallest x,y coordinates of both vectors.
public func min<T: Comparable>(_ a: Vector2<T>, _ b: Vector2<T>) -> Vector2<T> {
    var res = a
    
    res.x = min(a.x, b.x)
    res.y = min(a.y, b.y)
    
    return res
}

/// Returns the minimal vector across two vectors.
/// The returned Vector2 has the largest x,y coordinates of both vectors.
public func max<T: Comparable>(_ a: Vector2<T>, _ b: Vector2<T>) -> Vector2<T> {
    var res = a
    
    res.x = max(a.x, b.x)
    res.y = max(a.y, b.y)
    
    return res
}

/// Returns the minimal vector across the given vectors.
/// The returned Vector2 has the smallest x,y coordinates found on the vectors
/// list.
public func min<T: Comparable>(_ a: Vector2<T>, _ b: Vector2<T>, _ rem: Vector2<T>...) -> Vector2<T> {
    return rem.reduce(min(a, b), min)
}

/// Returns the maximal vector across the given vectors.
/// The returned Vector2 has the largest x,y coordinates found on the vectors
/// list.
public func max<T: Comparable>(_ a: Vector2<T>, _ b: Vector2<T>, _ rem: Vector2<T>...) -> Vector2<T> {
    return rem.reduce(max(a, b), max)
}
