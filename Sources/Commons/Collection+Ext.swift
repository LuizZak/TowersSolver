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
}
