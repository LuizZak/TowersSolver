import XCTest
import Commons

class KeyTests: XCTestCase {
    func testIsEquatable() {
        XCTAssertEqual(Key<String, Int>(1), Key<String, Int>(1))
        XCTAssertNotEqual(Key<String, Int>(1), Key<String, Int>(2))
    }
}
