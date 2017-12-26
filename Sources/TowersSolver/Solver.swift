import Foundation

public class Solver {
    public var grid: Grid
    
    /// Maximum number of times the solver can try making a guess on a cell and
    /// try to continue solving the grid before giving up completely.
    public var maxGuessAttempts: Int = 3
    
    /// If true, enables stopping at key points during solving to show solving
    /// steps
    public var interactive: Bool = false
    
    /// When interactive mode is set, tries to be extra descriptive with solving
    /// steps.
    public var descriptive: Bool = false
    
    /// Total guesses that this solver (and any branching sub-solver created during
    /// guessing) made before finishing.
    private(set) public var totalGuesses = 0
    
    /// Used to avoid resetting when recursing through sub-solvers while guessing
    /// cells after getting stuck.
    private var resetGrid: Bool = true
    
    /// When using interactive printing, used to set which coordinate we are looking
    /// at when looping through columns/rows
    private var _coord: String = ""
    
    /// When using descriptive interactive printing, collects descriptive steps
    /// until we hit a grid print operation, which we then print after the grid
    /// to improve legibility of the temrinal output.
    private var _description = ""
    
    /// Only really used when `self.interactive == true`
    private(set) public var gridPrinter: GridPrinter = GridPrinter(bufferWidth: 80, bufferHeight: 35)
    
    public init(grid: Grid, maxGuessAttempts: Int = 3) {
        self.grid = grid
        self.maxGuessAttempts = maxGuessAttempts
    }
    
    /// Removes a height from the possibility set of a cell.
    /// Does nothing, if cell is not a `.hint`.
    private func markCellNot(x: Int, y: Int, height: Int) {
        grid.markNot(x: x, y: y, height: height)
    }
    
    private func markSolvedCell(x: Int, y: Int, height: Int) {
        guard grid.cellAt(x: x, y: y).solution != height else {
            return
        }
        
        grid.markSolved(x: x, y: y, height: height)
        
        // Now expand on all four directions and remove the number from any existing
        // hint
        for x in 0..<grid.size {
            markCellNot(x: x, y: y, height: height)
        }
        for y in 0..<grid.size {
            markCellNot(x: x, y: y, height: height)
        }
    }
    
    /// When in interactive mode, sets the value of the _coord variable
    private func _setCoord(_ coord: @autoclosure () -> String) {
        if interactive {
            _coord = coord()
        }
    }
    
    /// When in descriptive interactive mode, accumulates the string for printing
    /// later.
    private func _print(_ desc: @autoclosure () -> String) {
        if interactive && descriptive {
            if !_description.isEmpty {
                _description += "\n"
            }
            
            _description += desc()
        }
    }
    
    /// When in descriptive interactive mode, prints contents of `_description`
    /// string to stdout.
    private func _flushDescriptiveText() {
        if interactive && descriptive {
            print(_description)
            _description = ""
        }
    }
    
    /// Runs a while loop that runs the given closure for as long as running it
    /// modifies the grid in any way.
    private func runWhileChangingGrid(_ closure: () throws -> ()) rethrows {
        var beforeGrid: [Cell]
        repeat {
            beforeGrid = grid.cells
            try closure()
        } while beforeGrid != grid.cells
    }
    
    /// Runs a given closure for each solution direction (up, down, left, right)
    /// passing in the visibility at the cell and the array of towers (pre-ordered
    /// from nearest to farthest from the edge.)
    ///
    /// Also provides a closure that when fed an index, returns a proper (x, y)
    /// coordinates pair for the cell at the given index on the column/row that
    /// it belongs.
    private func runStepAcrossLines(_ step: (_ visible: Int, _ towers: [Cell], _ convertCoord: (_ index: Int) -> (x: Int, y: Int)) throws -> Void) rethrows {
        for (x, v) in grid.visibilities.top.enumerated() {
            _setCoord("column \(x + 1) (top)")
            
            try step(v, grid.column(x: x, orientation: .lookingDown), { (x: x, y: $0) })
        }
        
        for (x, v) in grid.visibilities.bottom.enumerated() {
            _setCoord("column \(x + 1) (bot)")
            
            try step(v, grid.column(x: x, orientation: .lookingUp), { (x: x, y: grid.size - 1 - $0) })
        }
        
        for (y, v) in grid.visibilities.left.enumerated() {
            _setCoord("row \(y + 1) (left)")
            
            try step(v, grid.row(y: y, orientation: .lookingFromLeft), { (x: $0, y: y) })
        }
        
        for (y, v) in grid.visibilities.right.enumerated() {
            _setCoord("row \(y + 1) (right)")
            
            try step(v, grid.row(y: y, orientation: .lookingFromRight), { (x: grid.size - 1 - $0, y: y) })
        }
    }
    
    /// Fills in each cell of the grid w/ solve hints based on the visibility set
    /// on the outer edges of the grid.
    public func fillHints() {
        if interactive {
            _print("Resetting grid hints and excluding obvious nots...")
        }
        
        // Reset hints
        grid.resetHints(toAllPossible: true)
        
        // Go over each edge marking down impossible spots (based on distance to
        // towers of certain heights and their occlusion of remaining towers in
        // sequence. See `excludeHints()` method for more info.)
        // This helps prune search space when working with visibility trees.
        
        runStepAcrossLines { (v, towers, coord) in
            excludeHints(visible: v, towers: towers) { (i, not) in
                let (x, y) = coord(i)
                
                markCellNot(x: x, y: y, height: not)
            }
        }
        
        // Now step through and remove hints that conflict with previously solved
        // cells in vertical/horizontal lines.
        for y in 0..<grid.size {
            for x in 0..<grid.size {
                guard let solution = grid.cellAt(x: x, y: y).solution else {
                    continue
                }
                
                for x in 0..<grid.size {
                    markCellNot(x: x, y: y, height: solution)
                }
                for y in 0..<grid.size {
                    markCellNot(x: x, y: y, height: solution)
                }
            }
        }
        
        if interactive {
            // Re-print grid
            gridPrinter.printGrid(grid: grid)
            _flushDescriptiveText()
            
            print("Press Enter to advance...")
            _=readLine()
        }
    }
    
    private func excludeHints(visible: Int, towers: [Cell], setNot: (Int, Int) -> Void) {
        // Case 1: For 1 < v < towers, the largest possible tower height will always
        // be at least 'v' distance from the corner.
        // E.g.:
        //
        // 3: - - - - -
        //
        // Can only have 5's on:
        //
        // 3: - - 5 5 5  If a 5 lands on the first or second spot, the row cannot
        //               be solved!
        if visible > 1 && visible < towers.count {
            var r = towers.count
            for max in (1..<visible).reversed() {
                var _set = false
                for x in 0..<max {
                    if towers[x].solution != r {
                        setNot(x, r)
                        _set = true
                    }
                }
                
                if interactive && descriptive && _set {
                    _print("[\(visible)] At \(_coord): Removing impossible \(r) tower heights for visibility \(visible)")
                }
                
                r -= 1
            }
        }
        
        // Case 2: For visibilities of 2, the second tower cannot be the second
        // tallest one, as it'd result in either one or three towers being visible
        // (along with any other possible visible towers count, except exactly two!)
        if visible == 2 {
            setNot(1, towers.count - 1)
        }
    }
    
    public func runTrivialStep() {
        runStepAcrossLines { (visible, towers, coord) in
            fillTrivial(visible: visible, towers: towers) { (i, n) in
                let (x, y) = coord(i)
                
                markSolvedCell(x: x, y: y, height: n)
            }
        }
    }
    
    public func runComplexStep() {
        runStepAcrossLines { (v, towers, coord) in
            complexStep(visible: v, towers: towers, markNot: { (i, not) in
                let (x, y) = coord(i)
                
                markCellNot(x: x, y: y, height: not)
            }, solve: { (i, n) in
                let (x, y) = coord(i)
                
                markSolvedCell(x: x, y: y, height: n)
            })
        }
    }
    
    private func fillTrivial(visible: Int, towers: [Cell], set: (Int, Int) -> Void) {
        // Ignore already-solved rows
        if towers.areSolved() {
            return
        }
        
        // Case 1: For visible = 1, the very first tower is always the maximum
        // height
        if !towers[0].hasSolution && visible == 1 {
            set(0, towers.count)
            
            if interactive && descriptive {
                _print("[\(visible)] At \(_coord): Blocking whole view with \(towers.count) tower")
            }
            
            return
        }
        
        if visible == 2 {
            // Case 2: For visible = 2, if the highest tower is the last in the
            // sequence, then the first tower must be the second to largest one.
            if towers.last?.solution == towers.count {
                set(0, towers.count - 1)
                
                if interactive && descriptive {
                    if towers[0].solution != towers.count - 1 {
                        _print("[\(visible)] At \(_coord): Blocking view of towers up to \(towers.count) with \(towers.count - 1) tower")
                    }
                }
                
                return
            }
            
            // Case 3: For visible = 2, if the very first tower is the smallest
            // one, the second tower must be the tallest one.
            // This is generalized in Case 5, but we put this simpler case here
            // because it's more common.
            if towers.first?.solution == 1 {
                set(1, towers.count)
                
                if interactive && descriptive {
                    if towers[1].solution != towers.count {
                        _print("[\(visible)] At \(_coord): Smallest tower must be followed by largest tower")
                    }
                }
                
                return
            }
        }
        
        // Case 4: if the tallest tower is at the N position of an N-visibility
        // solution, and all positions occluded by the tall tower contain the
        // sequence of towers from Tallest to N-th tallest (in any order), then
        // the positions before the tallest tower must be a sequence of shortest
        // to N-1 tall tower, because that's the only way to solve those positions.
        if visible > 1 && towers[visible - 1].solution == towers.count {
            // Check occluded tower solutions
            let sol = towers[(visible-1)...].solutionHeights()
            if Set(sol) == Set(visible...towers.count) {
                for h in 1..<visible {
                    set(h - 1, h)
                }
                
                if interactive && descriptive {
                    _print("[\(visible)] At \(_coord): Adding sequential tower heights (due to being only solution possible)")
                }
                
                return
            }
        }
        
        // Case 5: If the sequence of towers from the first position go from
        // 1 to visible - 1 (in order), then the next tower must be the tallest
        // possible tower occluding all others, otherwise the solution will be
        // visible + 1 (and thus invalid).
        if visible > 1 && visible < towers.count && !towers[visible - 1].hasSolution {
            if towers[0..<visible-1].solutionHeights() == Array(1..<visible) {
                set(visible - 1, towers.count)
                
                if interactive && descriptive {
                    _print("[\(visible)] At \(_coord): Adding tallest tower after sequential tower heights (due to being only solution possible)")
                }
                
                return
            }
        }
        
        // Case 5: For visible = tower count, all towers are visible, in ascending
        // order
        if visible == towers.count {
            for i in 0..<towers.count {
                set(i, i + 1)
            }
            
            if interactive && descriptive {
                _print("[\(visible)] At \(_coord): Only solution is sequential tower heights from 1 - \(towers.count)")
            }
            
            return
        }
        
        // Case 6: A cell is marked with only one possible hint value. That hint
        // value must be the solution for that cell
        for (i, cell) in towers.enumerated() {
            switch cell {
            case .hint(let hints) where hints.count == 1:
                set(i, hints.first!)
                
                if interactive && descriptive {
                    _print("[\(visible)] At \(_coord): Sole hint \(hints.first!) is the only solution for cell at \(i + 1)!")
                }
            default:
                break
            }
        }
        
        // Now run through all hinted cells, and for each unique hint/cell
        // pair, fill in the cell with that value.
        // This solves cells that feature a hint that does not appear in any other
        // cell.
        var available = Set(1...towers.count)
        
        // Remove solved cells
        for cell in towers {
            switch cell {
            case .solved(let value):
                available.remove(value)
            default:
                continue
            }
        }
        
        func cellsForHint(hint: Int) -> [(Int, Cell)] {
            return towers.enumerated().filter { (_, cell) in
                switch cell {
                case .hint(let hints):
                    return hints.contains(hint)
                default:
                    return false
                }
            }
        }
        
        for h in available {
            let c = cellsForHint(hint: h)
            if c.count == 1 {
                set(c[0].0, h)
                
                if interactive && descriptive {
                    _print("[\(visible)] At \(_coord): Cell \(c[0].0 + 1) is the only cell on its row featuring height hint \(h): That's its solution.")
                }
            }
        }
    }
    
    /// A more complex solving round that uses visibility trees to make deeper
    /// analysis of possible (and impossible) tower heights.
    private func complexStep(visible: Int, towers: [Cell],
                             markNot: (_ index: Int, _ height: Int) -> Void,
                             solve: (_ index: Int, _ height: Int) -> Void)
    {
        // Ignore already-solved rows
        if towers.areSolved() {
            return
        }
        
        // Construct all possible solution permutations for the array of towers
        let root = TowerVisibilityNode.visibilities(from: towers)
        
        let possibleSets: [Set<Int>]
        
        // 0 means no restriction for visible tower count, all permutations are
        // possible.
        if visible == 0 {
            possibleSets = (0..<towers.count).map {
                root.possibleSolutionHeights(at: $0)
            }
        } else {
            // Create an array containing sets where each index represents the
            // tower that is 'that-index' distance away from the edge, and each
            // set within is a set of all distinct cell hints found at that index
            // from all input solution permutations.
            possibleSets =
                root.permutations(ofVisibleTowers: visible)
                    .reduce(into: (0..<towers.count).map(Set<Int>.init)) { (res, heights) in
                        for (i, h) in heights.enumerated() {
                            res[i].insert(h)
                        }
                    }
        }
        
        for (i, possibleSet) in possibleSets.enumerated() {
            guard !towers[i].hasSolution else {
                continue
            }
            
            // Only one possible solution for this cell!
            if possibleSet.count == 1 {
                solve(i, possibleSet.first!)
                
                if interactive && descriptive {
                    _print("[\(visible)] At \(_coord): Cell \(i + 1) only has \(possibleSet.first!) in common across possible options")
                }
            }
            
            // Remove from the current hints set of the cell all heights that don't
            // show up on the possible heights permutations for that cell, meaning
            // no combination of solution features these heights, and they can be
            // safely discarded.
            if let hints = towers[i].hints {
                let diff = possibleSet.symmetricDifference(hints)
                if diff.count > 0 {
                    for h in diff {
                        markNot(i, h)
                    }
                    
                    if interactive && descriptive {
                        let list = Array(diff).sorted().map { h in h.description }.joined(separator: ", ")
                        _print("[\(visible)] At \(_coord): Cell \(i + 1) cannot feature height(s) \(list) since that would result in empty cells elsewhere!")
                    }
                }
            }
        }
    }
}

// MARK: - Solver loops
public extension Solver {
    /// Runs as many solving steps as possible before either solving the whole
    /// grid, or stopping after not being able to make any more attempts.
    @discardableResult
    public func solve() -> Bool {
        if resetGrid {
            // Fill in hints- these are required and are the basis for solving the
            // cells of the grid.
            fillHints()
        }
        
        // Run until we can't anymore
        while true {
            let didWork = step()
            
            if interactive && didWork {
                // Re-print grid
                gridPrinter.printGrid(grid: grid)
                _flushDescriptiveText()
                
                print("^ After full trivials + complex step cycle. Press Enter to advance...")
                _=readLine()
            }
            
            if !didWork {
                break
            }
        }
        
        if grid.isSolved {
            return true
        }
        
        if interactive {
            // Re-print grid
            gridPrinter.printGrid(grid: grid)
            _flushDescriptiveText()
            
            print("^ After last trivial + complex step cycle.")
            _print("Ran out of possible tries!")
        }
        
        // Ran out of attempts and got stuck. Now make leaps of faith: Pick the
        // cells starting from the ones with the smallest number of hints to
        // attempt one value or the other to solve. Each backtracking attempt
        // counts as 1 attempt on the max guesses var.
        var subGrid = grid
        
        // Find possible branches to take from here. Simply look at the grid and
        // list every non-solved cell's hints. Those are all possible branching
        // paths to take from here.
        let possible =
            subGrid.cells
                .enumerated()
                .filter {
                    ($0.element.hints?.count ?? 0) > 0
                }.sorted { (pair1, pair2) in
                    let h1 = pair1.element.hints
                    let h2 = pair2.element.hints
                    
                    if h1 != nil && h2 == nil {
                        return true
                    }
                    if h1 == nil && h2 != nil {
                        return false
                    }
                    
                    if let h1 = h1, let h2 = h2 {
                        return h1.count < h2.count
                    }
                    
                    return false
                }.flatMap { tup -> [(offset: Int, hint: Int)] in
                    let (offset, element) = tup
                    return element.hints!.map { (offset, $0) }
                }
        
        var guesses = 0
        while guesses < maxGuessAttempts && guesses < possible.count {
            totalGuesses += 1
            
            subGrid = grid
            
            let least = possible[guesses]
            
            let subSolver = Solver(grid: subGrid, maxGuessAttempts: maxGuessAttempts - guesses)
            subSolver.resetGrid = false
            subSolver.gridPrinter = gridPrinter
            subSolver.interactive = interactive
            subSolver.descriptive = descriptive
            
            defer {
                totalGuesses += subSolver.totalGuesses
            }
            
            // Flip a single unit of the grid that features the smallest branches
            subSolver.markSolvedCell(x: least.offset % subGrid.size,
                                     y: least.offset / subGrid.size,
                                     height: least.hint)
            
            // Check if this doesn't lead into an inconsistent solve attempt
            // (this counts as a backtracking attempt torwards the max guess counts)
            if !subSolver.isConsistent() || subSolver.hasEmptySolutionCells() {
                guesses += 1
                
                if interactive {
                    // Re-print grid
                    _print("Skipping guess that created invalid state...")
                }
                
                continue
            }
            
            if interactive {
                // Re-print grid
                gridPrinter.printGrid(grid: subSolver.grid)
                _flushDescriptiveText()
                
                print("^ Attempting to guess a cell and follow through with solving...")
                _=readLine()
            }
            
            if subSolver.solve() {
                // We solved this guy!
                if subSolver.isConsistent() {
                    grid = subSolver.grid
                    return true
                }
                
                if interactive {
                    _print("A Guess attempt resulted in invalid solution. Backtracking (or quitting)...")
                }
            }
            
            gridPrinter.storingDiff {
                gridPrinter.printGrid(grid: grid)
            }
            
            guesses += 1
        }
        
        return grid.isSolved
    }
    
    /// Performs a single step of the solver.
    /// Returns if no more steps can be performed (either because the game is won
    /// or because the solver failed to solve the puzzle successfully).
    public func step() -> Bool {
        
        // Check if any cell features empty cells (this means we ran out of
        // possibilities for one or more cells)
        if hasEmptySolutionCells() {
            if interactive {
                _print("Avoiding solving a grid with no more guesses available")
            }
            return false
        }
        
        let before = grid.cells
        
        // Do nested trivial and complex runs
        runWhileChangingGrid {
            // Fill out trivials first. These don't need to construct visibility
            // trees, and so are much faster to perform, as well as trim out many
            // easy cases.
            runWhileChangingGrid {
                runTrivialStep()
                _print("End of trivial cycle.")
            }
            
            // Run a complex step that uses visibility trees as an aid for a more
            // complete solving attempt with solution combinations checkings
            runComplexStep()
            _print("End of complex + trivial cycle.")
        }
        
        let after = grid.cells
        
        return before != after
    }
}

// MARK: - Consistency check methods
public extension Solver {
    
    /// Returns if all visibility hints on the corners of the grid are consistent
    /// with the visibility of the rows and columns, and each row/column has the
    /// precise count of tower heights (or doesn't have repeats, in case they are
    /// not fully solved yet.)
    public func isConsistent() -> Bool {
        struct Inconsistent: Error { }
        
        let allHeights = Set(1...grid.size)
        
        do {
            // Detect earlier inconsistency by checking current solution rows
            try runStepAcrossLines { (v, towers, coord) in
                let heights = towers.solutionHeights()
        
                // Quick check for duplicates (except 0, which represents a
                // non-solved cell)
                let dict =
                    Dictionary(grouping: heights.filter { $0 != 0 }, by: { $0 })
                        .mapValues({ $0.count })
                if dict.values.contains(where: { $0 > 1 }) {
                    throw Inconsistent()
                }
        
                if !towers.areSolved() {
                    // We can already check for invalid solutions when the current
                    // set results in higher number of possible visible towers
                    // than the visibility hint, even if solutions are still
                    // missing (any other solution would at least keep the visible
                    // tower count, and at most increase it by one)
                    if v > 0 && countIncreases(in: heights.filter { $0 != 0 }) > v {
                        throw Inconsistent()
                    }
                    
                    return
                }
        
                // Mismatch tower heights count - they should all be present!
                if Set(heights) != allHeights {
                    throw Inconsistent()
                }
        
                if v != 0 && v != countIncreases(in: heights) {
                    throw Inconsistent()
                }
            }
            
            return true
        } catch {
            return false
        }
    }
    
    /// Returns if any of the cells on the grid is empty.
    ///
    /// Empty grids (after proper pre-hint filling steps) usually mean no solutions
    /// are possible at this point because a cell cannot be filled with any valid
    /// value without duplicating a column/row.
    public func hasEmptySolutionCells() -> Bool {
        return grid.cells.contains(where: { (cell) -> Bool in
            switch cell {
            case .empty:
                return true
            case .hint(let h) where h.count == 0:
                return true
            default:
                return false
            }
        })
    }
}
