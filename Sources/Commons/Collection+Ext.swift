public extension Collection {
    /// Returns every range of sequential indices from this collection whose
    /// element at that index satisfies a given predicate.
    @inlinable
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
    @inlinable
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
    @inlinable
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

public extension Collection where Index == Int {
    /// Performs a binary search for a given value.
    ///
    /// Invoking this function implies the collection is sorted.
    func binarySearchIndex(value: Element) -> Index? where Element: Comparable {
        return binarySearchIndex(value: value, transform: { $0 })
    }
    
    /// Performs a binary search for a given value using a given transform
    /// function that takes an element of the collection and returns a
    /// comparable value.
    ///
    /// Invoking this function implies the collection is ordered such that when
    /// this collection is mapped by `transform`, the resulting array is sorted.
    func binarySearchIndex<T: Comparable>(value: T, transform: (Element) -> T) -> Index? {
        if isEmpty {
            return nil
        }
        if count == 1 {
            if first.map(transform) == value {
                return startIndex
            }
            
            return nil
        }
        
        let midIndex = (startIndex + endIndex) / 2
        let mid = self[midIndex]
        
        let midValue = transform(mid)
        
        if midValue == value {
            return midIndex
        }
        
        if midValue > value {
            return self[0..<midIndex].binarySearchIndex(value: value, transform: transform)
        } else {
            return self[midIndex..<endIndex].binarySearchIndex(value: value, transform: transform)
        }
    }
    
    /// Performs a binary search for an index to insert a given value such that
    /// the resulting collection is still sorted.
    ///
    /// Invoking this function implies the collection is sorted.
    func binarySearchInsert(value: Element) -> Index where Element: Comparable {
        return binarySearchInsert(value: value, transform: { $0 })
    }
    
    /// Performs a binary search for an index to insert a given value such that
    /// the resulting collection is still sorted.
    ///
    /// Invoking this function implies the collection is ordered such that when
    /// this collection is mapped by `transform`, the resulting array is sorted.
    func binarySearchInsert<T: Comparable>(value: Element, transform: (Element) -> T) -> Index {
        lazy var valueT = transform(value)
        
        if isEmpty {
            return startIndex
        }
        if count == 1 {
            if transform(self[startIndex]) > valueT {
                return startIndex
            } else {
                return endIndex
            }
        }
        
        let midIndex = (startIndex + endIndex) / 2
        let mid = self[midIndex]
        
        let midValue = transform(mid)
        
        if midValue == valueT {
            return midIndex
        }
        
        if midValue > valueT {
            return self[0..<midIndex].binarySearchInsert(value: value, transform: transform)
        } else {
            return self[midIndex..<endIndex].binarySearchInsert(value: value, transform: transform)
        }
    }
}
