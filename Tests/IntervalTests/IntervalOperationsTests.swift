import Interval
import XCTest

class IntervalOperationsTests: XCTestCase {
    func testOverlap() {
        let interval = Interval(start: -1, end: 1)

        XCTAssertEqual(
            interval.overlap(Interval(start: -2, end: 0)),
            Interval(start: -1, end: 0)
        )
        XCTAssertEqual(
            interval.overlap(Interval(start: 0, end: 2)),
            Interval(start: 0, end: 1)
        )
    }

    func testOverlapOnIntervalWhichContainsInterval() {
        let interval = Interval(start: -1, end: 1)

        XCTAssertEqual(interval.overlap(Interval(start: -2, end: 2)), interval)
    }

    func testOverlapNilWhenOverlapRegionIsZeroLength() {
        let interval = Interval(start: -1, end: 1)

        XCTAssertNil(interval.overlap(Interval(start: 1, end: 2)))
    }

    func testOverlapNilWhenNotOverlapping() {
        let interval = Interval(start: -1, end: 1)

        XCTAssertNil(interval.overlap(Interval(start: 5, end: 10)))
    }

    func testUnion() {
        XCTAssertEqual(
            Interval(start: -1, end: 0).union(Interval(start: 0, end: 1)),
            Interval(start: -1, end: 1)
        )

        XCTAssertEqual(
            Interval(start: -2, end: -1).union(Interval(start: 1, end: 2)),
            Interval(start: -2, end: 2)
        )
    }

    func testOverlaps() {
        XCTAssert(Interval(start: -1, end: 1).overlaps(Interval(start: -1, end: 1)))
        XCTAssert(Interval(start: -1, end: 1).overlaps(Interval(start: -1, end: 0)))
        XCTAssert(Interval(start: -1, end: 1).overlaps(Interval(start: 0, end: 1)))
        XCTAssertFalse(Interval(start: -1, end: 1).overlaps(Interval(start: 1, end: 2)))
        XCTAssertFalse(Interval(start: -1, end: 1).overlaps(Interval(start: -2, end: -1)))
    }

    func testIntersects() {
        XCTAssert(Interval(start: -1, end: 1).overlaps(Interval(start: -1, end: 1)))
        XCTAssert(Interval(start: -1, end: 1).overlaps(Interval(start: -1, end: 0)))
        XCTAssert(Interval(start: -1, end: 1).overlaps(Interval(start: 0, end: 1)))
        XCTAssertFalse(Interval(start: -1, end: 1).overlaps(Interval(start: 1, end: 2)))
        XCTAssertFalse(Interval(start: -1, end: 1).overlaps(Interval(start: -2, end: -1)))
    }

    func testCompactIntervals() {
        let intervals: [IntInterval] = [
            Interval(start: 10, end: 13),
            Interval(start: 13, end: 14),
            Interval(start: -5, end: -1),
            Interval(start: -7, end: -2),
            Interval(start: 4, end: 5),
            Interval(start: 2, end: 3),
            Interval(start: 3, end: 4),
            Interval(start: 1, end: 9),
        ]

        XCTAssertEqual(
            intervals.compactIntervals(),
            [
                Interval(start: -7, end: -1), Interval(start: 1, end: 9),
                Interval(start: 10, end: 14),
            ]
        )
    }

    func testCompactIntervalsSingleInterval() {
        XCTAssertEqual(
            [Interval(start: 1, end: 2)].compactIntervals(),
            [Interval(start: 1, end: 2)]
        )
    }

    func testCompactIntervalsTwoNonOverlappingIntervals() {
        XCTAssertEqual(
            [Interval(start: 4, end: 5), Interval(start: 1, end: 2)].compactIntervals(),
            [Interval(start: 1, end: 2), Interval(start: 4, end: 5)]
        )
    }
}
