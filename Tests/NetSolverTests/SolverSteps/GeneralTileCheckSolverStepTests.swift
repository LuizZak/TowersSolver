import XCTest

@testable import NetSolver

class GeneralTileCheckSolverStepTests: BaseSolverStepTestClass {
    func testApply_possibleOrientationsMatchRequiredPorts_doNothing() {
        let grid = TestGridBuilder(columns: 1, rows: 1)
            .setTileKind(0, 0, kind: .I)
            .build()
        mockDelegate.mock_prepare(forGrid: grid)
        mockDelegate.mock_requiredPortsForTile = { (_, _) in
            return [.top]
        }
        mockDelegate.mock_unavailableIncomingPortsForTile = { (_, _) in
            return []
        }
        mockDelegate.mock_possibleOrientationsForTile = { (_, _) in
            return [.north]
        }
        let sut = GeneralTileCheckSolverStep(column: 0, row: 0)

        let result = sut.apply(on: grid, delegate: mockDelegate)

        XCTAssertEqual(result, [])
    }

    func testApply_requiredOverlapsGuaranteedUnavailableOutgoing_markAsInvalid() {
        let grid = TestGridBuilder(columns: 1, rows: 1)
            .build()
        mockDelegate.mock_prepare(forGrid: grid)
        mockDelegate.mock_requiredPortsForTile = { (_, _) in
            return [.top, .left]
        }
        mockDelegate.mock_guaranteedOutgoingUnavailablePortsForTile = { (_, _) in
            return [.top, .right]
        }
        let sut = GeneralTileCheckSolverStep(column: 0, row: 0)

        let result = sut.apply(on: grid, delegate: mockDelegate)

        XCTAssertEqual(result, [.markAsInvalid])
    }

    func testApply_unavailableIncomingMatchesAllButOneDirection() {
        let grid = TestGridBuilder(columns: 1, rows: 1)
            .setTileKind(0, 0, kind: .L)
            .build()
        mockDelegate.mock_prepare(forGrid: grid)
        mockDelegate.mock_unavailableIncomingPortsForTile = { (_, _) in
            return [.left, .bottom]
        }
        let sut = GeneralTileCheckSolverStep(column: 0, row: 0)

        let result = sut.apply(on: grid, delegate: mockDelegate)

        XCTAssertEqual(
            result,
            [
                .markImpossibleOrientations(column: 0, row: 0, [.west, .east, .south])
            ]
        )
    }

    func testApply_unavailableIncomingMatchesAllDirections_markAsInvalid() {
        let grid = TestGridBuilder(columns: 1, rows: 1)
            .setTile(0, 0, kind: .I, orientation: .north)
            .build()
        mockDelegate.mock_prepare(forGrid: grid)
        mockDelegate.mock_unavailableIncomingPortsForTile = { (_, _) in
            return [.left, .bottom]
        }
        let sut = GeneralTileCheckSolverStep(column: 0, row: 0)

        let result = sut.apply(on: grid, delegate: mockDelegate)

        XCTAssertEqual(
            result,
            [
                .markAsInvalid
            ]
        )
    }

    func testApply_requiredDiscardsUnavailableDirections() {
        let grid = TestGridBuilder(columns: 1, rows: 1)
            .setTile(0, 0, kind: .L, orientation: .north)
            .build()
        mockDelegate.mock_prepare(forGrid: grid)
        mockDelegate.mock_requiredPortsForTile = { (_, _) in
            return [.right]
        }
        mockDelegate.mock_unavailableIncomingPortsForTile = { (_, _) in
            return []
        }
        let sut = GeneralTileCheckSolverStep(column: 0, row: 0)

        let result = sut.apply(on: grid, delegate: mockDelegate)

        XCTAssertEqual(
            result,
            [
                .markImpossibleOrientations(column: 0, row: 0, [.south, .west]),
                .markUnavailableIngoing(column: 0, row: 0, [.right]),
            ]
        )
    }

    func testApply_markImpossibleOrientations() {
        let grid = TestGridBuilder(columns: 3, rows: 3)
            .setTileKind(1, 1, kind: .L)
            .build()
        mockDelegate.mock_prepare(forGrid: grid)
        mockDelegate.mock_guaranteedOutgoingUnavailablePortsForTile = { (_, _) in
            return [.right]
        }
        let sut = GeneralTileCheckSolverStep(column: 1, row: 1)

        let result = sut.apply(on: grid, delegate: mockDelegate)

        XCTAssertEqual(
            result,
            [
                .markImpossibleOrientations(column: 1, row: 1, [.north, .east]),
                .markUnavailableIngoing(column: 2, row: 1, [.left]),
            ]
        )
    }

    func testApply_unavailableOrientationsAreEquivalent_disableOnlyOne() {
        let grid = TestGridBuilder(columns: 3, rows: 3)
            .setTileKind(1, 1, kind: .I)
            .build()
        mockDelegate.mock_prepare(forGrid: grid)
        mockDelegate.mock_requiredPortsForTile = { (_, _) in
            return [.left]
        }
        let sut = GeneralTileCheckSolverStep(column: 1, row: 1)

        let result = sut.apply(on: grid, delegate: mockDelegate)

        XCTAssertTrue(result.contains(.markImpossibleOrientations(column: 1, row: 1, [.north])))
    }

    func testApply_propagatesUnavailableIncomingPortsAcrossNeighboringTiles() {
        let grid = TestGridBuilder(columns: 3, rows: 3)
            .setTileKind(0, 1, kind: .L)
            .setTileKind(1, 1, kind: .I)
            .build()
        mockDelegate.mock_prepare(forGrid: grid)
        mockDelegate.mock_requiredPortsForTile = { (_, _) in
            return [.left]
        }
        mockDelegate.mock_unavailableIncomingPortsForTile = { (_, _) in
            return []
        }
        let sut = GeneralTileCheckSolverStep(column: 0, row: 1)

        let result = sut.apply(on: grid, delegate: mockDelegate)

        XCTAssertEqual(
            result,
            [
                .markImpossibleOrientations(column: 0, row: 1, [.north, .east]),
                .markUnavailableIngoing(column: 1, row: 1, [.left]),
            ]
        )
    }

    func testApply_doesNotPropagateUnavailableIncomingPortsWhenAlreadyReportedByDelegate() {
        let grid = TestGridBuilder(columns: 3, rows: 3)
            .setTileKind(0, 1, kind: .L)
            .setTileKind(1, 1, kind: .I)
            .build()
        mockDelegate.mock_prepare(forGrid: grid)
        mockDelegate.mock_requiredPortsForTile = { (_, _) in
            return [.left]
        }
        mockDelegate.mock_unavailableIncomingPortsForTile = { (_, _) in
            return [.right]
        }
        let sut = GeneralTileCheckSolverStep(column: 0, row: 1)

        let result = sut.apply(on: grid, delegate: mockDelegate)

        XCTAssertEqual(
            result,
            [
                .markImpossibleOrientations(column: 0, row: 1, [.north, .east])
            ]
        )
    }

    func testApply_lockedTilesSurroundingTile_lockOrientation() {
        // Grid:
        //
        // │ ├ ┘
        // │ ┘ ┬
        // └ ─ ┘
        //
        // Only center tile is unlocked
        let grid = TestGridBuilder(columns: 3, rows: 3)
            .setTile(0, 0, kind: .I, orientation: .north, locked: true)
            .setTile(1, 0, kind: .T, orientation: .east, locked: true)
            .setTile(2, 0, kind: .L, orientation: .east, locked: true)
            .setTile(0, 1, kind: .I, orientation: .north, locked: true)
            .setTile(1, 1, kind: .L, orientation: .east)
            .setTile(2, 1, kind: .T, orientation: .south, locked: true)
            .setTile(0, 2, kind: .L, orientation: .north, locked: true)
            .setTile(1, 2, kind: .I, orientation: .east, locked: true)
            .setTile(2, 2, kind: .L, orientation: .east, locked: true)
            .build()
        mockDelegate.mock_prepare(forGrid: grid)
        let sut = GeneralTileCheckSolverStep(column: 1, row: 1)

        let result = sut.apply(on: grid, delegate: mockDelegate)

        XCTAssertEqual(
            result,
            [
                .markImpossibleOrientations(column: 1, row: 1, [.south, .west, .east])
            ]
        )
    }
}
