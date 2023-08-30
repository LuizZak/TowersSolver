import Geometry

/// Class used to perform guessing fills of undecided tiles in a Pattern grid
internal class PatternGuesser {
    let grid: PatternGrid

    init(grid: PatternGrid) {
        self.grid = grid
    }

    /// Generates a grid based on the nth available guess given the current
    /// grid's state.
    ///
    /// Returns `nil` if no guess that leads to a valid game state could be
    /// produced from the current grid.
    func generateNextGuessGrid(index: Int = 0) -> PatternGrid? {
        guard let guess = generateNextGuess(index: index) else {
            return nil
        }

        return guess.applied(to: grid)
    }

    /// Generates the nth available guess given the current grid's state.
    ///
    /// Returns `nil` if no guess that leads to a valid game state could be
    /// produced from the current grid.
    func generateNextGuess(index: Int = 0) -> Guess? {
        let guesses = generateAllGuesses()
        if guesses.isEmpty || index >= guesses.count {
            return nil
        }

        // Find the nth guess by sorting the guesses by the number of tiles they
        // would affect, followed by whether there are logical inversions to the
        // guess move that can be used to push the solver forward in case the
        // guess results in an invalid grid, followed last by the number of
        // other ambiguous runs in the same column/row, favoring guesses that
        // attempt to pin down the last run of a column/row instead of ones that
        // still have many runs left.
        let sortedGuesses = guesses.sorted(by: {
            if $0._undecidedRuns < $1._undecidedRuns {
                return true
            }
            if $0._undecidedRuns > $1._undecidedRuns {
                return false
            }

            let lhsHasInverse = !$0.invalidatingMoves.isEmpty
            let rhsHasInverse = !$1.invalidatingMoves.isEmpty

            switch (lhsHasInverse, rhsHasInverse) {
            case (true, true), (false, false):
                return $0.move.affectedTileCoordinates.count > $1.move.affectedTileCoordinates.count
            
            case (false, true):
                return false
            case (true, false):
                return true
            }
        })

        return sortedGuesses[index]
    }

    /// Generates an array of potential guesses given the current grid's state.
    ///
    /// Returns an empty array if no guess that leads to a valid game state could
    /// be produced from the current grid.
    private func generateAllGuesses() -> [Guess] {
        var guesses: [Guess] = []

        var views: [(PatternGrid.RunsHint, GridTileView<PatternGrid>)] = []

        for column in 0..<grid.columns {
            let hint = grid.hintForColumn(column)
            let tiles = grid.tilesInColumn(column)

            views.append((hint, tiles))
        }

        for row in 0..<grid.rows {
            let hint = grid.hintForRow(row)
            let tiles = grid.tilesInRow(row)

            views.append((hint, tiles))
        }

        for (hint, tiles) in views {
            // Check that there are available tiles to be placed in the grid
            guard tiles.contains(where: { $0.state == .undecided }) else {
                continue
            }

            let tileFitter = TileFitter(hint: hint, tiles: Array(tiles))

            // TODO: Should return an empty array for non-solvable hints?
            guard tileFitter.isValid, let runRanges = tileFitter.runRanges() else {
                continue
            }

            let undecidedRuns: Int = runRanges.reduce(0) { (total, run) in
                let isDecided = run.earliestStartIndex == run.latestStartIndex
                return total + (isDecided ? 0 : 1)
            }

            var isFirstUndecidedRun = true

            // Find first run that has a range of potential start indices and
            // use it
            for run in runRanges {
                guard run.earliestStartIndex != run.latestStartIndex else {
                    continue
                }

                defer { isFirstUndecidedRun = false }

                let start = run.earliestStartIndex
                let end = run.earliestEndIndex

                let tilesToMark = tiles[subViewInRange: start...end]
                
                let guessMove = PatternMove.markAsDark(tilesToMark)
                var guessInverse: [PatternMove] = []

                // Invert guess: start by analyzing guesses of earliest-aligned
                // runs of tiles, and disable the guess by moving the run forward
                // by marking another trailing dark tile on an existing dark tile
                // run on the grid.
                if
                    grid[guessMove.affectedTileCoordinates].contains(where: {
                        $0.state == .dark
                    })
                {
                    // Extrapolate dark tile coordinates by one, and check if we
                    // are still inside the grid
                    let coord = tilesToMark[coordinateAt: tilesToMark.count]
                    if grid.isWithinBounds(coord) && grid[coord].state == .undecided {
                        guessInverse.append(.markAsDark(grid.viewForTile(coord)))
                    }
                }
                
                // For the first undecided runs of the column/row, the
                // inversion of the guess equates to marking the leading
                // tile of the guess as white, pushing the undecided run to
                // the next possible tile.
                if isFirstUndecidedRun {
                    let coord = tilesToMark[coordinateAt: 0]
                    guessInverse.append(.markAsLight(grid.viewForTile(coord)))
                }

                guesses.append(.init(
                    _undecidedRuns: undecidedRuns,
                    move: guessMove,
                    invalidatingMoves: guessInverse
                ))
            }
        }

        return guesses
    }

    struct Guess {
        /// Count of undecided runs in the column/row that this guess was derived
        /// from.
        fileprivate var _undecidedRuns: Int

        /// The move that composes this guess.
        var move: PatternMove

        /// A list of atomic moves that may be made in order to invalidate the
        /// move of this guess, effectively the reverse of a binary logic for
        /// the guess, in case the guess results in an invalid grid state.
        ///
        /// May be empty, if the guess cannot be associated with moves that
        /// logically invert it on the grid.
        var invalidatingMoves: [PatternMove]

        func applied(to grid: PatternGrid) -> PatternGrid {
            move.applied(to: grid)
        }
    }
}
