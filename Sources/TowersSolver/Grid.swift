public struct Grid {
    private(set) public var cells: [Cell]
    
    /// Values of visibility hints around the grid.
    /// Each side of the grid is covered w/ numbers telling how many towers can
    /// be see from that side looking across to the other side in a straight line.
    /// Visibility values of 0 indicate no visibility hints.
    public var visibilities: Visibilities
    
    /// Size of the square grid
    public let size: Int
    
    /// Returns true if all cells are currently solved.
    public var isSolved: Bool {
        for cell in cells {
            switch cell {
            case .solved:
                continue
            default:
                return false
            }
        }
        
        return true
    }
    
    /// Inits a grid of a specified side length.
    /// - precondition: size > 1
    public init(size: Int) {
        assert(size > 1, "size > 1")
        
        self.size = size
        
        cells = Array(repeating: .empty, count: size * size)
        
        // Init visibility hints for grid
        // Hints appear on the corners of the grid and have a number between
        // 1 - (grid size), and are used to solve the puzzle by saying how many
        // towers are visible from that corner of the grid looking past to the
        // opposite side.
        visibilities = Visibilities(size: size)
    }
    
    /// Restores all cell hints to either empty or to all possible values (if
    /// `toAllPossible` == true).
    ///
    /// Solved cells are left untouched.
    public mutating func resetHints(toAllPossible: Bool) {
        let set = Set(1...size)
        
        cells = cells.map { cell in
            switch cell {
            case .empty, .hint:
                return toAllPossible ? .hint(set) : .empty
            default:
                return cell
            }
        }
    }
    
    /// Removes a height from the hint of a cell at a given coordinate.
    ///
    /// Solved cells are left untouched.
    public mutating func markNot(x: Int, y: Int, height: Int) {
        let cell = cellAt(x: x, y: y)
        
        switch cell {
        case .hint(let hints):
            setCellAt(x: x, y: y, to: .hint(hints.subtracting([height])))
        default:
            break
        }
    }
    
    /// Marks a cell at a given x, y coordinate as solved with a given height
    public mutating func markSolved(x: Int, y: Int, height: Int) {
        setCellAt(x: x, y: y, to: .solved(height))
    }
    
    /// Returns an array of cells that represents the cells at a vertical column
    /// when looking at a given direction.
    ///
    /// If `orientation == .lookingDown` the array goes from `y = 0` to y = size - 1,
    /// otherwise it goes from `y = size - 1` to `y = 0`.
    public func column(x: Int, orientation: ColumnOrientation) -> [Cell] {
        let cells = (0..<size).map { y in
            cellAt(x: x, y: y)
        }
        
        return orientation == .lookingDown ? cells : cells.reversed()
    }
    
    /// Returns an array of cells that represents the cells at a horizontal line
    /// when looking at a given direction.
    ///
    /// If `orientation == .lookingFromLeft` the array goes from `x = 0` to x = size - 1,
    /// otherwise it goes from `x = size - 1` to `x = 0`.
    public func row(y: Int, orientation: RowOrientation) -> [Cell] {
        let cells = (0..<size).map { x in
            cellAt(x: x, y: y)
        }
        
        return orientation == .lookingFromLeft ? cells : cells.reversed()
    }
    
    /// Gets a cell at a given coordinate.
    public func cellAt(x: Int, y: Int) -> Cell {
        return cells[_index(forX: x, y: y)]
    }
    
    /// Changes the cell at a given coordinate to a specified cell value.
    mutating func setCellAt(x: Int, y: Int, to cell: Cell) {
        cells[_index(forX: x, y: y)] = cell
    }
    
    func _index(forX x: Int, y: Int) -> Int {
        return x + y * size
    }
    
    /// Stores the rows of visibility hints around the grid.
    public struct Visibilities {
        public var top: [Int]
        public var right: [Int]
        public var bottom: [Int]
        public var left: [Int]
        
        public init(size: Int) {
            // Init with all zeroes on all corners
            let runs = Array(repeating: 0, count: size)
            
            top = runs
            right = runs
            bottom = runs
            left = runs
        }
    }
    
    public enum ColumnOrientation {
        /// Looking from the top of the grid downwards
        case lookingDown
        
        /// Looking from the bottom of the grid upwards
        case lookingUp
    }
    
    public enum RowOrientation {
        /// Looking from the left side of the grid out to the right side
        case lookingFromLeft
        
        /// Looking from the right side of the grid out to the left side
        case lookingFromRight
    }
}

/// Represents a grid cell, w/ either a solved or unsolved state.
public enum Cell: Equatable {
    /// Cell is empty- no hint or solution is currently in place.
    case empty
    
    /// Cell is not solved, bunt contains a set of possible heights.
    case hint(Set<Int>)
    
    /// Cell is solved with a given height.
    case solved(Int)
    
    public var hints: Set<Int>? {
        switch self {
        case .hint(let hints):
            return hints
        default:
            return nil
        }
    }
    
    /// Returns `true` if this cell has a solution number set in (either correct
    /// or incorrect), i.e. `self` is an instance of `Cell.solved`
    public var hasSolution: Bool {
        if case .solved = self {
            return true
        }
        return false
    }
    
    public var solution: Int? {
        if case .solved(let s) = self {
            return s
        }
        
        return nil
    }
    
    /// Returns a cell for a specified set of heights, with a different case
    /// that best matches the heights list.
    ///
    /// - If `heights.count > 1`, returns `.hint(heights)`
    /// - If `heights.count == 1`, returns `.solved(heights[0])`
    /// - If `heights.count == 0`, returns `.empty`
    public static func fromHeights(_ heights: Set<Int>) -> Cell {
        if heights.count == 0 {
            return .empty
        }
        if heights.count == 1 {
            return .solved(heights.first!)
        }
        return .hint(heights)
    }
}

public extension Sequence where Iterator.Element == Cell {
    
    /// Returns `true` if all towers in this sequence have a solution assigned.
    public func areSolved() -> Bool {
        for cell in self {
            guard case .solved = cell else {
                return false
            }
        }
        
        return true
    }
    
    /// For each cell in this sequence, returns the height associated with its
    /// solution. Places 0 on indexes of cells that where not solved yet.
    public func solutionHeights() -> [Int] {
        return map { cell in cell.solution ?? 0 }
    }
}
