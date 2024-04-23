import Geometry

/// A grid for a light up game.
public struct LightUpGrid: GridType, Equatable {
    public typealias TileType = LightUpTile

    /// Matrix of tiles, stored as [columns][rows]
    private(set) public var tiles: [[TileType]] = []

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

    public subscript(column column: Int, row row: Int) -> TileType {
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

    /// Initializes a new Light Up grid instance
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

    internal init(tiles: [[LightUpTile]]) {
        self.rows = tiles[0].count
        self.columns = tiles.count

        self.tiles = tiles
    }

    private mutating func initGrid() {
        tiles.removeAll()

        for _ in 0..<columns {
            let column = Array(repeating:
                TileType(state: .space(.empty)),
                count: rows
            )

            tiles.append(column)
        }
    }

    /// Returns `true` if this grid is currently in a solved state.
    /// 
    /// The grid is solved when all of the following conditions are true:
    /// 
    /// 1. All non-wall tiles are lit;
    /// 2. No light is orthogonally connected to another light without a wall in
    ///    between;
    /// 3. All walls with numeric hints have the same number of lights surrounding
    ///    that wall.
    func isSolved() -> Bool {
        for coords in tileCoordinates {
            switch self[coords].state {
            case .space(.empty), .space(.marker):
                if !isLit(coords) {
                    return false
                }

            case .space(.light):
                let spaces = allSpacesVisible(from: coords)

                if spaces?.containsLight() == true {
                    return false
                }

            case .wall(let hint?):
                let lights = lightsSurrounding(coords)?.count ?? 0

                if lights != hint {
                    return false
                }

            default:
                break
            }
        }

        return true
    }

    /// Returns `true` if this grid is currently in a valid state.
    ///
    /// The grid is in a valid state when all of the following conditions are
    /// true:
    ///
    /// 1. No light is orthogonally connected to another light without a wall in
    ///    between;
    /// 2. All walls with numeric hints have no more lights surrounding that wall
    ///    than its numeric hint;
    /// 3. All walls with numeric hints should have at least as many empty
    ///    non-lit spaces surrounding them as the lights still required for that
    ///    hint;
    /// 4. All tiles with markers are either lit or have an unobstructed orthogonal
    ///    path to a tile where a light can be place to illuminate them.
    func isValid() -> Bool {
        for coords in tileCoordinates {
            switch self[coords].state {
            case .space(.marker) where !isLit(coords):
                guard let spaces = allSpacesVisible(from: coords) else {
                    // Marker has no reachable neighbors that can light it
                    return false
                }

                if spaces.coordinates.count(where: canPlaceLight(on:)) == 0 {
                    return false
                }

            case .space(.light):
                let spaces = allSpacesVisible(from: coords)

                if spaces?.containsLight() == true {
                    return false
                }

            case .wall(let hint?):
                let lights = lightsSurrounding(coords)?.count ?? 0

                if lights > hint {
                    return false
                }
                if lights == hint {
                    continue
                }

                let remainingRequired = hint - lights
                let available = availableSpacesSurrounding(coords)?.count ?? 0

                if available < remainingRequired {
                    return false
                } 

            default:
                break
            }
        }

        return true
    }

    /// Returns a view of light tiles that are currently orthogonally adjacent
    /// to a tile at a given coordinate.
    func lightsSurrounding(_ coord: Coordinates) -> GridTileView<Self>? {
        let coordinates = tilesOrthogonallyAdjacentTo(coord).coordinates.filter({ self[$0].isLight })
        guard !coordinates.isEmpty else {
            return nil
        }

        return viewForCoordinates(coordinateList:
            coordinates
        )
    }

    /// Returns a view of tiles orthogonally adjacent to `coord` where a light
    /// can be placed.
    func availableSpacesSurrounding(_ coord: Coordinates) -> GridTileView<Self>? {
        let coordinates = tilesOrthogonallyAdjacentTo(coord).coordinates.filter(canPlaceLight(on:))
        guard !coordinates.isEmpty else {
            return nil
        }

        return viewForCoordinates(coordinateList:
            coordinates
        )
    }

    /// Returns `true` if a tile at a given coordinate can be made a light, i.e.
    /// it is an unlit empty space.
    func canPlaceLight(on coord: Coordinates) -> Bool {
        switch self[coord].state {
        case .space(.empty):
            return !isLit(coord)
        default:
            return false
        }
    }

    /// Returns `true` if a tile at a given coordinate is lit by a light in any
    /// of the four cardinal directions.
    ///
    /// Also returns `true` if the tile is a light itself.
    func isLit(_ coord: Coordinates) -> Bool {
        if self[coord].isLight {
            return true
        }

        func search(_ tiles: GridTileView<Self>) -> Bool {
            tiles.contains(where: { $0.isLight })
        }

        for direction in Direction.allCases {
            guard let tiles = spaces(from: coord, direction: direction) else {
                continue
            }

            if search(tiles) {
                return true
            }
        }

        return false
    }

    /// Returns a list of all spaces orthogonally connected to a specified tile,
    /// except for `coord` itself.
    ///
    /// Returns `nil` if `coord` points to a wall, or has walls or grid edges
    /// immediately in all directions.
    func allSpacesVisible(from coord: Coordinates) -> GridTileView<Self>? {
        var coords: [Coordinates] = []

        for direction in Direction.allCases {
            guard let spaces = spaces(from: coord, direction: direction) else {
                continue
            }

            coords.append(contentsOf: spaces.coordinates)
        }

        guard !coords.isEmpty else {
            return nil
        }

        return viewForCoordinates(coordinateList: coords)
    }

    /// Returns a list of sequential tiles from `coord` that are spaces until
    /// either the first wall or the edge of the grid is reached.
    ///
    /// Returns `nil` if `coord` points to a wall, or has a wall or grid edge
    /// immediately in `direction`.
    func spaces(from coord: Coordinates, direction: Direction) -> GridTileView<Self>? {
        if self[coord].isWall {
            return nil
        }

        var coords: [Coordinates] = []
        
        var current = coord
        while let next = direction.shifting(current, on: self) {
            if self[next].isWall {
                break
            }

            coords.append(next)
            current = next
        }

        guard !coords.isEmpty else {
            return nil
        }

        return viewForCoordinates(coordinateList: coords)
    }

    /// One of the four cardinal directions.
    enum Direction: CaseIterable {
        case left
        case top
        case right
        case bottom

        func shifting(_ coord: Coordinates, on grid: LightUpGrid) -> Coordinates? {
            switch self {
            case .left:
                return grid.shift(coords: coord, byColumn: -1, row: 0)
            case .top:
                return grid.shift(coords: coord, byColumn: 0, row: -1)
            case .right:
                return grid.shift(coords: coord, byColumn: 1, row: 0)
            case .bottom:
                return grid.shift(coords: coord, byColumn: 0, row: 1)
            }
        }
    }
}

#if DEBUG

import Console

extension LightUpGrid {
    func debugPrint() {
        let target = StringBufferConsolePrintTarget(supportsTerminalColors: true)
        let printer = LightUpGridPrinter(bufferForGrid: self)
        printer.target = target
        printer.printGrid(grid: self)

        print(target.buffer)
    }
}

#endif

extension GridTileView where Grid == LightUpGrid {
    /// Returns the number of free spaces in this set of tiles that a light can
    /// be placed onto.
    ///
    /// Counts only `LightUpTile.State.space(.empty)`.
    func emptySpaces() -> Int {
        count(where: { $0.state == .space(.empty) })
    }

    /// Returns `true` if any tile in this set of tiles is a light.
    func containsLight() -> Bool {
        contains(where: { $0.state == .space(.light) })
    }
}
