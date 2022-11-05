import Interval
import XCTest

class IntervalOperationsTests: XCTestCase {
    // MARK: - Range extensions

    func testUnion_range() {
        XCTAssertEqual(
            (-1..<(0 + 1)).union((0..<(1 + 1))),
            (-1..<(1 + 1))
        )

        XCTAssertEqual(
            (-2..<(-1 + 1)).union((1..<(2 + 1))),
            (-2..<(2 + 1))
        )
    }

    func testCompactIntervals_range() {
        let intervals: [Range<Int>] = [
            (-7..<(-2 + 1)),
            (-5..<(-1 + 1)),
            (1..<(9 + 1)),
            (2..<(3 + 1)),
            (4..<(5 + 1)),
            (3..<(4 + 1)),
            (10..<(13 + 1)),
            (13..<(14 + 1)),
        ]

        XCTAssertEqual(
            intervals.compactIntervals(),
            [
                (-7..<(-1 + 1)),
                (1..<(9 + 1)),
                (10..<(14 + 1)),
            ]
        )
    }

    func testCompactIntervalsSingleInterval_range() {
        XCTAssertEqual(
            [(1..<(2 + 1))].compactIntervals(),
            [(1..<(2 + 1))]
        )
    }

    func testCompactIntervalsTwoNonOverlappingIntervals_range() {
        XCTAssertEqual(
            [(4..<(5 + 1)), (1..<(2 + 1))].compactIntervals(),
            [(1..<(2 + 1)), (4..<(5 + 1))]
        )
    }

    // MARK: - ClosedRange extensions

    func testUnion_closedRange() {
        XCTAssertEqual(
            (-1...0).union((0...1)),
            (-1...1)
        )

        XCTAssertEqual(
            (-2...(-1)).union((1...2)),
            (-2...2)
        )
    }

    func testCompactIntervals_closedRange() {
        let intervals: [ClosedRange<Int>] = [
            (-7...(-1)),
            (-5...(-1)),
            (1...9),
            (2...4),
            (3...5),
            (4...6),
            (10...14),
            (13...15),
        ]

        XCTAssertEqual(
            intervals.compactIntervals(),
            [
                (-7...(-1)),
                (1...9),
                (10...15),
            ]
        )
    }

    func testCompactIntervalsSingleInterval_closedRange() {
        XCTAssertEqual(
            [(1...2)].compactIntervals(),
            [(1...2)]
        )
    }

    func testCompactIntervalsTwoNonOverlappingIntervals_closedRange() {
        XCTAssertEqual(
            [(4...5), (1...2)].compactIntervals(),
            [(1...2), (4...5)]
        )
    }
}
