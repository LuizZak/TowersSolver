extension IntervalProtocol {
    /// Returns true if `self` overlaps `Interval`.
    ///
    /// Unlike intersection, overlap only accounts for overlaps that result
    /// in a > 0 resulting overlap interval
    public func overlaps<I: IntervalProtocol>(_ other: I) -> Bool where I.Bounds == Bounds {
        return start < other.end && other.start < end
    }

    /// Returns true if `self` intersects `Interval`.
    ///
    /// Unlike overlapping, intersection takes into account ends of intervals
    /// meeting when they otherwise do not have a positive shared overlapping
    /// interval.
    public func intersects<I: IntervalProtocol>(_ other: I) -> Bool where I.Bounds == Bounds {
        return start <= other.end && other.start <= end
    }
}

extension ConstructibleIntervalProtocol {
    /// Returns the overlap with a given interval.
    ///
    /// Returns `nil`, in case no overlap is found.
    public func overlap<I: IntervalProtocol>(_ other: I) -> Self? where I.Bounds == Bounds {
        if end <= other.start || other.end <= start {
            return nil
        }

        let s = max(start, other.start)
        let e = min(end, other.end)

        return Self.init(start: s, end: e)
    }

    /// Returns the union of this interval with another, such that the resulting
    /// interval is the minimal interval length capable of containing both intervals.
    public func union<I: IntervalProtocol>(_ other: I) -> Self where I.Bounds == Bounds {
        let low = min(start, other.start)
        let high = max(end, other.end)

        return Self.init(start: low, end: high)
    }
}

extension Sequence where Element: ConstructibleIntervalProtocol {
    /// Returns a new array of intervals such that it covers the same interval
    /// ranges with the minimal number of intervals possible.
    ///
    /// Effectively simplifies long interwind interval lists with many overlapping
    /// intervals into single, longer segments that cover the same interval ranges.
    public func compactIntervals() -> [Element] {
        // Sort intervals first
        let arranged = sorted { $0.start < $1.start }

        var result: [Element] = []
        var current: Element?

        // Pick intervals, creating unions over overlapping interval regions,
        // and pushing these intervals to a result array once no more overlapping
        // intervals are found, repeating until all intervals are exhausted

        for inter in arranged {
            guard let cur = current else {
                current = inter
                continue
            }

            if cur.intersects(inter) {
                current = cur.union(inter)
            }
            else {
                // Append and reset
                current = inter
                result.append(cur)
            }
        }

        if let current = current {
            result.append(current)
        }

        return result
    }
}
