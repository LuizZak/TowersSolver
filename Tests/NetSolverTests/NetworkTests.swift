import Commons
import XCTest

@testable import NetSolver

class NetworkTests: XCTestCase {
    func testHasTile() {
        let sut = Network(tiles: [
            .init(column: 0, row: 0, ports: [])
        ])

        XCTAssertTrue(sut.hasTile(forColumn: 0, row: 0))
    }

    func testHasTile_noMatchingTile() {
        let sut = Network(tiles: [
            .init(column: 0, row: 0, ports: [])
        ])

        XCTAssertFalse(sut.hasTile(forColumn: 1, row: 0))
    }

    func testHasConnection() {
        let grid = TestGridBuilder(columns: 2, rows: 2)
            .setTile(1, 0, kind: .endPoint, orientation: .east)
            .build()
        let sut = Network(tiles: [
            .init(column: 0, row: 0, ports: [.right])
        ])

        XCTAssertTrue(sut.hasConnection(toColumn: 1, row: 0, port: .left, onGrid: grid))
    }

    func testHasConnection_nonMatchingPort_returnsFalse() {
        let grid = TestGridBuilder(columns: 2, rows: 2)
            .setTile(1, 0, kind: .endPoint, orientation: .east)
            .build()
        let sut = Network(tiles: [
            .init(column: 0, row: 0, ports: [.top])
        ])

        XCTAssertFalse(sut.hasConnection(toColumn: 1, row: 0, port: .left, onGrid: grid))
    }

    func testHasConnection_oppositeTiles_2x2_wrappingFalse_returnsFalse() {
        let grid = TestGridBuilder(columns: 2, rows: 2)
            .setTile(1, 0, kind: .endPoint, orientation: .east)
            .setWrapping(false)
            .build()
        let sut = Network(tiles: [
            .init(column: 0, row: 0, ports: [.left])
        ])

        XCTAssertFalse(sut.hasConnection(toColumn: 1, row: 0, port: .right, onGrid: grid))
    }

    func testHasConnection_oppositeTiles_3x3_wrappingFalse_returnsFalse() {
        let grid = TestGridBuilder(columns: 3, rows: 3)
            .setTile(1, 0, kind: .endPoint, orientation: .east)
            .setWrapping(false)
            .build()
        let sut = Network(tiles: [
            .init(column: 0, row: 0, ports: [.left])
        ])

        XCTAssertFalse(sut.hasConnection(toColumn: 2, row: 0, port: .right, onGrid: grid))
    }

    func testHasConnection_oppositeTiles_2x2_wrappingTrue_returnsTrue() {
        let grid = TestGridBuilder(columns: 2, rows: 2)
            .setTile(1, 0, kind: .endPoint, orientation: .east)
            .setWrapping(true)
            .build()
        let sut = Network(tiles: [
            .init(column: 0, row: 0, ports: [.left])
        ])

        XCTAssertTrue(sut.hasConnection(toColumn: 1, row: 0, port: .right, onGrid: grid))
    }

    func testHasConnection_oppositeTiles_3x3_wrappingTrue_returnsTrue() {
        let grid = TestGridBuilder(columns: 3, rows: 3)
            .setTile(1, 0, kind: .endPoint, orientation: .east)
            .setWrapping(true)
            .build()
        let sut = Network(tiles: [
            .init(column: 0, row: 0, ports: [.left])
        ])

        XCTAssertTrue(sut.hasConnection(toColumn: 2, row: 0, port: .right, onGrid: grid))
    }

    func testIsClosed_emptyNetwork() {
        let grid = Grid(columns: 1, rows: 1)
        let sut = Network(tiles: [])

        XCTAssertTrue(sut.isClosed(onGrid: grid))
    }

    func testIsClosed_closedNetwork() {
        let grid = TestGridBuilder(columns: 2, rows: 1)
            .setTile(0, 0, kind: .endPoint, orientation: .east)
            .setTile(1, 0, kind: .endPoint, orientation: .west)
            .build()
        let sut = Network.fromCoordinates(
            onGrid: grid,
            [
                (0, 0),
                (1, 0),
            ]
        )

        XCTAssertTrue(sut.isClosed(onGrid: grid))
    }

    func testIsClosed_nonClosedNetwork() {
        let grid = TestGridBuilder(columns: 2, rows: 1)
            .setTile(0, 0, kind: .endPoint, orientation: .east)
            .setTile(1, 0, kind: .L, orientation: .west)
            .build()
        let sut = Network.fromCoordinates(
            onGrid: grid,
            [
                (0, 0),
                (1, 0),
            ]
        )

        XCTAssertFalse(sut.isClosed(onGrid: grid))
    }

    func testIsClosed_incompleteNetwork() {
        let grid = TestGridBuilder(columns: 2, rows: 1)
            .setTile(0, 0, kind: .endPoint, orientation: .east)
            .setTile(1, 0, kind: .endPoint, orientation: .west)
            .build()
        let sut = Network.fromCoordinates(
            onGrid: grid,
            [
                (0, 0)
            ]
        )

        XCTAssertFalse(sut.isClosed(onGrid: grid))
    }

    func testIsClosed_stopsOnBarriers() {
        let grid = TestGridBuilder(columns: 2, rows: 1)
            .setTile(0, 0, kind: .endPoint, orientation: .west)
            .setTile(1, 0, kind: .endPoint, orientation: .east)
            .setWrapping(false)
            .build()
        let sut = Network.fromGrid(grid)

        XCTAssertFalse(sut.isClosed(onGrid: grid))
    }

    func testHasLoops_emptyNetwork() {
        let grid = Grid(columns: 1, rows: 1)
        let sut = Network(tiles: [])

        XCTAssertFalse(sut.hasLoops(onGrid: grid))
    }

    func testHasLoops_nonLoopedNetwork() {
        let grid = TestGridBuilder(columns: 2, rows: 2)
            .setTile(0, 0, kind: .L, orientation: .west)
            .setTile(1, 0, kind: .L, orientation: .east)
            .build()
        let sut = Network.fromCoordinates(
            onGrid: grid,
            [
                (0, 0),
                (1, 0),
            ]
        )

        XCTAssertFalse(sut.hasLoops(onGrid: grid))
    }

    func testHasLoops_nonLoopedNetwork_nonWrapping() {
        let grid = TestGridBuilder(columns: 2, rows: 2)
            .setTile(0, 0, kind: .I, orientation: .west)
            .setTile(1, 0, kind: .I, orientation: .east)
            .build()
        let sut = Network.fromCoordinates(
            onGrid: grid,
            [
                (0, 0),
                (1, 0),
            ]
        )

        XCTAssertFalse(sut.hasLoops(onGrid: grid))
    }

    func testHasLoops_loopedNetwork() {
        let grid = TestGridBuilder(columns: 3, rows: 3)
            .setTile(0, 0, kind: .L, orientation: .east)
            .setTile(1, 0, kind: .L, orientation: .south)
            .setTile(0, 1, kind: .L, orientation: .north)
            .setTile(1, 1, kind: .L, orientation: .west)
            .build()
        let sut = Network.fromCoordinates(
            onGrid: grid,
            [
                (0, 0),
                (1, 0),
                (0, 1),
                (1, 1),
            ]
        )

        XCTAssertTrue(sut.hasLoops(onGrid: grid))
    }

    func testHasLoops_loopedNetwork_wrapping() {
        let grid = TestGridBuilder(columns: 2, rows: 2)
            .setTile(0, 0, kind: .I, orientation: .west)
            .setTile(1, 0, kind: .I, orientation: .east)
            .setWrapping(true)
            .build()
        let sut = Network.fromCoordinates(
            onGrid: grid,
            [
                (0, 0),
                (1, 0),
            ]
        )

        XCTAssertTrue(sut.hasLoops(onGrid: grid))
    }

    func testIsCompleteNetwork() {
        let grid = TestGridBuilder(columns: 2, rows: 2)
            .build()
        let sut = Network.fromCoordinates(
            onGrid: grid,
            [
                (0, 0),
                (1, 0),
                (0, 1),
                (1, 1),
            ]
        )

        XCTAssertTrue(sut.isCompleteNetwork(ofGrid: grid))
    }

    func testIsCompleteNetwork_missingTiles() {
        let grid = TestGridBuilder(columns: 2, rows: 2)
            .build()
        let sut = Network.fromCoordinates(
            onGrid: grid,
            [
                (0, 0),
                (1, 0),
                (1, 1),
            ]
        )

        XCTAssertFalse(sut.isCompleteNetwork(ofGrid: grid))
    }

    func testIsCompleteNetwork_outOfBoundsTile() {
        let grid = TestGridBuilder(columns: 2, rows: 2)
            .build()
        var sut = Network.fromCoordinates(
            onGrid: grid,
            [
                (0, 0),
                (1, 0),
                (0, 1),
            ]
        )
        sut.tiles.insert(.init(column: 2, row: 1, ports: [.top]))

        XCTAssertFalse(sut.isCompleteNetwork(ofGrid: grid))
    }

    func testOpenPorts_singleTile() {
        let grid = TestGridBuilder(columns: 3, rows: 3)
            .setTile(1, 1, kind: .L, orientation: .north, locked: true)
            .build()
        let sut = Network.fromCoordinates(onGrid: grid, [(1, 1)])

        let result = sut.openPorts(onGrid: grid)

        XCTAssertEqual(
            result,
            [
                .init(column: 1, row: 1, ports: [.top, .right])
            ]
        )
    }

    func testOpenPorts_twoTile() {
        let grid = TestGridBuilder(columns: 3, rows: 3)
            .setTile(1, 1, kind: .L, orientation: .north)
            .setTile(2, 1, kind: .I, orientation: .west)
            .build()
        let sut = Network.fromCoordinates(onGrid: grid, [(1, 1), (2, 1)])

        let result = sut.openPorts(onGrid: grid)

        XCTAssertEqual(
            result,
            [
                .init(column: 1, row: 1, ports: [.top]),
                .init(column: 2, row: 1, ports: [.right]),
            ]
        )
    }

    func testOpenPorts_wrappingGrid() {
        let grid = TestGridBuilder(columns: 3, rows: 3)
            .setWrapping(true)
            .setTile(0, 1, kind: .L, orientation: .south)
            .setTile(1, 1, kind: .L, orientation: .north)
            .setTile(2, 1, kind: .I, orientation: .west)
            .build()
        let sut = Network.fromCoordinates(onGrid: grid, [(0, 1), (1, 1), (2, 1)])

        let result = sut.openPorts(onGrid: grid)

        XCTAssertEqual(
            result,
            [
                .init(column: 1, row: 1, ports: [.top]),
                .init(column: 0, row: 1, ports: [.bottom]),
            ]
        )
    }

    func testOpenPorts_nonWrappingGrid() {
        let grid = TestGridBuilder(columns: 3, rows: 3)
            .setWrapping(false)
            .setTile(0, 1, kind: .L, orientation: .south)
            .setTile(1, 1, kind: .L, orientation: .north)
            .setTile(2, 1, kind: .I, orientation: .west)
            .build()
        let sut = Network.fromCoordinates(onGrid: grid, [(0, 1), (1, 1), (2, 1)])

        let result = sut.openPorts(onGrid: grid)

        XCTAssertEqual(
            result,
            [
                .init(column: 0, row: 1, ports: [.left, .bottom]),
                .init(column: 1, row: 1, ports: [.top]),
                .init(column: 2, row: 1, ports: [.right]),
            ]
        )
    }

    func testOpenPorts_closedNetwork() {
        let grid = TestGridBuilder(columns: 3, rows: 1)
            .setWrapping(false)
            .setTile(0, 0, kind: .endPoint, orientation: .east)
            .setTile(1, 0, kind: .I, orientation: .west)
            .setTile(2, 0, kind: .endPoint, orientation: .west)
            .build()
        let sut = Network.fromCoordinates(onGrid: grid, [(0, 0), (1, 0), (2, 0)])

        let result = sut.openPorts(onGrid: grid)

        XCTAssertEqual(result, [])
    }

    func testSplitNetwork_disconnectedNetwork() {
        let grid = TestGridBuilder(columns: 2, rows: 2)
            .setTile(0, 0, kind: .endPoint, orientation: .north)
            .setTile(1, 0, kind: .endPoint, orientation: .south)
            .build()
        let sut = Network.fromCoordinates(
            onGrid: grid,
            [
                (0, 0),
                (1, 0),
            ]
        )

        let result = sut.splitNetwork(onGrid: grid)

        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(
            1,
            result.count(where: {
                $0.tiles == [
                    .init(column: 0, row: 0, ports: [.top])
                ]
            })
        )
        XCTAssertEqual(
            1,
            result.count(where: {
                $0.tiles == [
                    .init(column: 1, row: 0, ports: [.bottom])
                ]
            })
        )
    }

    func testSplitNetwork_connectedNetwork() {
        let grid = TestGridBuilder(columns: 2, rows: 2)
            .setTile(0, 0, kind: .endPoint, orientation: .east)
            .setTile(1, 0, kind: .endPoint, orientation: .west)
            .build()
        let sut = Network.fromCoordinates(
            onGrid: grid,
            [
                (0, 0),
                (1, 0),
            ]
        )

        let result = sut.splitNetwork(onGrid: grid)

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].tiles, sut.tiles)
    }

    func testSplitNetwork_disconnectedNetwork_nonWrapping() {
        let grid = TestGridBuilder(columns: 2, rows: 2)
            .setTile(0, 0, kind: .endPoint, orientation: .west)
            .setTile(1, 0, kind: .endPoint, orientation: .east)
            .setWrapping(false)
            .build()
        let sut = Network.fromCoordinates(
            onGrid: grid,
            [
                (0, 0),
                (1, 0),
            ]
        )

        let result = sut.splitNetwork(onGrid: grid)

        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(
            1,
            result.count(where: {
                $0.tiles == [
                    .init(column: 0, row: 0, ports: [.left])
                ]
            })
        )
        XCTAssertEqual(
            1,
            result.count(where: {
                $0.tiles == [
                    .init(column: 1, row: 0, ports: [.right])
                ]
            })
        )
    }

    func testSplitNetwork_connectedNetwork_wrapping() {
        let grid = TestGridBuilder(columns: 2, rows: 2)
            .setTile(0, 0, kind: .endPoint, orientation: .east)
            .setTile(1, 0, kind: .endPoint, orientation: .west)
            .setWrapping(true)
            .build()
        let sut = Network.fromCoordinates(
            onGrid: grid,
            [
                (0, 0),
                (1, 0),
            ]
        )

        let result = sut.splitNetwork(onGrid: grid)

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].tiles, sut.tiles)
    }

    func testAttemptJoin_nonConnectedNetworks() {
        let grid = TestGridBuilder(columns: 2, rows: 2)
            .setTile(0, 0, kind: .endPoint, orientation: .north)
            .setTile(1, 0, kind: .endPoint, orientation: .south)
            .setWrapping(false)
            .build()
        let net1 = Network.fromCoordinates(onGrid: grid, [(0, 0)])
        let net2 = Network.fromCoordinates(onGrid: grid, [(1, 0)])

        XCTAssertNil(net1.attemptJoin(other: net2, onGrid: grid))
    }

    func testAttemptJoin_connectedNetworks() throws {
        let grid = TestGridBuilder(columns: 2, rows: 2)
            .setTile(0, 0, kind: .endPoint, orientation: .east)
            .setTile(1, 0, kind: .I, orientation: .west)
            .setWrapping(false)
            .build()
        let net1 = Network.fromCoordinates(onGrid: grid, [(0, 0)])
        let net2 = Network.fromCoordinates(onGrid: grid, [(1, 0)])

        let result = try XCTUnwrap(net1.attemptJoin(other: net2, onGrid: grid))

        XCTAssertEqual(
            result.tiles,
            [
                .init(column: 0, row: 0, ports: [.right]),
                .init(column: 1, row: 0, ports: [.left, .right]),
            ]
        )
    }

    func testAttemptJoin_connectedNetworks_wrapping() throws {
        let grid = TestGridBuilder(columns: 2, rows: 2)
            .setTile(0, 0, kind: .endPoint, orientation: .west)
            .setTile(1, 0, kind: .I, orientation: .east)
            .setWrapping(true)
            .build()
        let net1 = Network.fromCoordinates(onGrid: grid, [(0, 0)])
        let net2 = Network.fromCoordinates(onGrid: grid, [(1, 0)])

        let result = try XCTUnwrap(net1.attemptJoin(other: net2, onGrid: grid))

        XCTAssertEqual(
            result.tiles,
            [
                .init(column: 0, row: 0, ports: [.left]),
                .init(column: 1, row: 0, ports: [.left, .right]),
            ]
        )
    }

    func testAttemptJoin_connectedNetworks_nonWrapping_returnsNil() throws {
        let grid = TestGridBuilder(columns: 2, rows: 2)
            .setTile(0, 0, kind: .endPoint, orientation: .west)
            .setTile(1, 0, kind: .I, orientation: .east)
            .setWrapping(false)
            .build()
        let net1 = Network.fromCoordinates(onGrid: grid, [(0, 0)])
        let net2 = Network.fromCoordinates(onGrid: grid, [(1, 0)])

        XCTAssertNil(net1.attemptJoin(other: net2, onGrid: grid))
    }

    func testAttemptJoin_overlappingTiles() throws {
        let grid = TestGridBuilder(columns: 2, rows: 2)
            .setTile(0, 0, kind: .endPoint, orientation: .north)
            .setTile(1, 0, kind: .endPoint, orientation: .south)
            .setTile(0, 1, kind: .endPoint, orientation: .west)
            .setWrapping(true)
            .build()
        let net1 = Network.fromCoordinates(onGrid: grid, [(1, 0), (0, 0)])
        let net2 = Network.fromCoordinates(onGrid: grid, [(1, 0), (0, 1)])

        let result = try XCTUnwrap(net1.attemptJoin(other: net2, onGrid: grid))

        XCTAssertEqual(
            result.tiles,
            [
                .init(column: 1, row: 0, ports: [.bottom]),
                .init(column: 0, row: 0, ports: [.top]),
                .init(column: 0, row: 1, ports: [.left]),
            ]
        )
    }

    func testAttemptJoin_doNotJoinIfPortsDoNotConnect() throws {
        let grid = TestGridBuilder(columns: 2, rows: 1)
            .setTile(0, 0, kind: .endPoint, orientation: .east)
            .setTile(1, 0, kind: .endPoint, orientation: .east)
            .setWrapping(true)
            .build()
        let net1 = Network.fromCoordinates(onGrid: grid, [(0, 0)])
        let net2 = Network.fromCoordinates(onGrid: grid, [(1, 0)])

        XCTAssertNil(net1.attemptJoin(other: net2, onGrid: grid))
    }

    func testFromCoordinates() {
        let grid = TestGridBuilder(columns: 2, rows: 2)
            .setTile(0, 0, kind: .endPoint, orientation: .east)
            .setTile(1, 1, kind: .T, orientation: .west)
            .build()

        let result =
            Network.fromCoordinates(
                onGrid: grid,
                [
                    (0, 0),
                    (1, 1),
                ]
            )

        XCTAssertEqual(
            result.tiles,
            [
                .init(column: 0, row: 0, ports: [.right]),
                .init(column: 1, row: 1, ports: [.left, .top, .bottom]),
            ]
        )
    }

    func testFromLockedTiles() {
        let grid = TestGridBuilder(columns: 3, rows: 3)
            .setTile(0, 0, kind: .L, orientation: .east, locked: true)
            .setTile(0, 1, kind: .I, orientation: .north, locked: true)
            .setTile(0, 2, kind: .I, orientation: .north)
            .build()

        let result = Network.fromLockedTiles(onGrid: grid)

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(
            result[0].tiles,
            [
                .init(column: 0, row: 0, ports: [.bottom, .right]),
                .init(column: 0, row: 1, ports: [.top, .bottom]),
            ]
        )
    }

    func testFromLockedTiles_splitNetwork() {
        let grid = TestGridBuilder(columns: 3, rows: 3)
            .setTile(0, 0, kind: .L, orientation: .east, locked: true)
            .setTile(0, 1, kind: .I, orientation: .north)
            .setTile(0, 2, kind: .I, orientation: .north, locked: true)
            .build()

        let result = Network.fromLockedTiles(onGrid: grid)

        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(
            1,
            result.count(where: {
                $0.tiles == [
                    .init(column: 0, row: 0, ports: [.bottom, .right])
                ]
            })
        )
        XCTAssertEqual(
            1,
            result.count(where: {
                $0.tiles == [
                    .init(column: 0, row: 2, ports: [.top, .bottom])
                ]
            })
        )
    }

    func testAllConnectedStartingFrom() {
        let grid = TestGridBuilder(columns: 3, rows: 3)
            .setTile(0, 0, kind: .L, orientation: .east)
            .setTile(0, 1, kind: .endPoint, orientation: .north)
            .build()

        let result = Network.allConnectedStartingFrom(column: 0, row: 0, onGrid: grid)

        XCTAssertEqual(
            result.tiles,
            [
                .init(column: 0, row: 0, ports: [.right, .bottom]),
                .init(column: 0, row: 1, ports: [.top]),
            ]
        )
    }

    func testAllConnectedStartingFrom_handlesLoops() {
        let grid = TestGridBuilder(columns: 2, rows: 2)
            .setTile(0, 0, kind: .L, orientation: .east)
            .setTile(1, 0, kind: .L, orientation: .south)
            .setTile(0, 1, kind: .L, orientation: .north)
            .setTile(1, 1, kind: .L, orientation: .west)
            .build()

        let result = Network.allConnectedStartingFrom(column: 0, row: 0, onGrid: grid)

        XCTAssertEqual(
            result.tiles,
            [
                .init(column: 0, row: 0, ports: [.bottom, .right]),
                .init(column: 1, row: 0, ports: [.left, .bottom]),
                .init(column: 0, row: 1, ports: [.top, .right]),
                .init(column: 1, row: 1, ports: [.top, .left]),
            ]
        )
    }

    func testAllConnectedStartingFrom_nonWrapping() {
        let grid = TestGridBuilder(columns: 2, rows: 1)
            .setTile(0, 0, kind: .endPoint, orientation: .west)
            .setTile(1, 0, kind: .endPoint, orientation: .east)
            .build()

        let result = Network.allConnectedStartingFrom(column: 0, row: 0, onGrid: grid)

        XCTAssertEqual(
            result.tiles,
            [
                .init(column: 0, row: 0, ports: [.left])
            ]
        )
    }

    func testAllConnectedStartingFrom_wrapping() {
        let grid = TestGridBuilder(columns: 2, rows: 1)
            .setTile(0, 0, kind: .endPoint, orientation: .west)
            .setTile(1, 0, kind: .endPoint, orientation: .east)
            .setWrapping(true)
            .build()

        let result = Network.allConnectedStartingFrom(column: 0, row: 0, onGrid: grid)

        XCTAssertEqual(
            result.tiles,
            [
                .init(column: 0, row: 0, ports: [.left]),
                .init(column: 1, row: 0, ports: [.right]),
            ]
        )
    }

    func testAllConnectedStartingFromOnNetwork() {
        let grid = TestGridBuilder(columns: 3, rows: 3)
            .setTile(0, 0, kind: .L, orientation: .east)
            .setTile(0, 1, kind: .endPoint, orientation: .north)
            .build()
        let network = Network.fromCoordinates(
            onGrid: grid,
            [
                (0, 0)
            ]
        )

        let result = Network.allConnectedStartingFrom(
            column: 0,
            row: 0,
            onNetwork: network,
            onGrid: grid
        )

        XCTAssertEqual(
            result.tiles,
            [
                .init(column: 0, row: 0, ports: [.right, .bottom])
            ]
        )
    }

    func testAllConnectedStartingFromOnNetwork_stopOnGaps() {
        let grid = TestGridBuilder(columns: 3, rows: 3)
            .setTile(0, 0, kind: .I, orientation: .east)
            .setTile(1, 0, kind: .I, orientation: .east)
            .setTile(2, 0, kind: .L, orientation: .east)
            .build()
        let network = Network.fromCoordinates(
            onGrid: grid,
            [
                (0, 0),
                (2, 0),
            ]
        )

        let result = Network.allConnectedStartingFrom(
            column: 0,
            row: 0,
            onNetwork: network,
            onGrid: grid
        )

        XCTAssertEqual(
            result.tiles,
            [
                .init(column: 0, row: 0, ports: [.left, .right])
            ]
        )
    }

    func testAllConnectedStartingFromOnNetwork_handlesLoops() {
        let grid = TestGridBuilder(columns: 2, rows: 2)
            .setTile(0, 0, kind: .L, orientation: .east)
            .setTile(1, 0, kind: .L, orientation: .south)
            .setTile(0, 1, kind: .L, orientation: .north)
            .setTile(1, 1, kind: .L, orientation: .west)
            .build()
        let network = Network.fromGrid(grid)

        let result = Network.allConnectedStartingFrom(
            column: 0,
            row: 0,
            onNetwork: network,
            onGrid: grid
        )

        XCTAssertEqual(
            result.tiles,
            [
                .init(column: 0, row: 0, ports: [.bottom, .right]),
                .init(column: 1, row: 0, ports: [.left, .bottom]),
                .init(column: 0, row: 1, ports: [.top, .right]),
                .init(column: 1, row: 1, ports: [.top, .left]),
            ]
        )
    }

    func testAllConnectedStartingFromOnNetwork_nonWrapping() {
        let grid = TestGridBuilder(columns: 2, rows: 1)
            .setTile(0, 0, kind: .endPoint, orientation: .west)
            .setTile(1, 0, kind: .endPoint, orientation: .east)
            .build()
        let network = Network.fromGrid(grid)

        let result = Network.allConnectedStartingFrom(
            column: 0,
            row: 0,
            onNetwork: network,
            onGrid: grid
        )

        XCTAssertEqual(
            result.tiles,
            [
                .init(column: 0, row: 0, ports: [.left])
            ]
        )
    }

    func testAllConnectedStartingFromOnNetwork_wrapping() {
        let grid = TestGridBuilder(columns: 2, rows: 1)
            .setTile(0, 0, kind: .endPoint, orientation: .west)
            .setTile(1, 0, kind: .endPoint, orientation: .east)
            .setWrapping(true)
            .build()
        let network = Network.fromGrid(grid)

        let result = Network.allConnectedStartingFrom(
            column: 0,
            row: 0,
            onNetwork: network,
            onGrid: grid
        )

        XCTAssertEqual(
            result.tiles,
            [
                .init(column: 0, row: 0, ports: [.left]),
                .init(column: 1, row: 0, ports: [.right]),
            ]
        )
    }

    func testHashOfCoordinatesMatchByColumnRowOnly() {
        let coord1 = Network.Coordinate(column: 0, row: 0, ports: [.left])
        let coord2 = Network.Coordinate(column: 0, row: 0, ports: [.right])
        let coord3 = Network.Coordinate(column: 1, row: 0, ports: [.left])
        let coord4 = Network.Coordinate(column: 1, row: 0, ports: [.right])

        XCTAssertEqual(coord1.hashValue, coord2.hashValue)
        XCTAssertEqual(coord3.hashValue, coord4.hashValue)
        XCTAssertNotEqual(coord1.hashValue, coord3.hashValue)
        XCTAssertNotEqual(coord2.hashValue, coord4.hashValue)
    }

    func testisEarlierInTopBottomLeftRightSweep() {
        let coord0x0 = Network.Coordinate(column: 0, row: 0, ports: [])
        let coord1x0 = Network.Coordinate(column: 1, row: 0, ports: [])
        let coord1x1 = Network.Coordinate(column: 1, row: 1, ports: [])
        let coord0x1 = Network.Coordinate(column: 0, row: 1, ports: [])

        XCTAssertTrue(Network.Coordinate.isEarlierInTopBottomLeftRightSweep(coord0x0, coord0x1))
        XCTAssertFalse(Network.Coordinate.isEarlierInTopBottomLeftRightSweep(coord0x1, coord0x0))
        XCTAssertTrue(Network.Coordinate.isEarlierInTopBottomLeftRightSweep(coord0x0, coord1x0))
        XCTAssertFalse(Network.Coordinate.isEarlierInTopBottomLeftRightSweep(coord1x0, coord0x0))

        XCTAssertTrue(Network.Coordinate.isEarlierInTopBottomLeftRightSweep(coord0x0, coord1x1))
        XCTAssertFalse(Network.Coordinate.isEarlierInTopBottomLeftRightSweep(coord1x1, coord0x0))
        XCTAssertTrue(Network.Coordinate.isEarlierInTopBottomLeftRightSweep(coord1x0, coord0x1))
        XCTAssertFalse(Network.Coordinate.isEarlierInTopBottomLeftRightSweep(coord0x1, coord1x0))
    }
}
