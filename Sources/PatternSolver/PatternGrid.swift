import Geometry

/// A grid for a pattern game.
public struct PatternGrid: GridType {
    public typealias TileType = PatternTile

    /// Matrix of tiles, stored as [columns][rows]
    private(set) public var tiles: [[TileType]] = []

    /// List of hints for this Pattern grid, stored as
    /// [column0, column1, ..., columnN, row0, row1, ..., rowN]
    public var hints: [RunsHint] = []

    public let rows: Int
    public let columns: Int

    public subscript(coordinates: Geometry.Coordinates) -> TileType {
        get {
            tiles[coordinates.column][coordinates.row]
        }
        set(newValue) {
            tiles[coordinates.column][coordinates.row] = newValue
        }
    }

    public subscript(column column: Int, row row: Int) -> PatternTile {
        get {
            tiles[column][row]
        }
        set(newValue) {
            tiles[column][row] = newValue
        }
    }

    public subscript(column column: Int) -> [TileType] {
        get { tiles[column] }
        set { tiles[column] = newValue }
    }

    /// Initializes a new Pattern grid instance
    ///
    /// - Parameters:
    ///   - rows: The number of horizontal rows on the grid. Must be greater than
    ///   0.
    ///   - columns: The number of vertical columns on the grid. Must be greater
    ///   than 0.
    ///
    /// - precondition: `rows > 0 && columns > 0`
    public init(rows: Int, columns: Int) {
        precondition(rows > 0, "Must have at least one row")
        precondition(columns > 0, "Must have at least one column")

        self.rows = rows
        self.columns = columns
        
        initGrid()
    }

    private mutating func initGrid() {
        tiles.removeAll()

        for _ in 0..<rows {
            let row = Array(repeating:
                PatternTile(state: .undecided),
                count: columns
            )

            tiles.append(row)
        }

        hints = Array(
            repeating: .init(runs: []),
            count: rows + columns
        )
    }

    /// Returns `true` if this grid's hints are fully solved.
    ///
    /// The grid must have no undecided spaces.
    public func isSolved() -> Bool {
        for column in tiles {
            for tile in column {
                if tile.state == .undecided {
                    return false
                }
            }
        }

        for row in (0..<rows) {
            let hint = hintForRow(row)
            let tiles = tilesInRow(row)

            if hint.runs != tiles.darkTileRuns().map(\.count) {
                return false
            }
        }

        for column in (0..<columns) {
            let hint = hintForColumn(column)
            let tiles = tilesInColumn(column)

            if hint.runs != tiles.darkTileRuns().map(\.count) {
                return false
            }
        }

        return true
    }

    /// Returns `true` if the grid at its current state is valid, that is,
    /// sequences of potential dark tile run hints can be fit in the current
    /// dark tile runs in the grid.
    public func isValid() -> Bool {
        for row in (0..<rows) {
            let hint = hintForRow(row)
            let tiles = tilesInRow(row)

            let fitter = TileFitter(hint: hint, tiles: Array(tiles))
            if !fitter.isValid {
                return false
            }
        }

        for column in (0..<columns) {
            let hint = hintForColumn(column)
            let tiles = tilesInColumn(column)

            let fitter = TileFitter(hint: hint, tiles: Array(tiles))
            if !fitter.isValid {
                return false
            }
        }

        return true
    }

    /// Returns a flat array of all tile states, organized in row-major order.
    public func statesForTiles() -> [PatternTile.State] {
        tilesSequential.map(\.state)
    }

    /// Returns the state for each tile in a specified row of this grid.
    ///
    /// - precondition: `row >= 0 && row <= self.rows`
    public func statesForRow(_ row: Int) -> [PatternTile.State] {
        precondition(row >= 0 && row <= rows, "\(row) >= 0 && \(row) <= \(rows)")

        var result: [PatternTile.State] = .init(repeating: .undecided, count: columns)

        for column in 0..<columns {
            result[column] = self[column: column, row: row].state
        }

        return result
    }

    /// Returns the state for each tile in a specified column of this grid.
    ///
    /// - precondition: `column >= 0 && column <= self.columns`
    public func statesForColumn(_ column: Int) -> [PatternTile.State] {
        precondition(column >= 0 && column <= columns, "\(column) >= 0 && \(column) <= \(columns)")

        var result: [PatternTile.State] = .init(repeating: .undecided, count: rows)

        for row in 0..<rows {
            result[row] = self[column: column, row: row].state
        }

        return result
    }

    /// Returns whether a tile with a specified state exists on a specified row
    /// of this grid.
    ///
    /// - precondition: `row >= 0 && row <= self.rows`
    public func rowContainsState(_ row: Int, state: PatternTile.State) -> Bool {
        for column in 0..<columns {
            if self[column: column, row: row].state == state {
                return true
            }
        }

        return false
    }

    /// Returns whether a tile with a specified state exists on a specified column
    /// of this grid.
    ///
    /// - precondition: `column >= 0 && column <= self.columns`
    public func columnContainsState(_ column: Int, state: PatternTile.State) -> Bool {
        for row in 0..<rows {
            if self[column: column, row: row].state == state {
                return true
            }
        }

        return false
    }

    /// Returns the run hints for a given column index on this grid.
    ///
    /// - precondition: `column >= 0 && column <= self.columns`
    public func hintForColumn(_ column: Int) -> RunsHint {
        precondition(column >= 0 && column <= columns, "\(column) >= 0 && \(column) <= columns")

        return hints[column]
    }

    /// Returns the run hints for a given row index on this grid.
    ///
    /// - precondition: `row >= 0 && row <= self.rows`
    public func hintForRow(_ row: Int) -> RunsHint {
        precondition(row >= 0 && row <= rows, "\(row) >= 0 && \(row) <= rows")

        return hints[columns + row]
    }

    /// Sets the run hints for a given row column on this grid.
    ///
    /// - precondition: `column >= 0 && column <= self.columns`
    public mutating func setHintForColumn(_ column: Int, runs: [Int]) {
        precondition(column >= 0 && column <= columns, "\(column) >= 0 && \(column) <= columns")

        hints[column] = .init(runs: runs)
    }

    /// Sets the run hints for a given row index on this grid.
    ///
    /// - precondition: `row >= 0 && row <= self.rows`
    public mutating func setHintForRow(_ row: Int, runs: [Int]) {
        precondition(row >= 0 && row <= rows, "\(row) >= 0 && \(row) <= rows")

        hints[columns + row] = .init(runs: runs)
    }
}

extension PatternGrid: Equatable {
    
}

extension PatternGrid {
    /// Describes the hint of a column or row of a Pattern grid as a sequence of
    /// numbers that describe the length of individual runs of dark tiles.
    public struct RunsHint: Equatable {
        /// A sequence of positive, non-zero numbers that describe the runs of
        /// dark squares within a column or row of a Pattern grid.
        public var runs: [Int]

        /// Returns the number of runs in this runs hint object.
        public var runCount: Int {
            return runs.count
        }

        /// Returns the number of empty spaces that are required to properly
        /// fill this list of hints.
        ///
        /// Is equal to each value in `self.runs` plus the number of values in
        /// the list, for the expected light tile separators in between.
        public var requiredEmptySpace: Int {
            max(0, runs.reduce(0, +) + (runs.count - 1))
        }

        /// Returns the number of dark tiles for the runs in this hint.
        public var requiredDarkTiles: Int {
            runs.reduce(0, +)
        }

        /// Returns a hint containing the same runs as this hint, but in reverse
        /// order.
        public var reversed: Self {
            Self(runs: runs.reversed())
        }
    }
}

extension PatternGrid.RunsHint: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Int...) {
        self.runs = elements
    }
}
