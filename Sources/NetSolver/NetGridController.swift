public class NetGridController {
    private(set) public var grid: Grid
    
    var columns: Int {
        return grid.columns
    }
    var rows: Int {
        return grid.rows
    }
    
    public init(grid: Grid) {
        self.grid = grid
    }
    
    /// Returns the orientations for all tiles on a given row.
    /// 
    /// - precondition: `row >= 0 && row < rows`
    public func tileOrientations(forRow row: Int) -> [Tile.Orientation] {
        return grid.tiles[row].map(\.orientation)
    }
    
    /// Returns the kinds for all tiles on a given row.
    ///
    /// - precondition: `row >= 0 && row < rows`
    public func tileKinds(forRow row: Int) -> [Tile.Kind] {
        return grid.tiles[row].map(\.kind)
    }
    
    /// Shuffle the rotation of the tiles, optionally specifying whether to
    /// rotate locked tiles as well.
    ///
    /// - Parameters:
    ///   - rotateLockedTiles: Whether to rotate locked tiles. Defaults to false.
    public func shuffle(rotateLockedTiles: Bool = false) {
        var rng = SystemRandomNumberGenerator()
        
        shuffle(using: &rng, rotateLockedTiles: rotateLockedTiles)
    }
    
    /// Shuffle the rotation of the tiles according to a given random number
    /// generator, optionally specifying whether to rotate locked tiles as well.
    ///
    /// - Parameters:
    ///   - rng: The random number generator that will be used to derive the random
    ///   orientation of the tiles.
    ///   - rotateLockedTiles: Whether to rotate locked tiles. Defaults to false.
    public func shuffle<RNG: RandomNumberGenerator>(using rng: inout RNG,
                        rotateLockedTiles: Bool = false) {
        
        let orientations = Tile.Orientation.allCases
        
        for y in 0..<columns {
            for x in 0..<rows {
                if grid.tiles[y][x].isLocked && !rotateLockedTiles {
                    continue
                }
                
                grid.tiles[y][x].orientation =
                    orientations.randomElement(using: &rng) ?? .north
            }
        }
    }
}
