import Interval

extension Sequence where Element == PatternTile {
    /// Returns the number of tiles in this sequence of tiles that have a state of
    /// `PatternTile.State.undecided`.
    func undecidedTileCount() -> Int {
        reduce(0, { $0 + ($1.state == .undecided ? 1 : 0) })
    }

    /// Returns the number of tiles in this sequence of tiles that have a state of
    /// `PatternTile.State.dark`.
    func darkTileCount() -> Int {
        reduce(0, { $0 + ($1.state == .dark ? 1 : 0) })
    }

    /// Returns the number of tiles in this sequence of tiles that have a state of
    /// `PatternTile.State.light`.
    func lightTileCount() -> Int {
        reduce(0, { $0 + ($1.state == .light ? 1 : 0) })
    }
}

extension Collection where Element == PatternTile {
    /// If this collection contains any dark tiles, returns the index of the
    /// first dark tile that precedes a non-dark tile immediately after it.
    ///
    /// Returns `nil` if this collection contains no dark tiles.
    func endOfFirstDarkTileRun() -> Index? {
        var index = startIndex
        var lastFound: Index? = nil

        while index < endIndex {
            defer { _=formIndex(&index, offsetBy: 1, limitedBy: endIndex) }

            let tile = self[index]
            if tile.state == .dark {
                lastFound = index
            } else if lastFound != nil {
                break
            }
        }

        return lastFound
    }

    /// Returns the interval of indices of the next available run of tiles in
    /// this collection whose tiles are not `PatternTile.State.isSeparator`,
    /// optionally providing an index to start the search from.
    ///
    /// Returns `nil` if no available spaces are found beyond the given start
    /// index.
    ///
    /// - precondition: if `start` is non-`nil`:
    /// `start >= self.startIndex && start < self.endIndex`.
    func nextAvailableSpace(fromIndex start: Index? = nil) -> Range<Index>? {
        var searchHead = start ?? startIndex
        var currentStart: Index? = nil

        while searchHead < endIndex {
            defer { formIndex(after: &searchHead) }

            if isSeparator(at: searchHead) {
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

    func isSeparator(at index: Index) -> Bool {
        self[index].state.isSeparator
    }
}
