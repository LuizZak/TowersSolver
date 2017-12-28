/// A Loopy match grid
public struct Grid {
    /// Vertical edges, stored as columns, starting from left-most column.
    /// Each array represents a column going from left to right, with each array
    /// within containing the edges from top-to-bottom of that column.
    /// Always has height + 1 count of arrays.
    ///
    /// Querying a vertical edge for a cell:
    ///
    ///     verticalEdges[x][y]
    internal var verticalEdges: [[EdgeState]] = []
    
    /// Horizontal edges, stored as rows, starting from top-most row.
    /// Each array represent a row going from top to bottom, with each array within
    /// containing the edges from left-to-right of that row.
    /// Always has width + 1 count of arrays.
    ///
    /// Querying a horizontal edge for a cell:
    ///
    ///     horizontalEdges[y][x]
    internal var horizontalEdges: [[EdgeState]] = []
    
    /// Matrix of y by x hints for the edges of number of edges of each cell that
    /// are touching the line.
    /// A value of nil represents no hint at that cell (any number of corners can
    /// be marked).
    internal var edgesHints: [[Int?]] = []
    
    /// Total width of the grid, in number of cells
    public let width: Int
    /// Total height of the grid, in number of cells
    public let height: Int
    
    public init(width: Int, height: Int) {
        self.width = width
        self.height = height
        
        initializeEdges()
        initializeEdgeHints()
    }
    
    mutating func initializeEdges() {
        horizontalEdges = []
        verticalEdges = []
        
        let row = Array(repeating: EdgeState.normal, count: width + 1)
        let column = Array(repeating: EdgeState.normal, count: height + 1)
        
        for _ in 0...height {
            horizontalEdges.append(row)
        }
        
        for _ in 0...width {
            verticalEdges.append(column)
        }
    }
    
    mutating func initializeEdgeHints() {
        edgesHints = []
        
        let row: [Int?] = Array(repeating: nil, count: width)
        
        for _ in 0..<height {
            edgesHints.append(row)
        }
    }
    
    /// Returns information about edges of a given cell coordinate pair.
    /// - precondition: x is >= 0 and < width, and y is >= 0 and < height.
    public func edgesOfCell(x: Int, y: Int) -> (top: EdgeState, right: EdgeState, bottom: EdgeState, left: EdgeState) {
        let colLeft = edgesFor(column: x)
        let colRight = edgesFor(column: x + 1)
        
        let rowTop = edgesFor(row: y)
        let rowBottom = edgesFor(row: y + 1)
        
        let cellLeft = colLeft[y]
        let cellRight = colRight[y]
        
        let cellTop = rowTop[x]
        let cellBottom = rowBottom[x]
        
        return (cellTop, cellRight, cellBottom, cellLeft)
    }
    
    /// Returns a summay for the cell at a given x,y coordinate of the grid.
    /// - precondition: x is >= 0 and < width, and y is >= 0 and < height.
    public func cell(atX x: Int, y: Int) -> Cell {
        let edges = edgesOfCell(x: x, y: y)
        let hint = hintForCell(atX: x, y: y)
        
        return Cell(topEdge: edges.top, rightEdge: edges.right,
                    bottomEdge: edges.bottom, leftEdge: edges.left, hint: hint)
    }
    
    /// Gets the hint for the number of edges of a cell that are part of the
    /// solution line.
    /// If nil, any number of edges can be marked on the cell.
    /// - precondition: x is >= 0 and < width, and y is >= 0 and < height.
    public func hintForCell(atX x: Int, y: Int) -> Int? {
        let hint = edgesHints[y][x]
        return hint
    }
    
    public mutating func setEdgeValue(_ edge: EdgeState, onEdgeCardinal edgeCardinal: EdgeCardinal, forCellAtX x: Int, y: Int) {
        switch edgeCardinal {
        case .top:
            horizontalEdges[y][x] = edge
        case .left:
            verticalEdges[x][y] = edge
        case .bottom:
            horizontalEdges[y + 1][x] = edge
        case .right:
            verticalEdges[x + 1][y] = edge
        }
    }
    
    /// Sets the hint for a cell at a given x,y coordinate pair.
    /// - precondition: x is >= 0 and < width, and y is >= 0 and < height.
    public mutating func setHint(_ hint: Int?, forCellAtX x: Int, y: Int) {
        edgesHints[y][x] = hint
    }
    
    /// Loads the hints information from a given array of nullable integers.
    /// Each value is inserted sequentially, from top to bottom, left to right
    /// on the grid cells (i.e. the 0th index is the top-left corner, and the
    /// last index is the bottom-right corner).
    ///
    /// This method overrides all existing hints with the ones provided on the
    /// given array.
    ///
    /// - precondition: hints.count == self.width * self.height
    public mutating func setHints(_ hints: [Int?]) {
        assert(hints.count == width * height)
        
        for (i, hint) in hints.enumerated() {
            let x = i % width
            let y = i / width
            
            setHint(hint, forCellAtX: x, y: y)
        }
    }
    
    /// Returns an array of edges this vertex participates in.
    /// The array contains the edges in top, right, bottom, left order, with any
    /// edge that ends outside
    public func edgesForVertex(_ vertex: Vertex) -> [Edge] {
        var edges: [Edge] = []
        
        // Top
        if vertex.y > 0 {
            edges.append(Edge(x: vertex.x, y: vertex.y - 1, cardinal: .left))
        }
        // Right
        if vertex.x < width {
            edges.append(Edge(x: vertex.x + 1, y: vertex.y, cardinal: .top))
        }
        // Left
        if vertex.x > 0 {
            edges.append(Edge(x: vertex.x - 1, y: vertex.y, cardinal: .top))
        }
        // Down
        if vertex.y < height {
            edges.append(Edge(x: vertex.x, y: vertex.y + 1, cardinal: .top))
        }
        
        return edges.map { edge in
            edge.normalized(onGridWidth: width, height: height)
        }
    }
    
    /*
    /// Returns the two vertices that make up the given edge.
    public func verticesForEdge(_ edge: Edge) -> [Vertex] {
        
    }
    */
    
    /// Gets all vertices that compose a cell at a given x,y coordinate
    public func verticesFor(cellAtX x: Int, y: Int) -> [Vertex] {
        return [
            Vertex(x: x, y: y),
            Vertex(x: x + 1, y: y),
            Vertex(x: x + 1, y: y + 1),
            Vertex(x: x, y: y + 1)
        ]
    }
    
    /// Returns all cells sharing a given vertex.
    public func cellsSharing(vertex: Vertex) -> [Cell] {
        var cells: [Cell] = []
        
        // Top
        if vertex.y < height - 1 {
            cells.append(cell(atX: vertex.x, y: vertex.y + 1))
        }
        // Right
        if vertex.x < width - 1 {
            cells.append(cell(atX: vertex.x + 1, y: vertex.y))
        }
        // Bottom
        if vertex.y > 0 {
            cells.append(cell(atX: vertex.x, y: vertex.y - 1))
        }
        // Left
        if vertex.x > 0 {
            cells.append(cell(atX: vertex.x - 1, y: vertex.y))
        }
        
        return cells
    }
    
    private func edgesFor(column: Int) -> [EdgeState] {
        return verticalEdges[column]
    }
    
    private func edgesFor(row: Int) -> [EdgeState] {
        return horizontalEdges[row]
    }
}

/// Represents a cell of the grid, containing the four adjacent edges and an optional
/// number representing the required number of edges to be contoured.
///
///                .topEdge
///               ┼────────┼
///               │        │
///     .leftEdge │ .hint  │ .rightEdge
///               │        │
///               ┼────────┼
///              .bottomEdge
///
public struct Cell: Equatable {
    public var topEdge: EdgeState
    public var rightEdge: EdgeState
    public var bottomEdge: EdgeState
    public var leftEdge: EdgeState
    
    /// Returns an array containing all four edges of this cell, in this sequence:
    /// top, right, bottom, left.
    public var allEdges: [EdgeState] {
        return [topEdge, rightEdge, bottomEdge, leftEdge]
    }
    
    public var hint: Int?
    
    /// Gets the value for a given edge cardinal direction on this cell.
    public func edge(_ edge: EdgeCardinal) -> EdgeState {
        switch edge {
        case .top:
            return topEdge
        case .right:
            return rightEdge
        case .bottom:
            return bottomEdge
        case .left:
            return leftEdge
        }
    }
    
    public static func ==(lhs: Cell, rhs: Cell) -> Bool {
        return lhs.allEdges == rhs.allEdges && lhs.hint == rhs.hint
    }
}

/// Represents an Edge coordinate, with a x,y coordinate of the cell the edge
/// belongs to, and its edge direction.
/// As an implementation detail, shared edges across cells are interchangeable
/// and compare as equal, i.e. the right edge of cell 0,0 is exactly the same as
/// the left edge of the cell 1,0
public struct Edge: Hashable {
    public var x: Int
    public var y: Int
    public var cardinal: EdgeCardinal
    
    /// Returns the hash value for the normalized (on an infinite grid field)
    /// value of `self`.
    /// Edge instances that represent the same edge logically always have the
    /// same hash value.
    public var hashValue: Int {
        let norm = normalized(onGridWidth: Int.max, height: Int.max)
        
        var hash = 13
        hash = (hash * 7) + norm.x
        hash = (hash * 7) + norm.y
        hash = (hash * 7) + norm.cardinal.hashValue
        
        return hash
    }
    
    /// Normalizes this edge so shared edges have the same representation structurally.
    /// The normalization tries to represent edges as the top or left edge of
    /// cells, and bottom or right when the cell x,y is at the right or bottom
    /// sides of the grid.
    ///
    /// The normalization rules are as follows:
    ///
    /// - 1 If cardinal == .left or .right:
    ///   - 1.1. If x <= width and cardinal == .left:
    ///     - return as-is
    ///   - 1.2. If x == width and cardinal == .right:
    ///     - return as-is
    ///   - 1.3. If x < width and cardinal == .right:
    ///     - return Edge with x + 1, and EdgeCardinal.left
    /// - 2. If cardinal == .top or .bottom
    ///   - 2.1. If y <= width and cardinal == .top:
    ///     - return as-is
    ///   - 2.2. If y == height and cardinal == .bottom:
    ///     - return .bottom
    ///   - 2.3. If y < height and cardinal == .bottom:
    ///     - return Edge with y + 1, and EdgeCardinal.top
    ///
    /// Pass in `Int.max` to always normalize the edge representation against the
    /// top or left of the cell it's connected to.
    public func normalized(onGridWidth width: Int, height: Int) -> Edge {
        if isNormalized(onGridWidth: width, height: height) {
            return self
        }
        
        switch cardinal {
        case .left where x <= width, .right where x == width,
             .top where y <= height, .bottom where y == height:
            return self
            
        case .right:
            return Edge(x: x + 1, y: y, cardinal: .left)
        case .bottom:
            return Edge(x: x, y: y + 1, cardinal: .top)
            
        default:
            fatalError("Unexpected/unhandled case x == \(x) and cardinal == \(cardinal)?")
        }
    }
    
    /// Returns whether this cell is normalized on a given grid width/height.
    /// See `normalized(onGridWidth:height:)` for more info on normalization.
    ///
    /// Passing in `Int.max` always returns `true` for `.left` and `.top` edges,
    /// and false for `.right` and `.bottom`.
    public func isNormalized(onGridWidth width: Int, height: Int) -> Bool {
        switch cardinal {
        case .left where x <= width, .right where x == width,
             .top where y <= height, .bottom where y == height:
            return true
            
        case .right, .bottom:
            return false
            
        default:
            fatalError("Unexpected/unhandled case x == \(x) and cardinal == \(cardinal)?")
        }
    }
    
    /// Compares the normalized (on an infinite grid field) values of `lhs` and
    /// `rhs`, returning `true` if they exactly match in representation.
    public static func ==(lhs: Edge, rhs: Edge) -> Bool {
        let normL = lhs.normalized(onGridWidth: Int.max, height: Int.max)
        let normR = rhs.normalized(onGridWidth: Int.max, height: Int.max)
        
        return normL.x == normR.x && normL.y == normR.y && normL.cardinal == normR.cardinal
    }
}

/// Represents the state of single edge of the grid
public enum EdgeState {
    /// An edge that has not been modified (default state)
    case normal
    
    /// An edge marked as a path of the line
    case marked
    
    /// An edge marked as disabled (hint that the edge is not part of the solution)
    case disabled
}

/// Used to query an edge at an x,y coordinate cell pair
public enum EdgeCardinal: Int {
    case top
    case right
    case bottom
    case left
    
    /// Returns whether this edge is horizontal (either the top or bottom edge of
    /// a cell).
    public var isHorizontal: Bool {
        return self == .top || self == .bottom
    }
}
