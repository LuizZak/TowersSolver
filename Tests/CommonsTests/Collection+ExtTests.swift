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
    
    func testBinarySearchIndex_comparable_length0() {
        XCTAssertNil([].binarySearchIndex(value: 0))
    }
    
    func testBinarySearchIndex_comparable_length1() {
        XCTAssertEqual([0].binarySearchIndex(value: 0), 0)
        
        XCTAssertNil([0].binarySearchIndex(value: -1))
        XCTAssertNil([0].binarySearchIndex(value: 1))
    }
    
    func testBinarySearchIndex_comparable_length2() {
        XCTAssertEqual([0, 1].binarySearchIndex(value: 0), 0)
        XCTAssertEqual([0, 1].binarySearchIndex(value: 1), 1)
        
        XCTAssertNil([0, 1].binarySearchIndex(value: -1))
        XCTAssertNil([0, 1].binarySearchIndex(value: 2))
    }
    
    func testBinarySearchIndex_comparable_length5() {
        XCTAssertEqual([0, 1, 2, 3, 4].binarySearchIndex(value: 0), 0)
        XCTAssertEqual([0, 1, 2, 3, 4].binarySearchIndex(value: 1), 1)
        XCTAssertEqual([0, 1, 2, 3, 4].binarySearchIndex(value: 2), 2)
        XCTAssertEqual([0, 1, 2, 3, 4].binarySearchIndex(value: 3), 3)
        XCTAssertEqual([0, 1, 2, 3, 4].binarySearchIndex(value: 4), 4)
        
        XCTAssertNil([0, 1, 2, 3, 4].binarySearchIndex(value: -1))
        XCTAssertNil([0, 1, 2, 3, 4].binarySearchIndex(value: 5))
    }
    
    func testBinarySearchIndex_transform_length0() {
        XCTAssertNil([].binarySearchIndex(value: 0, transform: { $0 }))
    }
    
    func testBinarySearchIndex_transform_length1() {
        XCTAssertEqual([0].binarySearchIndex(value: 0, transform: { $0 }), 0)
        
        XCTAssertNil([0].binarySearchIndex(value: -1, transform: { $0 }))
        XCTAssertNil([0].binarySearchIndex(value: 1, transform: { $0 }))
    }
    
    func testBinarySearchIndex_transform_length2() {
        XCTAssertEqual([0, 1].binarySearchIndex(value: 0, transform: { $0 }), 0)
        XCTAssertEqual([0, 1].binarySearchIndex(value: 1, transform: { $0 }), 1)
        
        XCTAssertNil([0, 1].binarySearchIndex(value: -1, transform: { $0 }))
        XCTAssertNil([0, 1].binarySearchIndex(value: 2, transform: { $0 }))
    }
    
    func testBinarySearchIndex_transform_length5() {
        XCTAssertEqual([0, 1, 2, 3, 4].binarySearchIndex(value: 0, transform: { $0 }), 0)
        XCTAssertEqual([0, 1, 2, 3, 4].binarySearchIndex(value: 1, transform: { $0 }), 1)
        XCTAssertEqual([0, 1, 2, 3, 4].binarySearchIndex(value: 2, transform: { $0 }), 2)
        XCTAssertEqual([0, 1, 2, 3, 4].binarySearchIndex(value: 3, transform: { $0 }), 3)
        XCTAssertEqual([0, 1, 2, 3, 4].binarySearchIndex(value: 4, transform: { $0 }), 4)
        
        XCTAssertNil([0, 1, 2, 3, 4].binarySearchIndex(value: -1, transform: { $0 }))
        XCTAssertNil([0, 1, 2, 3, 4].binarySearchIndex(value: 5, transform: { $0 }))
    }
    
    func testBinarySearchInsert_comparable_length0() {
        XCTAssertEqual([].binarySearchInsert(value: 0), 0)
    }
    
    func testBinarySearchInsert_comparable_length1() {
        XCTAssertEqual([0].binarySearchInsert(value: 0), 1)
        
        XCTAssertEqual([0].binarySearchInsert(value: -1), 0)
        XCTAssertEqual([0].binarySearchInsert(value: 1), 1)
    }
    
    func testBinarySearchInsert_comparable_length2() {
        XCTAssertEqual([0, 1].binarySearchInsert(value: 0), 1)
        XCTAssertEqual([0, 1].binarySearchInsert(value: 1), 1)
        
        XCTAssertEqual([0, 1].binarySearchInsert(value: -1), 0)
        XCTAssertEqual([0, 1].binarySearchInsert(value: 2), 2)
    }
    
    func testBinarySearchInsert_comparable_length5() {
        XCTAssertEqual([0, 1, 2, 3, 4].binarySearchInsert(value: 0), 1)
        XCTAssertEqual([0, 1, 2, 3, 4].binarySearchInsert(value: 1), 1)
        XCTAssertEqual([0, 1, 2, 3, 4].binarySearchInsert(value: 2), 2)
        XCTAssertEqual([0, 1, 2, 3, 4].binarySearchInsert(value: 3), 3)
        XCTAssertEqual([0, 1, 2, 3, 4].binarySearchInsert(value: 4), 4)
        
        XCTAssertEqual([0, 1, 2, 3, 4].binarySearchInsert(value: -1), 0)
        XCTAssertEqual([0, 1, 2, 3, 4].binarySearchInsert(value: 5), 5)
    }
    
    func testBinarySearchInsert_comparable_nonExistingValue() {
        XCTAssertEqual([0, 1, 5, 6, 7].binarySearchInsert(value: 4), 2)
    }
    
    func testBinarySearchInsert_transform_length0() {
        XCTAssertEqual([].binarySearchInsert(value: 0, transform: { $0 }), 0)
    }
    
    func testBinarySearchInsert_transform_length1() {
        XCTAssertEqual([0].binarySearchInsert(value: 0, transform: { $0 }), 1)
        
        XCTAssertEqual([0].binarySearchInsert(value: -1, transform: { $0 }), 0)
        XCTAssertEqual([0].binarySearchInsert(value: 1, transform: { $0 }), 1)
    }
    
    func testBinarySearchInsert_transform_length2() {
        XCTAssertEqual([0, 1].binarySearchInsert(value: 0, transform: { $0 }), 1)
        XCTAssertEqual([0, 1].binarySearchInsert(value: 1, transform: { $0 }), 1)
        
        XCTAssertEqual([0, 1].binarySearchInsert(value: -1, transform: { $0 }), 0)
        XCTAssertEqual([0, 1].binarySearchInsert(value: 2, transform: { $0 }), 2)
    }
    
    func testBinarySearchInsert_transform_length5() {
        XCTAssertEqual([0, 1, 2, 3, 4].binarySearchInsert(value: 0, transform: { $0 }), 1)
        XCTAssertEqual([0, 1, 2, 3, 4].binarySearchInsert(value: 1, transform: { $0 }), 1)
        XCTAssertEqual([0, 1, 2, 3, 4].binarySearchInsert(value: 2, transform: { $0 }), 2)
        XCTAssertEqual([0, 1, 2, 3, 4].binarySearchInsert(value: 3, transform: { $0 }), 3)
        XCTAssertEqual([0, 1, 2, 3, 4].binarySearchInsert(value: 4, transform: { $0 }), 4)
        
        XCTAssertEqual([0, 1, 2, 3, 4].binarySearchInsert(value: -1, transform: { $0 }), 0)
        XCTAssertEqual([0, 1, 2, 3, 4].binarySearchInsert(value: 5, transform: { $0 }), 5)
    }
}
