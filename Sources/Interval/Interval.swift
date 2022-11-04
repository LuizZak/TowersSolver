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

    /// Returns `true` if `value` is contained within the inclusive span
    /// (start, end) defined by this interval.
    public func contains(_ value: Bounds) -> Bool {
        start <= value && end >= value
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

public extension Interval where Bounds: Strideable {
    var asRange: Range<Bounds> {
        start..<(end.advanced(by: 1))
    }

    var asClosedRange: ClosedRange<Bounds> {
        start...end
    }
}

extension Interval: Sequence where Bounds: Strideable, Bounds.Stride: SignedInteger {
    public typealias Element = Bounds

    public func makeIterator() -> AnyIterator<Bounds> {
        AnyIterator((start...end).makeIterator())
    }
}
