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
}
