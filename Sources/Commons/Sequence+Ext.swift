extension Sequence {
    /// Returns the number of objects in this array that return true when passed
    /// through a given predicate.
    public func count(where predicate: (Iterator.Element) throws -> Bool) rethrows -> Int {
        var count = 0
        
        for item in self where try predicate(item) {
            count += 1
        }
        
        return count
    }
}

extension Sequence where Iterator.Element: Equatable {
    /// Returns the count of values in this sequence type that equal the given
    /// `value`
    public func count(_ value: Iterator.Element) -> Int {
        return count { $0 == value }
    }
}
