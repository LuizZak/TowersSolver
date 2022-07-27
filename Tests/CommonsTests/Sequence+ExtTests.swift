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

    func testCommonPrefix() {
        XCTAssertEqual(
            [0, 1, 2].commonPrefix(sharedWith: [0, 1, 3]),
            [0, 1]
        )
        XCTAssertEqual(
            [0, 1, 2].commonPrefix(sharedWith: [0, 3, 2]),
            [0]
        )
    }

    func testCommonPrefix_emptyInputs() {
        XCTAssertEqual(Array<Int>().commonPrefix(sharedWith: []), [])
        XCTAssertEqual(
            [].commonPrefix(sharedWith: [0, 1, 2]),
            []
        )
        XCTAssertEqual(
            [0, 1, 2].commonPrefix(sharedWith: []),
            []
        )
    }

    func testCommonSuffix() {
        XCTAssertEqual(
            [0, 1, 2, 3].commonSuffix(sharedWith: [4, 5, 2, 3]),
            [2, 3]
        )
        XCTAssertEqual(
            [0, 1, 2, 3].commonSuffix(sharedWith: [3, 3]),
            [3]
        )
    }

    func testCommonSuffix_emptyInputs() {
        XCTAssertEqual(Array<Int>().commonSuffix(sharedWith: []), [])
        XCTAssertEqual(
            [].commonSuffix(sharedWith: [0, 1, 2]),
            []
        )
        XCTAssertEqual(
            [0, 1, 2].commonSuffix(sharedWith: []),
            []
        )
    }
}
