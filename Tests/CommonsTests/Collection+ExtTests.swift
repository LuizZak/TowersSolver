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

    func testNextIndexRange() {
        let sut = [
            0, 1, -5, 6, 0, -1, -2, 10, 15, 7
        ]

        XCTAssertEqual(sut.nextIndexRange(where: { $0 >= 0 }), (0..<2))
        XCTAssertEqual(sut.nextIndexRange(fromIndex: 2, where: { $0 >= 0 }), (3..<5))
        XCTAssertEqual(sut.nextIndexRange(fromIndex: 8, where: { $0 >= 0 }), (8..<10))
        XCTAssertEqual(sut.nextIndexRange(where: { $0 >= 100 }), nil)
    }

    func testIndicesSurrounding() {
        let sut = [
            0, 1, -5, 6, 0, -1, -2, 10, 15, 7
        ]

        XCTAssertEqual(sut.indicesSurrounding(index: 1, where: { $0 >= 0 }), (0..<2))
        XCTAssertEqual(sut.indicesSurrounding(index: 2, where: { $0 >= 0 }), nil)
        XCTAssertEqual(sut.indicesSurrounding(index: 3, where: { $0 >= 0 }), (3..<5))
        XCTAssertEqual(sut.indicesSurrounding(index: 4, where: { $0 >= 0 }), (3..<5))
        XCTAssertEqual(sut.indicesSurrounding(index: 5, where: { $0 >= 0 }), nil)
        XCTAssertEqual(sut.indicesSurrounding(index: 6, where: { $0 >= 0 }), nil)
        XCTAssertEqual(sut.indicesSurrounding(index: 7, where: { $0 >= 0 }), (7..<10))
    }
}
