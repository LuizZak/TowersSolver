import XCTest

@testable import Commons

class Collection_ExtTests: XCTestCase {
    func testIndexRanges() {
        let sut = [
            0, 1, -5, 6, 0, -1, -2, 10, 15, 7
        ]
        
        XCTAssertEqual(sut.indexRanges(where: { $0 >= 0 }), [
            (0..<2),
            (3..<5),
            (7..<10),
        ])
    }

    func testIndexRanges_emptyRange() {
        let sut = [
            -1, -2, -3, -5, -1, -10
        ]
        
        XCTAssertEqual(sut.indexRanges(where: { $0 >= 0 }), [])
    }

    func testIndexRanges_fullList() {
        let sut = [
            1, 2, 3, 5, 1, 10
        ]
        
        XCTAssertEqual(sut.indexRanges(where: { $0 >= 0 }), [
            (0..<6)
        ])
    }
}
