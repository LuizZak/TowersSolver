import Commons
import XCTest

class Sequence_ExtTests: XCTestCase {
    func testCount() {
        let array = [0, 1, 2, 2, 3, 4]

        // Predicate
        XCTAssertEqual(4, array.count { $0 % 2 == 0 })
        XCTAssertEqual(array.count, array.count { _ in true })
        XCTAssertEqual(0, array.count { _ in false })

        // Individual item counting
        XCTAssertEqual(1, array.count(1))
        XCTAssertEqual(2, array.count(2))
        XCTAssertEqual(0, array.count(5))
    }
}
