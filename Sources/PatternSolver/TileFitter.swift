import Interval

class TileFitter {
    private let hint: PatternGrid.RunsHint
    private let tiles: [PatternTile]
    private var runs: [RunEntry]

    /// If `false`, indicates that no way to place the hints in the tiles that
    /// where provided was found.
    private(set) var isValid: Bool = false

    init(hint: PatternGrid.RunsHint, tiles: [PatternTile]) {
        self.hint = hint
        self.tiles = tiles
        self.runs = hint.runs.map {
            .init(count: $0)
        }

        fillHints()
    }

    private func fillHints() {
        guard let earliest = fitRunsEarliest() else {
            return
        }
        guard let latest = fitRunsLatest() else {
            return
        }

        isValid = true

        assert(earliest.count == latest.count)

        for (i, (early, late)) in zip(earliest, latest).enumerated() {
            runs[i].earliestStartIndex = early.start
            runs[i].latestStartIndex = late.start
        }
    }

    /// Returns the earliest possible dark tile in this run.
    ///
    /// Returns `nil` if `self.isValid == false`.
    func earliestDarkTile() -> Int? {
        guard let first = runs.first else {
            return nil
        }

        return first.earliestStartIndex
    }

    /// Returns the latest possible dark tile in this run.
    ///
    /// Returns `nil` if `self.isValid == false`.
    func latestDarkTile() -> Int? {
        guard let last = runs.last else {
            return nil
        }
        guard let latestStartIndex = last.latestStartIndex else {
            return nil
        }

        return latestStartIndex + last.count - 1
    }

    /// Attempts to fit a given set of runs in a given list of tiles, returning
    /// a list of intervals that describe the exact tile interval taken by each
    /// run in `runs` such that they occupy the earliest possible tile.
    ///
    /// If the runs cannot be fit in the given tiles, `nil` is returned, instead.
    ///
    /// The number of entries in the returned array is the same as `runs.runCount`.
    func fitRunsEarliest() -> [Interval<Int>]? {
        TileFitter._fitRunsRecursive(hint: hint, tiles: tiles)
    }

    /// Attempts to fit a given set of runs in a given list of tiles, returning
    /// a list of intervals that describe the exact tile interval taken by each
    /// run in `runs` such that they occupy the latest possible tile.
    ///
    /// If the runs cannot be fit in the given tiles, `nil` is returned, instead.
    ///
    /// The number of entries in the returned array is the same as `runs.runCount`.
    func fitRunsLatest() -> [Interval<Int>]? {
        guard let result = TileFitter._fitRunsRecursive(hint: hint.reversed, tiles: tiles.reversed()) else {
            return nil
        }

        // Invert results
        return result.reversed().map {
            .init(start: tiles.count - $0.end - 1, end: tiles.count - $0.start - 1)
        }
    }

    private static func fitRunsRecursive(
        hint: PatternGrid.RunsHint,
        tiles: [PatternTile],
        state: (startHintIndex: Int, startTileIndex: Int)? = nil
    ) -> [Interval<Int>]? {

        var result: [Interval<Int>] = []

        // For each run index, look for the next available space capable of
        // containing the required run.
        var currentIndex = 0
        outerLoop:
        for run in hint.runs {
            // 0-length runs are not allowed
            if run == 0 {
                return nil
            }

            if currentIndex >= tiles.count {
                break
            }

            while let nextSpaceInterval = tiles.nextAvailableSpace(fromIndex: currentIndex) {
                let nextSpaceTiles = tiles[nextSpaceInterval]
                
                let spaceLength = nextSpaceTiles.count

                guard spaceLength >= run else {
                    // If there are any dark tiles in this section, not being
                    // able to place the next necessary run results in a failure
                    if nextSpaceTiles.darkTileCount() > 0 {
                        return nil
                    }

                    currentIndex = nextSpaceInterval.endIndex
                    
                    continue
                }

                let latestFit = currentIndex + spaceLength - run

                // Attempt to fill the tiles, encompassing any dark tiles that
                // are neighboring the run, until we can fully fit the run.
                var index = currentIndex
                while index < latestFit {
                    let end = index + run
                    if end == tiles.count || nextSpaceTiles[end].state != .dark {
                        break
                    } else {
                        index += 1
                    }
                }

                let end = index + run
                if end <= tiles.count {
                    result.append(.init(start: index, end: end - 1))
                    currentIndex = end + 1

                    // If the run of tiles succeeds a dark tile, it means this
                    // run is too long
                    if index > 0 && tiles[index - 1].state == .dark {
                        return nil
                    }
                    
                    continue outerLoop
                }

                // Cannot fit tiles!
                return nil
            }
        }

        if result.count != hint.runCount {
            return nil
        } else {
            return result
        }
    }

    private static func _fitRunsRecursive(
        hint: PatternGrid.RunsHint,
        tiles: [PatternTile],
        state: (startHintIndex: Int, startTileIndex: Int)? = nil
    ) -> [Interval<Int>]? {

        // Hints have been satisfied
        if state?.startHintIndex == hint.runCount {
            return []
        }
        // No tiles available to fit!
        if state?.startTileIndex == tiles.count {
            return nil
        }

        let currentRunIndex = state?.startHintIndex ?? 0
        let currentRunLength = hint.runs[currentRunIndex]

        // 0-length runs are not allowed
        if currentRunLength == 0 {
            return nil
        }

        // Fit first tile in first available space and recursively place further
        // tiles until we find the first combination that fits properly.

        // For each run index, look for the next available space capable of
        // containing the required run.
        var currentIndex = state?.startTileIndex ?? 0
        let lastIndex = currentIndex + tiles.count - currentRunLength

        var result: [Interval<Int>] = []

        outerLoop:
        while currentIndex <= lastIndex, let nextSpaceInterval = tiles.nextAvailableSpace(fromIndex: currentIndex) {
            let nextSpaceTiles = tiles[nextSpaceInterval]
            
            let spaceLength = nextSpaceTiles.count

            guard spaceLength >= currentRunLength else {
                // If there are any dark tiles in this section, not being
                // able to place the next necessary run results in a failure
                if nextSpaceTiles.darkTileCount() > 0 {
                    return nil
                }

                currentIndex = nextSpaceInterval.endIndex
                continue
            }

            // Attempt to fill the tiles, encompassing any dark tiles that
            // are neighboring the run, until we can fully fit the run.
            var index = currentIndex
            while index < lastIndex {
                let end = index + currentRunLength
                if end == tiles.count || tiles[end].state != .dark {
                    break
                } else {
                    index += 1
                }
            }

            let end = index + currentRunLength
            if end <= tiles.count {
                let nextRun = end + 1

                // If the run of tiles succeeds a dark tile, it means this
                // run is too long and no valid solution is available.
                if index > 0 && tiles[index - 1].state == .dark {
                    return nil
                }

                // Recursively fit the remaining tiles
                if
                    let rest = _fitRunsRecursive(
                        hint: hint,
                        tiles: tiles,
                        state: (currentRunIndex + 1, nextRun)
                    )
                {
                    result.append(.init(start: index, end: end - 1))
                    result.append(contentsOf: rest)

                    break
                }

                // If tiles cannot fit here, increment index and try again
                currentIndex += 1
                continue
            }

            // Cannot fit tiles!
            return nil
        }

        if result.count != (hint.runCount - currentRunIndex) {
            return nil
        } else {
            return result
        }
    }

    private struct RunEntry {
        var count: Int
        var earliestStartIndex: Int?
        var latestStartIndex: Int?
    }
}

// [ ][O][ ][ ][O][ ][O][O][▋][ ][O][O][ ][ ]
// --
// [O][O][O]
// [O][O][O][O]
// [O][O]

// [O][O][O][▋][O][O][O][O][▋][▋][O][O][▋][▋]
