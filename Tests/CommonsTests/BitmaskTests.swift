import XCTest

@testable import Commons

class BitmaskTests: XCTestCase {
    func testEphemeral() {
        let sut = Bitmask()

        assertEqual(sut, value: 0b0)
    }

    func testInitOnBitRange_range() {
        let sut: Bitmask = Bitmask(onBitRange: 2..<7)

        assertEqual(sut, value: 0b00011_11100)
    }

    func testInitOnBitRange_closedRange() {
        let sut: Bitmask = Bitmask(onBitRange: 2...7)

        assertEqual(sut, value: 0b00111_11100)
    }

    func testStorageLength_emptyBitmask() {
        let sut = Bitmask()

        XCTAssertEqual(sut.storageLength, 1)
    }

    func testBitWidth_emptyBitmask() {
        let sut = Bitmask()

        XCTAssertEqual(sut.bitWidth, 64)
    }

    func testIsAllZeroes() {
        XCTAssertTrue((0b0 as Bitmask).isAllZeroes)
        XCTAssertFalse((0b1 as Bitmask).isAllZeroes)
        XCTAssertFalse((0b1010 as Bitmask).isAllZeroes)
    }

    func testIsNonZero() {
        XCTAssertFalse((0b0 as Bitmask).isNonZero)
        XCTAssertTrue((0b1 as Bitmask).isNonZero)
        XCTAssertTrue((0b1010 as Bitmask).isNonZero)
    }

    func testNonzeroBitCount() {
        let sut: Bitmask = 0b01010_00110_10101_11000_00100_11000_00001

        XCTAssertEqual(sut.nonzeroBitCount, 13)
    }

    func testIsBitSet() {
        let sut: Bitmask = 0b1001
        
        XCTAssertTrue(sut.isBitSet(0))
        XCTAssertFalse(sut.isBitSet(1))
        XCTAssertFalse(sut.isBitSet(2))
        XCTAssertTrue(sut.isBitSet(3))
    }

    func testSetBit() {
        var sut: Bitmask = 0b010

        sut.setBit(2, state: true)
        sut.setBit(1, state: false)

        assertEqual(sut, value: 0b100)
    }

    func testSetBitOn() {
        var sut: Bitmask = 0b0

        sut.setBitOn(2)

        assertEqual(sut, value: 0b100)
    }

    func testSetBitOff() {
        var sut: Bitmask = 0b101

        sut.setBitOff(2)

        assertEqual(sut, value: 0b001)
    }

    func testSetBitRangeOffsetCount_true() {
        var sut: Bitmask = 0b10010_00101

        sut.setBitRange(offset: 2, count: 6, state: true)

        assertEqual(sut, value: 0b10111_11101)
    }

    func testSetBitRangeOffsetCount_false() {
        var sut: Bitmask = 0b10010_00101

        sut.setBitRange(offset: 2, count: 6, state: false)

        assertEqual(sut, value: 0b10000_00001)
    }

    func testSetBitRange_range_true() {
        var sut: Bitmask = 0b10010_00101

        sut.setBitRange(2..<7, state: true)

        assertEqual(sut, value: 0b10011_11101)
    }

    func testSetBitRange_range_false() {
        var sut: Bitmask = 0b10010_00101

        sut.setBitRange(2..<7, state: false)

        assertEqual(sut, value: 0b10000_00001)
    }

    func testSetBitRange_closedRange_true() {
        var sut: Bitmask = 0b10010_00101

        sut.setBitRange(2...7, state: true)

        assertEqual(sut, value: 0b10111_11101)
    }

    func testSetBitRange_closedRange_false() {
        var sut: Bitmask = 0b10010_00101

        sut.setBitRange(2...7, state: false)

        assertEqual(sut, value: 0b10000_00001)
    }

    func testWithStorage() {
        let sut: Bitmask = 0b10010_00101

        let result = extractStorage(sut)

        XCTAssertEqual(result, [0b10010_00101])
    }

    func testForEachOnBitIndex() {
        let sut: Bitmask = 0b11101_00011_10000_11110_00000_00111_11110
        var indices: [Int] = []

        sut.forEachOnBitIndex { index in
            indices.append(index)            
        }

        XCTAssertEqual(indices, [
            1, 2, 3, 4, 5, 6, 7, 16, 17, 18, 19, 24, 25, 26, 30, 32, 33, 34
        ])
    }

    func testForEachOnBitIndex_copyBitmasks() {
        let sut: Bitmask = 0b11101_00011_10000_11110_00000_00111_11110
        var copy = Bitmask()

        sut.forEachOnBitIndex { index in
            copy.setBitOn(index)
        }

        XCTAssertEqual(sut, copy)
    }

    func testAndOperator() {
        let bitmask1: Bitmask = 0b10010_00101
        let bitmask2: Bitmask = 0b01010_11001

        let result = bitmask1 & bitmask2

        assertEqual(result, value: 0b00010_00001)
    }

    func testOrOperator() {
        let bitmask1: Bitmask = 0b10010_00101
        let bitmask2: Bitmask = 0b01010_11001

        let result = bitmask1 | bitmask2

        assertEqual(result, value: 0b11010_11101)
    }

    func testXOrOperator() {
        let bitmask1: Bitmask = 0b10010_00101
        let bitmask2: Bitmask = 0b01010_11001

        let result = bitmask1 ^ bitmask2

        assertEqual(result, value: 0b11000_11100)
    }

    func testNegateOperator() {
        let bitmask: Bitmask = 0b10010_00101

        let result = ~bitmask

        assertEqual(
            result,
            value: 0b1111_11111_11111_11111_11111_11111_11111_11111_11111_11111_11111_01101_11010
        )
    }

    // MARK: - Test utils

    private func assertEqual(_ bitmask: Bitmask, value: UInt64, line: UInt = #line) {
        let storage = extractStorage(bitmask)
        let expected = [value]

        XCTAssertEqual(
            storage,
            expected,
            "\(formatStorage(storage)) != \(formatStorage(expected))",
            line: line
        )
    }

    private func extractStorage(_ bitmask: Bitmask) -> [UInt64] {
        var result: [UInt64] = []

        bitmask.withStorage {
            result.append($0)
        }

        return result
    }

    private func formatStorage(_ storage: [UInt64]) -> String {
        var result: [String] = []

        for binary in storage {
            var binaryString = String(binary, radix: 2)

            // Underscore every five digits
            binaryString = String(binaryString.reversed())

            let sepInterval = 5
            for sep in stride(from: 0, to: binaryString.count, by: sepInterval).dropFirst().reversed() {
                binaryString.insert(
                    "_",
                    at: binaryString.index(binaryString.startIndex, offsetBy: sep)
                )
            }

            binaryString = String(binaryString.reversed())

            // Prepend '0b' binary qualifier
            result.append("0b\(binaryString)")
        }

        return "[" + result.joined(separator: ", ") + "]"
    }
}
