/// Holds all possible permutations of tower sequences in a recursive tree structure.
struct TowerVisibilityNode {
    var children: [TowerVisibilityNode]
    var height: Int
    
    init(height: Int) {
        children = []
        self.height = height
    }
    
    mutating func addChild(node: TowerVisibilityNode) {
        children.append(node)
    }
    
    /// Returns all possible permutations of heights found on this node and all
    /// children nodes
    func permutations(ignoreRoot: Bool = true) -> [[Int]] {
        var all: [[Int]] = []
        _traverse(ignoreRoot: ignoreRoot, [], &all)
        return all
    }
    
    private func _traverse(ignoreRoot: Bool = true, _ heights: [Int], _ dumpTo: inout [[Int]]) {
        let newH: [Int]
        if ignoreRoot && height == -1 {
            newH = heights
        } else {
            newH = heights + [height]
        }
        
        if children.count == 0 {
            dumpTo.append(newH)
        } else {
            for child in children.sorted(by: { $0.height < $1.height }) {
                child._traverse(newH, &dumpTo)
            }
        }
    }
    
    /// Returns permutations of heights found on this node and all children nodes
    /// that ammount to a given final visible tower count.
    /// All other permutations are not included, and if no combinations of nodes
    /// results in the requested visibility, an empty array is returned.
    func permutations(ofVisibleTowers visible: Int, ignoreRoot: Bool = true) -> [[Int]] {
        var all: [[Int]] = []
        _traverse(heightBudget: visible, highest: 0, ignoreRoot: ignoreRoot, [], &all)
        return all
    }
    
    private func _traverse(heightBudget: Int, highest: Int, ignoreRoot: Bool = true, _ heights: [Int], _ dumpTo: inout [[Int]]) {
        var heightBudget = heightBudget
        var highest = highest
        
        // Bump to visible towers count and check if we exceeded maximum height
        if highest < height {
            highest = height
            heightBudget -= 1
            
            if heightBudget < 0 {
                return
            }
        }
        
        let newH: [Int]
        if ignoreRoot && height == -1 {
            newH = heights
        } else {
            newH = heights + [height]
        }
        
        if children.count == 0 && heightBudget == 0 {
            dumpTo.append(newH)
        } else {
            for child in children.sorted(by: { $0.height < $1.height }) {
                child._traverse(heightBudget: heightBudget, highest: highest, newH, &dumpTo)
            }
        }
    }
    
    /// Gets the maximum number of towers that can be seen from the permutation
    /// set off of this tree node, including the node itself (if not -1)
    func maxVisible() -> Int {
        return countIncreases(in: sortedAscending())
    }
    
    /// Gets the minimum number of towers that can be seen from the permutation
    /// set off of this tree node, including the node itself (if not -1)
    func minVisible() -> Int {
        return countIncreases(in: sortedDescending())
    }
    
    /// From all valid possibilities represented by this tree, returns all the
    /// possible values at a given index (depth on the tree)
    func possibleSolutionHeights(at index: Int) -> Set<Int> {
        var set = Set<Int>()
        
        if height == -1 || index > 0 {
            for child in children {
                set.formUnion(child.possibleSolutionHeights(at: height == -1 ? index : index - 1))
            }
        } else if index == 0 {
            set.insert(height)
        }
        
        return set
    }
    
    /// Strips all children that are shallower than a given depth.
    mutating func stripShallower(than depth: Int) {
        for i in (0..<children.count).reversed() {
            children[i].stripShallower(than: depth - 1)
            if children[i].depth() < depth {
                children.remove(at: i)
            }
        }
    }
    
    /// Gets the depth of this node's tree. Always > 1.
    func depth() -> Int {
        var depth = 0
        for child in children {
            depth = max(depth, child.depth())
        }
        return depth + 1
    }
    
    /// Gets the largest tower present on this tree branch
    func largestTower() -> Int {
        var cur = height
        for child in children {
            cur = max(cur, child.largestTower())
        }
        
        return cur
    }
    
    /// Gets the smallest tower present on this tree branch
    func smallestTower() -> Int {
        var cur = height
        for child in children {
            cur = min(cur, child.largestTower())
        }
        
        return cur
    }
    
    /// Returns a list of integers that represent the permutation that has the
    /// highest number of visible towers in sequence.
    func sortedAscending() -> [Int] {
        let perms =
            permutations()
                .sorted(by: { (config1, config2) -> Bool in
                    countIncreases(in: config1) < countIncreases(in: config2)
                })
        
        return perms.last ?? []
    }
    
    /// Returns a list of integers that represent the permutation that has the
    /// lowest number of visible towers in sequence.
    func sortedDescending() -> [Int] {
        let perms =
            permutations()
                .sorted(by: { (config1, config2) -> Bool in
                    return countIncreases(in: config1) >  countIncreases(in: config2)
                })
        
        return perms.last ?? []
    }
}

extension TowerVisibilityNode {
    
    /// Returns a root visibility node of value -1, with children that represent
    /// all possible permutations of combinations of available heights for the
    /// given cell list.
    ///
    /// Non-solveable permutations (when e.g. a combination leaves a cell that
    /// cannot be filled with any valid value) are stripped away before returning.
    public static func visibilities(from cells: [Cell]) -> TowerVisibilityNode {
        var root = TowerVisibilityNode(height: -1)
        _permutate(onto: &root, cells: cells)
        
        root.stripShallower(than: cells.count)
        
        return root
    }
    
    private static func _permutate(onto node: inout TowerVisibilityNode, cells: [Cell]) {
        guard let next = cells.first else {
            return
        }
        
        for height in _heightsForCell(next) {
            var newNode = TowerVisibilityNode(height: height)
            
            if cells.count > 1 {
                let rem = _strippingHeight(height, from: cells[1...])
                _permutate(onto: &newNode, cells: rem)
            }
            
            node.addChild(node: newNode)
        }
    }
    
    private static func _strippingHeight<S: Sequence>(_ height: Int, from cells: S) -> [Cell] where S.Iterator.Element == Cell {
        let heightTest: (Int) -> Bool = { h in h != height }
        
        return cells.map { cell in
            switch cell {
            case .empty:
                return cell
            case .hint(let heights):
                let newHeights = heights.filter(heightTest)
                return Cell.fromHeights(newHeights)
            case .solved(let height):
                if heightTest(height) {
                    return cell
                }
                return .empty
            }
        }
    }
    
    private static func _heightsForCell(_ cell: Cell) -> Set<Int> {
        switch cell {
        case .solved(let h):
            return [h]
        case .hint(let h):
            return h
        case .empty:
            return []
        }
    }
}

/// Counts the number of non-sequential maximum number increases found on a given
/// array of integers.
///
/// From the first index, traverses down the list and counts the number of times
/// a larger integer than the largest so far is found.
///
/// Always returns `>= 1`, as the first index is counted as an increase as well
/// (increase from -infinity)
func countIncreases<T: Comparable>(in list: [T]) -> Int {
    guard var smallest = list.first else {
        return 1
    }
    
    var bumps = 1
    for item in list {
        if item > smallest {
            smallest = item
            bumps += 1
        }
    }
    
    return bumps
}
