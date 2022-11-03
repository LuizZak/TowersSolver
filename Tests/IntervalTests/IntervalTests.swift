import Interval
import XCTest

class IntervalTests: XCTestCase {
    func testEquals() {
        XCTAssertEqual(IntInterval(start: -1, end: 0), IntInterval(start: -1, end: 0))
        XCTAssertEqual(IntInterval(start: 0, end: 1), IntInterval(start: 0, end: 1))
        XCTAssertEqual(IntInterval(start: 1, end: 2), IntInterval(start: 1, end: 2))

        XCTAssertNotEqual(IntInterval(start: -1, end: 1), IntInterval(start: -1, end: 0))
        XCTAssertNotEqual(IntInterval(start: -1, end: 1), IntInterval(start: 0, end: 1))
    }

    func testContains() {
        let sut = IntInterval(start: -1, end: 1)

        XCTAssertFalse(sut.contains(-2))
        XCTAssertTrue(sut.contains(-1))
        XCTAssertTrue(sut.contains(0))
        XCTAssertTrue(sut.contains(1))
        XCTAssertFalse(sut.contains(2))
    }

    func testSequence() {
        let sut = IntInterval(start: -2, end: 2)

        XCTAssertEqual(Array(sut), [-2, -1, 0, 1, 2])
    }
}
