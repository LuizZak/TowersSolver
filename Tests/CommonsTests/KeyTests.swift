import XCTest
import Commons

class KeyTests: XCTest {
    func testIsEquatable() {
        XCTAssertEqual(Key<String, Int>(1), Key<String, Int>(1))
        XCTAssertNotEqual(Key<String, Int>(1), Key<String, Int>(2))
    }
}
