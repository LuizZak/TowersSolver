class TileFitter {
    typealias TileList = [PatternTile]

    private let hint: PatternGrid.RunsHint
    private let tiles: TileList
    private var runs: [RunEntry]

    /// If `false`, indicates that no way to place the hints in the tiles that
    /// where provided was found.
    private(set) var isValid: Bool = false

    init(hint: PatternGrid.RunsHint, tiles: TileList) {
        self.hint = hint
        self.tiles = tiles
        self.runs = hint.runs.map {
            .init(count: $0)
        }

        fillHints()
    }

    private func fillHints() {
        guard hint.requiredEmptySpace <= tiles.count else {
            return
        }

        guard let earliest = fitRunsEarliest() else {
            return
        }
        guard let latest = fitRunsLatest() else {
            return
        }

        isValid = true

        assert(earliest.count == latest.count)

        for (i, (early, late)) in zip(earliest, latest).enumerated() {
            assert(early.lowerBound <= late.lowerBound)

            runs[i].earliestStartIndex = early.lowerBound
            runs[i].latestStartIndex = late.lowerBound
        }
    }

    /// Returns the list of potential run ranges for the tiles in this tile fitter.
    ///
    /// Returns `nil`, if `isValid == false`.
    func runRanges() -> [RunRange]? {
        guard isValid else {
            return nil
        }

        var result: [RunRange] = []

        for (i, run) in runs.enumerated() {
            guard
                let earliest = run.earliestStartIndex,
                let latest = run.latestStartIndex
            else {
                return nil
            }

            result.append(.init(
                hintIndex: i,
                earliestStartIndex: earliest,
                earliestEndIndex: earliest + run.count,
                latestStartIndex: latest,
                latestEndIndex: latest + run.count
            ))
        }

        return result
    }

    /// From a given tile index, returns the indices of the potential runs that
    /// overlap it.
    ///
    /// Returns `nil`, if `isValid == false`.
    func potentialRunIndices(forTileAt index: Int) -> [Int]? {
        guard isValid else {
            return nil
        }

        var result: [Int] = []

        for (i, entry) in runs.enumerated() {
            guard let totalSpan = entry.totalPotentialSpan else {
                assertionFailure("found nil run entry but isValid is true")
                return nil
            }

            if totalSpan.contains(index) {
                result.append(i)
            }
        }

        return result
    }

    /// Returns the unique lengths of the potential runs that overlap a given
    /// tile index.
    ///
    /// Returns `nil`, if `isValid == false`.
    func potentialRunLengths(forTileAt index: Int) -> Set<Int>? {
        guard let indices = potentialRunIndices(forTileAt: index) else {
            return nil
        }

        return Set(indices.map { self.runs[$0].count })
    }

    /// For each run in this tile fitter, returns an interval representing the
    /// tiles that that run overlap when it is laid out in earliest/latest order
    /// on the tile list.
    ///
    /// If no overlap is known to occur for that run entry, its entry is `nil`
    /// instead.
    func overlappingIntervals() -> [Range<Int>?] {
        return runs.map { runEntry in
            guard let earliest = runEntry.earliestStartIndex else {
                return nil
            }
            guard let latest = runEntry.latestStartIndex else {
                return nil
            }

            let earliestInterval = earliest..<(earliest + runEntry.count)
            let latestInterval = latest..<(latest + runEntry.count)

            guard earliestInterval.overlaps(latestInterval) else {
                return nil
            }

            let s = max(earliestInterval.lowerBound, latestInterval.lowerBound)
            let e = min(earliestInterval.upperBound, latestInterval.upperBound)
            
            return s..<e
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

    /// Returns a list of intervals, one per run in this tile fitter's hint list,
    /// representing the earliest possible allocation for the dark tile runs.
    ///
    /// Returns `nil` if `self.isValid == false`.
    func earliestAlignedRuns() -> [Range<Int>]? {
        guard isValid else {
            return nil
        }

        var result: [Range<Int>] = []

        for entry in runs {
            guard let earliest = entry.earliestStartIndex else {
                return nil
            }

            result.append(earliest..<earliest + entry.count)
        }

        return result
    }

    /// Returns a list of intervals, one per run in this tile fitter's hint list,
    /// representing the latest possible allocation for the dark tile runs.
    ///
    /// Returns `nil` if `self.isValid == false`.
    func latestAlignedRuns() -> [Range<Int>]? {
        guard isValid else {
            return nil
        }

        var result: [Range<Int>] = []

        for entry in runs {
            guard let latest = entry.latestStartIndex else {
                return nil
            }

            result.append(latest..<latest + entry.count)
        }

        return result
    }

    /// Returns a list of tile indices surrounding a given tile index that are
    /// definitely dark, based on the potential run lengths that cross the tile
    /// and its surrounding boundaries.
    func guaranteedDarkTilesSurrounding(tileAtIndex index: Int) -> [Int] {
        guard let availableSpace = tiles.availableSpaceSurrounding(index: index) else {
            return []
        }

        guard let runIndices = potentialRunIndices(forTileAt: index) else {
            return []
        }
        let runLengths = runIndices.map { runs[$0].count }

        let minLength = runLengths.min() ?? 0
        guard minLength > 0 else {
            return []
        }

        let tilesAtSpace = tiles[availableSpace]

        // If the range contains dark tiles, attempt to find the smallest run
        // that fits the available space exactly
        if tilesAtSpace.hasDarkTile() {
            // If the space exactly fits the smallest run, return it.
            if minLength == availableSpace.count {
                return Array(availableSpace)
            }

            // If the space precedes or succeeds a separator, return a run that
            // is at least minLength in size around that separator
            let runs = tiles.darkTileRuns()
            if let lastRun = runs.last, lastRun.contains(index), lastRun.upperBound == availableSpace.upperBound {
                return Array((lastRun.upperBound - minLength)..<availableSpace.upperBound)
            }
            if let firstRun = runs.first, firstRun.contains(index), firstRun.lowerBound == availableSpace.lowerBound {
                return Array(availableSpace.lowerBound..<(firstRun.lowerBound + minLength))
            }
        }

        return []
    }

    /// Attempts to fit a given set of runs in a given list of tiles, returning
    /// a list of intervals that describe the exact tile interval taken by each
    /// run in `runs` such that they occupy the earliest possible tile.
    ///
    /// If the runs cannot be fit in the given tiles, `nil` is returned, instead.
    ///
    /// The number of entries in the returned array is the same as `runs.runCount`.
    func fitRunsEarliest() -> [Range<Int>]? {
        _fitRuns(hint: hint, tiles: tiles)
    }

    /// Attempts to fit a given set of runs in a given list of tiles, returning
    /// a list of intervals that describe the exact tile interval taken by each
    /// run in `runs` such that they occupy the latest possible tile.
    ///
    /// If the runs cannot be fit in the given tiles, `nil` is returned, instead.
    ///
    /// The number of entries in the returned array is the same as `runs.runCount`.
    func fitRunsLatest() -> [Range<Int>]? {
        guard let result = _fitRuns(hint: hint.reversed, tiles: tiles.reversed()) else {
            return nil
        }

        // Invert results
        return result.reversed().map {
            (tiles.count - $0.upperBound)..<(tiles.count - $0.lowerBound)
        }
    }

    private struct RunEntry {
        var count: Int
        var earliestStartIndex: Int?
        var latestStartIndex: Int?

        var totalPotentialSpan: Range<Int>? {
            guard let earliestStartIndex = earliestStartIndex else {
                return nil
            }
            guard let latestStartIndex = latestStartIndex else {
                return nil
            }
            
            return earliestStartIndex..<latestStartIndex + count
        }
    }

    /// A range of potential starting tile indices for a tile run in a tile fitter.
    struct RunRange {
        /// The 0-based index of the hint on its column or row, as initialized
        /// with the hint list on the associated `TileFitter`.
        var hintIndex: Int

        /// The earliest starting index that this run could be placed and still
        /// fulfill the remaining hints on the tile list.
        var earliestStartIndex: Int
        
        /// The earliest ending index that this run could be placed and still
        /// fulfill the remaining hints on the tile list, based on
        /// `earliestStartIndex` and the count of tiles of the associated hint.
        ///
        /// Is inclusive, for the purposes of indexing into the grid.
        var earliestEndIndex: Int

        /// The latest starting index that this run could be placed and still
        /// fulfill the remaining hints on the tile list.
        var latestStartIndex: Int

        /// The latest ending index that this run could be placed and still
        /// fulfill the remaining hints on the tile list, based on
        /// `latestStartIndex` and the count of tiles of the associated hint.
        ///
        /// Is inclusive, for the purposes of indexing into the grid.
        var latestEndIndex: Int
    }
}

private func _fitRuns<TileList: BidirectionalCollection>(
    hint: PatternGrid.RunsHint,
    tiles: TileList
) -> [Range<Int>]? where TileList.Element == PatternTile, TileList.Index == Int {

    var enclosedRuns: [Range<Int>] = []

    // Skip past enclosed tile runs that are solved
    let firstTiles = tiles.leftmostEnclosedDarkTileRuns()
    let state: (startHintIndex: Int, startTileIndex: Int)?

    if firstTiles.count > hint.runCount {
        return nil
    }

    if let lastTile = firstTiles.last?.upperBound {
        if !hint.runs[..<firstTiles.count].elementsEqual(firstTiles.map(\.count)) {
            return nil
        }

        for initialRun in firstTiles {
            enclosedRuns.append(initialRun)
        }

        state = (
            startHintIndex: firstTiles.count,
            startTileIndex: lastTile
        )
    } else {
        state = nil
    }
    
    var runs: [Range<Int>]
    runs = enclosedRuns
    runs += Array<Range<Int>>(repeating: 0..<0, count: hint.runCount - enclosedRuns.count)

    if
        _fitRunsRecursive(
            hint: hint,
            tiles: tiles,
            state: state,
            resultArray: &runs
        )
    {
        return runs
    }

    return nil
}

// Recursively fills a set of ranges fitting a particular configuration of tiles
// and hints, from a given state.
//
// Returns false if no solution was found for the given configuration of hint and
// tiles from the current state, or true if either no hints are left to fulfill,
// or the leftmost-aligned sets of runs of dark tiles that can fulfill the hints
// where able to be placed in `resultArray`.
private func _fitRunsRecursive<TileList: BidirectionalCollection>(
    hint: PatternGrid.RunsHint,
    tiles: TileList,
    state: (startHintIndex: Int, startTileIndex: Int)? = nil,
    resultArray: inout [Range<Int>]
) -> Bool where TileList.Element == PatternTile, TileList.Index == Int {

    var currentIndex = state?.startTileIndex ?? 0

    // Hints have been satisfied
    if state?.startHintIndex == hint.runCount {
        // Check if remaining tiles have no dark tiles
        if currentIndex < tiles.count && tiles[currentIndex...].hasDarkTile() {
            return false
        }

        return true
    }
    // No tiles available to fit!
    if state?.startTileIndex == tiles.count {
        return false
    }

    let currentRunIndex = state?.startHintIndex ?? 0
    let currentRunLength = hint.runs[currentRunIndex]

    // 0-length runs are not allowed
    if currentRunLength == 0 {
        return false
    }

    // Fit first tile in first available space and recursively place further
    // tiles until we find the first combination that fits properly.

    // For each run index, look for the next available space capable of
    // containing the required run.
    let lastIndex = currentIndex + tiles.count - currentRunLength

    let resultIndex = state?.startHintIndex ?? 0

    var foundFit = false

    outerLoop:
    while currentIndex <= lastIndex, let nextSpaceInterval = tiles.nextAvailableSpace(fromIndex: currentIndex) {
        let nextSpaceTiles = tiles[nextSpaceInterval]
        
        let spaceLength = nextSpaceTiles.count

        guard spaceLength >= currentRunLength else {
            // If there are any dark tiles in this section, not being
            // able to place the next necessary run results in a failure
            if nextSpaceTiles.hasDarkTile() {
                return false
            }

            currentIndex = nextSpaceInterval.endIndex
            continue
        }

        // Attempt to fill the tiles, encompassing any dark tiles that
        // are neighboring the run, until we can fully fit the run.
        var index = nextSpaceInterval.startIndex
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
                return false
            }

            // Recursively fit the remaining tiles
            if
                _fitRunsRecursive(
                    hint: hint,
                    tiles: tiles,
                    state: (currentRunIndex + 1, nextRun),
                    resultArray: &resultArray
                )
            {
                
                resultArray[resultIndex] = index..<end
                
                foundFit = true
                
                break
            }

            // If tiles cannot fit here, increment index and try again
            currentIndex = nextSpaceInterval.startIndex + 1
            continue
        }

        // Cannot fit tiles!
        return false
    }
    
    guard foundFit else {
        return false
    }

    // List of results should encompass exactly all the dark tiles that are
    // present from the requested index on the tile list onwards.
    let startTileIndex = state?.startTileIndex ?? 0
    for index in startTileIndex..<tiles.count where tiles[index].state == .dark {
        if !resultArray.contains(where: { $0.contains(index) }) {
            return false
        }
    }
    
    return true
}
