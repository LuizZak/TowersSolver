extension Sequence {
    /// Traverses the sequence, testing with a predicate and returning the only
    /// two elements which returned true for the sequence.
    ///
    /// In case less than two elements fulfil the predicate, or more than two
    /// fulfil it, nil is returned, instead.
    @inlinable
    public func onlyTwo(where predicate: (Iterator.Element) throws -> Bool) rethrows -> (
        first: Element, second: Element
    )? {
        var first: Element?
        var tuple: (Element, Element)?

        for item in self where try predicate(item) {
            if tuple != nil {
                return nil
            }

            if let first = first {
                tuple = (first, item)
            }
            else {
                first = item
            }
        }

        return tuple
    }

    /// Traverses the sequence, testing with a predicate and returning the only
    /// element which returned true for the sequence.
    ///
    /// In case no elements fulfils the predicate, or more than one element fulfils
    /// it, nil is returned, instead.
    @inlinable
    public func only(where predicate: (Iterator.Element) throws -> Bool) rethrows -> Element? {
        var element: Element? = nil

        for item in self where try predicate(item) {
            if element != nil {
                return nil
            }

            element = item
        }

        return element
    }

    /// Returns the number of objects in this array that return true when passed
    /// through a given predicate.
    @inlinable
    public func count(where predicate: (Iterator.Element) throws -> Bool) rethrows -> Int {
        var count = 0

        for item in self where try predicate(item) {
            count += 1
        }

        return count
    }

    /// Returns if the number of objects in this array that return true when
    /// passed through a given predicate matches an expected count.
    @inlinable
    public func count(
        _ count: Int,
        where predicate: (Iterator.Element) throws -> Bool
    ) rethrows -> Bool {

        var _count = 0

        for item in self where try predicate(item) {
            if _count >= count {
                return false
            }

            _count += 1
        }

        return _count == count
    }
}

extension Sequence where Iterator.Element: Equatable {
    /// Returns the count of values in this sequence type that equal the given
    /// `value`
    @inlinable
    public func count(_ value: Iterator.Element) -> Int {
        return count { $0 == value }
    }

    /// Returns the largest common subsequence of initial elements that are
    /// shared between `self` and `other`.
    @inlinable
    public func commonPrefix(sharedWith other: Self) -> [Element] {
        zip(self, other)
            .prefix(while: ==)
            .map(\.0)
    }

    /// Returns the largest common subsequence of final elements that are
    /// shared between `self` and `other`.
    @inlinable
    public func commonSuffix(sharedWith other: Self) -> [Element] {
        zip(self.reversed(), other.reversed())
            .prefix(while: ==)
            .map(\.0)
            .reversed()
    }
}

// Original `stableSorted` implementation by Tom:
// https://stackoverflow.com/a/50545761
extension Sequence {
    @inlinable
    public func stableSorted(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows
        -> [Element]
    {
        return try enumerated()
            .sorted { a, b -> Bool in
                try areInIncreasingOrder(a.element, b.element)
                    || (a.offset < b.offset && !areInIncreasingOrder(b.element, a.element))
            }
            .map { $0.element }
    }
}

extension Array {
    @inlinable
    public mutating func stableSort(by areInIncreasingOrder: (Element, Element) throws -> Bool)
        rethrows
    {
        self = try stableSorted(by: areInIncreasingOrder)
    }
}
