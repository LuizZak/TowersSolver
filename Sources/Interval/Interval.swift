public typealias IntInterval = Interval<Int>

/// Protocol for types that represent a closed interval between two comparable
/// objects.
public protocol IntervalProtocol: Equatable {
    associatedtype Bounds: Comparable

    var start: Bounds { get }
    var end: Bounds { get }
}

/// An interval that has a simple structure and thus can be initialized with just
/// start and end values.
public protocol ConstructibleIntervalProtocol: IntervalProtocol {
    init(start: Bounds, end: Bounds)
}

/// Represents a closed interval between two comparable objects.
public struct Interval<Bounds: Comparable>: ConstructibleIntervalProtocol {
    public var start: Bounds
    public var end: Bounds

    public init(start: Bounds, end: Bounds) {
        precondition(
            start <= end,
            "cannot create interval where start > end: provided \(start) > \(end)"
        )

        self.start = start
        self.end = end
    }

    public init<I: IntervalProtocol>(_ interval: I) where I.Bounds == Bounds {
        self.start = interval.start
        self.end = interval.end
    }
}

public extension Interval where Bounds: Numeric {
    /// Returns the magnitude (or positive distance) between the start and end
    /// of this interval.
    var distance: Bounds.Magnitude {
        (end - start).magnitude
    }
}

extension Interval: Hashable where Bounds: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(start)
        hasher.combine(end)
    }
}
