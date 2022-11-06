public extension Collection {
    /// Returns every range of sequential indices from this collection whose
    /// element at that index satisfies a given predicate.
    func indexRanges(where predicate: (Element) -> Bool) -> [Range<Index>] {
        let runs = self.indices.split(whereSeparator: { !predicate(self[$0]) })
        let result = runs.map { run in
            run.startIndex..<run.endIndex
        }
        
        return result
    }

    /// Returns the interval of indices of the elements in this collection that
    /// satisfy `predicate`, optionally starting from index `start`.
    ///
    /// If `start` is `nil`, it is assumed to be `self.startIndex`.
    ///
    /// Returns `nil` if no element past `start` (or `self.startIndex`, if `start`
    /// is `nil`), including itself, satisfy `predicate`.
    ///
    /// - precondition: if `start` is non-`nil`: `self.indices.contains(index)`.
    func nextIndexRange(fromIndex start: Index? = nil, where predicate: (Element) -> Bool) -> Range<Index>? {
        var searchHead = start ?? startIndex
        var currentStart: Index? = nil

        while searchHead < endIndex {
            defer { formIndex(after: &searchHead) }

            if !predicate(self[searchHead]) {
                if let currentStart = currentStart {
                    return currentStart..<searchHead
                }
            } else if currentStart == nil {
                currentStart = searchHead
            }
        }

        // Unclosed search: return remaining of indices.
        if let currentStart = currentStart {
            return currentStart..<searchHead
        }

        return nil
    }
}

public extension BidirectionalCollection {
    /// Returns the total span of indices surrounding an input index such that
    /// the whole neighborhood of indices satisfies `predicate`.
    ///
    /// Returns `nil` if no index, including `index`, satisfies the predicate.
    ///
    /// - precondition: `self.indices.contains(index)`.
    func indicesSurrounding(index: Index, where predicate: (Element) -> Bool) -> Range<Index>? {
        var start = index
        if !predicate(self[start]) {
            return nil
        }

        // Backtrack from current index until `predicate` fails or the start of
        // the collection is found.
        while start > startIndex && predicate(self[start]) {
            start = self.index(before: start)
        }

        return nextIndexRange(fromIndex: start, where: predicate)
    }
}
