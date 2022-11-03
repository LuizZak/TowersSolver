import Interval

extension Sequence where Element == PatternTile {
    /// Returns the number of tiles in this sequence of tiles that have a state of
    /// `PatternTile.State.undecided`.
    func undecidedTileCount() -> Int {
        count(where: { $0.state == .undecided })
    }

    /// Returns the number of tiles in this sequence of tiles that have a state of
    /// `PatternTile.State.dark`.
    func darkTileCount() -> Int {
        count(where: { $0.state == .dark })
    }

    /// Returns the number of tiles in this sequence of tiles that have a state of
    /// `PatternTile.State.light`.
    func lightTileCount() -> Int {
        count(where: { $0.state == .light })
    }

    /// Returns `true` if a tile in this sequence has a state of `PatternTile.State.undecided`.
    func hasUndecidedTile() -> Bool {
        contains { $0.state == .undecided }
    }

    /// Returns `true` if a tile in this sequence has a state of `PatternTile.State.dark`.
    func hasDarkTile() -> Bool {
        contains { $0.state == .dark }
    }

    /// Returns `true` if a tile in this sequence has a state of `PatternTile.State.light`.
    func hasLightTile() -> Bool {
        contains { $0.state == .light }
    }
}

extension Collection where Element == PatternTile {
    /// Returns every sequential list of dark tiles in this tile collection.
    func darkTileRuns() -> [Range<Index>] {
        var intervals: [Interval<Index>] = []

        for index in indices {
            if self[index].state == .dark {
                intervals.append(
                    .init(start: index, end: self.index(after: index))
                )
            }
        }

        intervals = intervals.compactIntervals()

        return intervals.map { ($0.start..<$0.end) }
    }

    /// Returns a list of sequential dark tiles that are enclosed in either the
    /// boundaries of the collection or are enclosed between light tiles.
    ///
    /// List is capped at the first run of dark tiles that is not enclosed.
    func leftmostEnclosedDarkTileRuns() -> [Range<Index>] {
        /*
        return darkTileRuns().prefix { range in
            if range.lowerBound > startIndex && self[range.lowerBound].state != .light {
                return false
            }
            if range.upperBound < endIndex && self[range.upperBound].state != .light {
                return false
            }

            return true
        }
        */

        var intervals: [Interval<Index>] = []
        var lastTileState: PatternTile.State?
        var current: Index?

        for index in indices {
            defer { lastTileState = self[index].state }
            
            if let c = current {
                if self[index].state == .light {
                    intervals.append(
                        .init(start: c, end: index)
                    )

                    current = nil
                } else if self[index].state == .undecided {
                    current = nil
                    break
                }
            } else if self[index].state == .dark {
                // If this run starts after an undecided tile, stop counting the
                // runs.
                if lastTileState == .undecided {
                    current = nil
                    break
                }

                current = index
            } else if self[index].state == .undecided {
                break
            }
        }

        // Close current runs
        if let current = current {
            intervals.append(.init(start: current, end: self.endIndex))
        }

        return intervals.map { ($0.start..<$0.end) }
    }

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
    /// - precondition: if `start` is non-`nil`: `self.indices.contains(index)`.
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

extension BidirectionalCollection where Element == PatternTile {
    /// Returns the total span of available space that surround a given tile index.
    ///
    /// Returns `nil` if no available spaces are found surrounding the given index.
    ///
    /// - precondition: `self.indices.contains(index)`.
    func availableSpaceSurrounding(index: Index) -> Range<Index>? {
        var start = index
        if self[start].state == .light {
            return nil
        }

        // Backtrack from current index until either a light tile or the start
        // of the collection is found
        while start > startIndex && self[start].state != .light {
            start = self.index(before: start)
        }

        return nextAvailableSpace(fromIndex: start)
    }
}
