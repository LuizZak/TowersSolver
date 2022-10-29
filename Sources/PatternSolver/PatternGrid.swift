import Geometry

/// A grid for a pattern game.
public struct PatternGrid: GridType {
    public typealias TileType = PatternTile

    /// Matrix of tiles, stored as [columns][rows]
    private(set) public var tiles: [[TileType]] = []

    /// List of hints for this Pattern grid, stored as
    /// [column0, column1, ..., columnN, row0, row1, ..., rowN]
    public var hints: [RunHints] = []

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

    /// Returns the run hints for a given column index on this grid.
    ///
    /// - precondition: `column >= 0 && column <= self.columns`
    func hintsForColumn(_ column: Int) -> RunHints {
        precondition(column >= 0 && column <= columns, "\(column) >= 0 && \(column) <= columns")

        return hints[column]
    }

    /// Returns the run hints for a given row index on this grid.
    ///
    /// - precondition: `row >= 0 && row <= self.rows`
    func hintsForRow(_ row: Int) -> RunHints {
        precondition(row >= 0 && row <= rows, "\(row) >= 0 && \(row) <= rows")

        return hints[columns + row]
    }
}

extension PatternGrid {
    /// Describes the hint of a column or row of a Pattern grid.
    public struct RunHints: Equatable {
        /// A sequence of positive, non-zero numbers that describe the runs of
        /// dark squares within a column or row of a Pattern grid.
        public var runs: [Int]

        /// Returns the number of empty spaces that are required to properly
        /// fill this list of hints.
        ///
        /// Is equal to each value in `self.runs` plus the number of values in
        /// the list, for the expected light tile separators in between.
        public var requiredEmptySpace: Int {
            max(0, runs.reduce(0, +) + (runs.count - 1))
        }
    }
}