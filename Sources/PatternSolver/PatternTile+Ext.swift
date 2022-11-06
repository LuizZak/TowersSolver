import Commons

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
        return indexRanges(where: { $0.state == .dark })
    }

    /// Returns every sequential list of non-light tiles in this tile collection.
    func availableSpaceRuns() -> [Range<Index>] {
        return indexRanges(where: { $0.state != .light })
    }

    /// Returns a list of sequential dark tiles that are enclosed in either the
    /// boundaries of the collection or are enclosed between light tiles.
    ///
    /// List is capped at the first run of dark tiles that is not enclosed.
    func leftmostEnclosedDarkTileRuns() -> [Range<Index>] {
        var ranges: [Range<Index>] = []
        var currentRunStart: Index?

        for index in indices {
            let state = self[index].state
            
            if state == .undecided {
                currentRunStart = nil
                break
            }

            if let runStart = currentRunStart {
                if state == .light {
                    ranges.append(
                        runStart..<index
                    )

                    currentRunStart = nil
                }
            } else if state == .dark {
                currentRunStart = index
            }
        }

        // Close current run, if it's still open
        if let currentRunStart = currentRunStart {
            ranges.append(currentRunStart..<self.endIndex)
        }

        return ranges
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
        nextIndexRange(fromIndex: start, where: { !$0.state.isSeparator })
    }
}

extension BidirectionalCollection where Element == PatternTile {
    /// Returns the total span of available space that surround a given tile index.
    ///
    /// Returns `nil` if no available spaces are found surrounding the given index.
    ///
    /// - precondition: `self.indices.contains(index)`.
    func availableSpaceSurrounding(index: Index) -> Range<Index>? {
        let predicate: (Element) -> Bool = { !$0.state.isSeparator }

        return indicesSurrounding(index: index, where: predicate)
    }
}
