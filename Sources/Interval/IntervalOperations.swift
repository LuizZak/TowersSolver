extension Range {
    /// Returns the union of this interval with another, such that the resulting
    /// interval is the minimal interval length capable of containing both intervals.
    public func union(_ other: Self) -> Self {
        let low = Swift.min(lowerBound, other.lowerBound)
        let high = Swift.max(upperBound, other.upperBound)

        return (low..<high)
    }
}

extension ClosedRange {
    /// Returns the union of this interval with another, such that the resulting
    /// interval is the minimal interval length capable of containing both intervals.
    public func union(_ other: Self) -> Self {
        let low = Swift.min(lowerBound, other.lowerBound)
        let high = Swift.max(upperBound, other.upperBound)

        return (low...high)
    }
}

extension Sequence {
    /// Returns a new array of intervals such that it covers the same interval
    /// ranges with the minimal number of intervals possible.
    ///
    /// Effectively simplifies long interwind interval lists with many overlapping
    /// intervals into single, longer segments that cover the same interval ranges.
    public func compactIntervals<Bound>() -> [Element] where Element == Range<Bound> {
        // Sort intervals first
        let arranged = sorted { $0.lowerBound < $1.lowerBound }

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

            if cur.overlaps(inter) {
                current = cur.union(inter)
            } else {
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

    /// Returns a new array of intervals such that it covers the same interval
    /// ranges with the minimal number of intervals possible.
    ///
    /// Effectively simplifies long interwind interval lists with many overlapping
    /// intervals into single, longer segments that cover the same interval ranges.
    public func compactIntervals<Bound>() -> [Element] where Element == ClosedRange<Bound> {
        // Sort intervals first
        let arranged = sorted { $0.lowerBound < $1.lowerBound }

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

            if cur.overlaps(inter) {
                current = cur.union(inter)
            } else {
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
