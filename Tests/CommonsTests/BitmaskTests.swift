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

    func testIsBitRangeZero() {
        let sut: Bitmask = 0b1111_11000
        
        XCTAssertTrue(sut.isBitRangeZero(offset: 0, count: 3))
        XCTAssertFalse(sut.isBitRangeZero(offset: 0, count: 4))
        XCTAssertFalse(sut.isBitRangeZero(offset: 3, count: 6))
        XCTAssertTrue(sut.isBitRangeZero(offset: 9, count: 20))
    }

    func testSetBit() {
        var sut: Bitmask = 0b010

        sut.setBit(2, state: true)
        sut.setBit(1, state: false)

        assertEqual(sut, value: 0b100)
    }

    func testSetBitOn() {
        var sut: Bitmask = 0b010

        sut.setBitOn(1)
        sut.setBitOn(2)

        assertEqual(sut, value: 0b110)
    }

    func testSetBitOff() {
        var sut: Bitmask = 0b101

        sut.setBitOff(1)
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

    func testSetAllBits_true() {
        var sut: Bitmask = 0b10010_00101

        sut.setAllBits(state: true)

        assertEqual(sut, value: UInt64.max)
    }

    func testSetAllBits_false() {
        var sut: Bitmask = 0b10010_00101

        sut.setAllBits(state: false)

        assertEqual(sut, value: 0b0)
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

    // MARK: Past 64 bits

    func testInitOnBitRange_range_past64Bits() {
        let sut = Bitmask(onBitRange: 32..<80)

        assertEqual(
            sut,
            value: [0b1111_11111_11111_11111_11111_11111_11100_00000_00000_00000_00000_00000_00000, 0b1_11111_11111_11111]
        )
    }

    func testInitOnBitRange_closedRange_past64Bits() {
        let sut = Bitmask(onBitRange: 32...80)

        assertEqual(
            sut,
            value: [0b1111_11111_11111_11111_11111_11111_11100_00000_00000_00000_00000_00000_00000, 0b11_11111_11111_11111]
        )
    }
    
    func testInitWithBits_past64Bits() {
        let sut = Bitmask(bits: [0b01011, 0b11001_0000])

        assertEqual(
            sut,
            value: [0b01011, 0b11001_0000]
        )
    }
    
    func testStorageLength_past64Bits() {
        var sut = Bitmask()
        sut.setBit(180, state: true)

        XCTAssertEqual(sut.storageLength, 3)
    }

    func testBitWidth_past64Bits() {
        var sut = Bitmask()
        sut.setBit(180, state: true)

        XCTAssertEqual(sut.bitWidth, 192)
    }

    func testIsAllZeroes_past64Bits() {
        XCTAssertTrue(Bitmask(bits: [0b0, 0b0]).isAllZeroes)
        XCTAssertFalse(Bitmask(bits: [0b1011, 0b0]).isAllZeroes)
        XCTAssertFalse(Bitmask(bits: [0b0, 0b1011]).isAllZeroes)
    }

    func testIsNonZero_past64Bits() {
        XCTAssertFalse(Bitmask(bits: [0b0, 0b0]).isNonZero)
        XCTAssertTrue(Bitmask(bits: [0b1011, 0b0]).isNonZero)
        XCTAssertTrue(Bitmask(bits: [0b0, 0b1011]).isNonZero)
    }

    func testNonzeroBitCount_past64Bits() {
        XCTAssertEqual(Bitmask(onBitRange: 32..<80).nonzeroBitCount, 48)
    }

    func testEquatable_past64Bits_unequalLengthStorage() {
        let bitmask1 = Bitmask(bits: [
            0b10110,
            0b0,
            0b0,
        ])
        let bitmask2 = Bitmask(bits: [
            0b10110,
        ])

        XCTAssertEqual(bitmask1, bitmask2)
    }

    func testHashable_past64Bits_unequalLengthStorage() {
        let bitmask1 = Bitmask(bits: [
            0b10110,
            0b0,
            0b0,
        ])
        let bitmask2 = Bitmask(bits: [
            0b10110,
        ])

        XCTAssertEqual(bitmask1.hashValue, bitmask2.hashValue)
    }

    func testCompact_pas64Bits() {
        var bitmask1 = Bitmask(bits: [
            0b10110,
            0b0,
            0b1,
        ])
        var bitmask2 = Bitmask(bits: [
            0b10110,
            0b0,
            0b0,
        ])

        bitmask1.compact()
        bitmask2.compact()

        assertEqual(bitmask1, value: [
            0b10110,
            0b0,
            0b1,
        ])
        assertEqual(bitmask2, value: [
            0b10110,
        ])
    }

    func testCompacted_pas64Bits() {
        let bitmask1 = Bitmask(bits: [
            0b10110,
            0b0,
            0b1,
        ])
        let bitmask2 = Bitmask(bits: [
            0b10110,
            0b0,
            0b0,
        ])

        assertEqual(bitmask1.compacted(), value: [
            0b10110,
            0b0,
            0b1,
        ])
        assertEqual(bitmask2.compacted(), value: [
            0b10110,
        ])
    }

    func testIsBitSet_past64Bits() {
        var sut: Bitmask = 0b1001
        sut.setBit(128, state: true)
        
        XCTAssertTrue(sut.isBitSet(0))
        XCTAssertFalse(sut.isBitSet(1))
        XCTAssertFalse(sut.isBitSet(2))
        XCTAssertTrue(sut.isBitSet(3))
        XCTAssertFalse(sut.isBitSet(127))
        XCTAssertTrue(sut.isBitSet(128))
        XCTAssertFalse(sut.isBitSet(129))
    }

    func testIsBitRangeZero_past64Bits() {
        var sut: Bitmask = 0b01010_11001
        sut.setBit(190, state: true)
        
        XCTAssertFalse(sut.isBitRangeZero(offset: 0, count: 1))
        XCTAssertTrue(sut.isBitRangeZero(offset: 1, count: 2))
        XCTAssertTrue(sut.isBitRangeZero(offset: 10, count: 120))
        XCTAssertFalse(sut.isBitRangeZero(offset: 63, count: 128))
    }

    func testSetBit_past64Bits() {
        var sut: Bitmask = 0b110

        sut.setBit(64, state: true)
        sut.setBit(1, state: false)

        assertEqual(sut, value: [0b100, 0b1])
    }

    func testSetBitOn_past64Bits() {
        var sut: Bitmask = 0b100

        sut.setBitOn(64)
        sut.setBitOn(1)

        assertEqual(sut, value: [0b110, 0b1])
    }

    func testSetBitOff_past64Bits_past64Bits() {
        var sut: Bitmask = 0b101

        sut.setBitOff(64)
        sut.setBitOff(2)

        assertEqual(sut, value: [0b001, 0b0])
    }

    func testSetBitRangeOffsetCount_true_past64Bits() {
        var sut: Bitmask = 0b10010_00101

        sut.setBitRange(offset: 8, count: 64, state: true)

        assertEqual(
            sut,
            value: [
                0b1111_11111_11111_11111_11111_11111_11111_11111_11111_11111_11111_11010_00101,
                0b111_11111
            ]
        )
    }

    func testSetBitRangeOffsetCount_false_past64Bits() {
        var sut: Bitmask = 0b10010_00101

        sut.setBitRange(offset: 8, count: 64, state: false)

        assertEqual(sut, value: [0b00010_00101, 0b0])
    }

    func testSetBitRange_range_true_past64Bits() {
        var sut: Bitmask = 0b10010_00101

        sut.setBitRange(8..<72, state: true)

        assertEqual(
            sut,
            value: [
                0b1111_11111_11111_11111_11111_11111_11111_11111_11111_11111_11111_11010_00101,
                0b111_11111
            ]
        )
    }

    func testSetBitRange_range_false_past64Bits() {
        var sut: Bitmask = 0b10010_00101

        sut.setBitRange(8..<72, state: false)

        assertEqual(sut, value: [0b00010_00101, 0b0])
    }

    func testSetBitRange_closedRange_true_past64Bits() {
        var sut: Bitmask = 0b10010_00101

        sut.setBitRange(8...72, state: true)

        assertEqual(
            sut,
            value: [
                0b1111_11111_11111_11111_11111_11111_11111_11111_11111_11111_11111_11010_00101,
                0b1111_11111
            ]
        )
    }

    func testSetBitRange_closedRange_false_past64Bits() {
        var sut: Bitmask = 0b10010_00101

        sut.setBitRange(8...72, state: false)

        assertEqual(sut, value: [0b00010_00101, 0b0])
    }

    func testSetAllBits_true_past64Bits() {
        var sut: Bitmask = Bitmask(onBitRange: 32...80)

        sut.setAllBits(state: true)

        assertEqual(sut, value: [UInt64.max, UInt64.max])
    }

    func testSetAllBits_false_past64Bits() {
        var sut: Bitmask = Bitmask(onBitRange: 32...80)

        sut.setAllBits(state: false)

        assertEqual(sut, value: [0b0, 0b0])
    }

    func testShiftingBitsLeft_past64Bits() {
        let sut: Bitmask = 0b10000_10001

        let result = sut.shiftingBitsLeft(count: 59)

        assertEqual(
            result,
            value: [
                0b1000_10000_00000_00000_00000_00000_00000_00000_00000_00000_00000_00000_00000,
                0b10000,
            ]
        )
    }

    func testShiftBitsLeft_past64Bits() {
        var sut: Bitmask = 0b10000_10001

        sut.shiftBitsLeft(count: 59)

        assertEqual(
            sut,
            value: [
                0b1000_10000_00000_00000_00000_00000_00000_00000_00000_00000_00000_00000_00000,
                0b10000,
            ]
        )
    }

    func testShiftingBitsRight_past64Bits() {
        let sut: Bitmask = Bitmask(bits: [
            0b1000_10000_00000_00000_00000_00000_00000_01110_00000_00000_01100_10000_00001,
            0b10000,
        ])

        let result = sut.shiftingBitsRight(count: 59)

        assertEqual(
            result,
            value: [
                0b10000_10001,
            ]
        )
    }

    func testShiftBitsRight_past64Bits() {
        var sut: Bitmask = Bitmask(bits: [
            0b1000_10000_00000_00000_00000_00000_00000_01110_00000_00000_01100_10000_00001,
            0b10000,
        ])

        sut.shiftBitsRight(count: 59)

        assertEqual(
            sut,
            value: [
                0b10000_10001,
            ]
        )
    }

    func testWithStorage_past64Bits() {
        var sut: Bitmask = 0b10010_00101
        sut.setBitRange(offset: 8, count: 64, state: true)

        let result = extractStorage(sut)

        XCTAssertEqual(
            result, [
                0b1111_11111_11111_11111_11111_11111_11111_11111_11111_11111_11111_11010_00101,
                0b111_11111,
            ]
        )
    }

    func testForEachOnBitIndex_past64Bits() {
        let sut = Bitmask(bits: [
            0b11101_00011_10000_11110_00000_00111_11110,
            0b11110_01001_00101_00100_11101_11110_00111,
        ])
        var indices: [Int] = []

        sut.forEachOnBitIndex { index in
            indices.append(index)            
        }

        XCTAssertEqual(indices, [
            1, 2, 3, 4, 5, 6, 7, 16, 17, 18, 19, 24, 25, 26, 30, 32, 33, 34,
            64, 65, 66, 70, 71, 72, 73, 74, 76, 77, 78, 81, 84, 86, 89, 92, 95,
            96, 97, 98,
        ])
    }

    func testForEachOnBitIndex_copyBitmasks_past64Bits() {
        let sut = Bitmask(bits: [
            0b11101_00011_10000_11110_00000_00111_11110,
            0b11110_01001_00101_00100_11101_11110_00111,
        ])
        var copy = Bitmask()

        sut.forEachOnBitIndex { index in
            copy.setBitOn(index)
        }

        XCTAssertEqual(sut, copy)
    }

    func testAndOperator_past64Bits() {
        let bitmask1 = Bitmask(bits: [0b10010_00101, 0b00101_10010])
        let bitmask2 = Bitmask(bits: [0b01010_11001, 0b11001_01010])

        let result = bitmask1 & bitmask2

        assertEqual(result, value: [0b00010_00001, 0b0001_00010])
    }

    func testOrOperator_past64Bits() {
        let bitmask1 = Bitmask(bits: [0b10010_00101, 0b00101_10010])
        let bitmask2 = Bitmask(bits: [0b01010_11001, 0b11001_01010])

        let result = bitmask1 | bitmask2

        assertEqual(result, value: [0b11010_11101, 0b11101_11010])
    }

    func testXOrOperator_past64Bits() {
        let bitmask1 = Bitmask(bits: [0b10010_00101, 0b00101_10010])
        let bitmask2 = Bitmask(bits: [0b01010_11001, 0b11001_01010])

        let result = bitmask1 ^ bitmask2

        assertEqual(result, value: [0b11000_11100, 0b11100_11000])
    }

    func testNegateOperator_past64Bits() {
        let bitmask = Bitmask(bits: [0b10010_00101, 0b00101_10010])

        let result = ~bitmask

        assertEqual(
            result,
            value: [
                0b1111_11111_11111_11111_11111_11111_11111_11111_11111_11111_11111_01101_11010,
                0b1111_11111_11111_11111_11111_11111_11111_11111_11111_11111_11111_11010_01101,
            ]
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

    private func assertEqual(_ bitmask: Bitmask, value: [UInt64], line: UInt = #line) {
        let storage = extractStorage(bitmask)

        XCTAssertEqual(
            storage,
            value,
            "\(formatStorage(storage)) != \(formatStorage(value))",
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
