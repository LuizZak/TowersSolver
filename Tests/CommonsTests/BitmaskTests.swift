import XCTest

@testable import Commons

class BitmaskTests: XCTestCase {
    func testEphemeral() {
        let sut = Bitmask64()

        assertEqual(sut, value: 0b0)
    }

    func testInitOnBitRange_range() {
        let sut: Bitmask64 = Bitmask64(onBitRange: 2..<7)

        assertEqual(sut, value: 0b00011_11100)
    }

    func testInitOnBitRange_closedRange() {
        let sut: Bitmask64 = Bitmask64(onBitRange: 2...7)

        assertEqual(sut, value: 0b00111_11100)
    }

    func testInitWithIntegerLiteral_8BitWith64Bits() {
        let sut: Bitmask8 = 0b01010_00110_10101_11000_00100_11000_00001

        assertEqual(
            sut,
            value: [
                0b00000001,
                0b00010011,
                0b01011100,
                0b10001101,
                0b00000010,
            ]
        )
    }

    func testInitWithIntegerLiteral_64BitWith64Bits() {
        let sut: Bitmask64 = 0b01010_00110_10101_11000_00100_11000_00001

        assertEqual(
            sut,
            value: [
                0b01010_00110_10101_11000_00100_11000_00001,
            ]
        )
    }

    func testStorageLength_emptyBitmask() {
        let sut = Bitmask64()

        XCTAssertEqual(sut.storageLength, 1)
    }

    func testBitWidth_emptyBitmask() {
        let sut = Bitmask64()

        XCTAssertEqual(sut.bitWidth, 64)
    }

    func testIsAllZeroes() {
        XCTAssertTrue((0b0 as Bitmask64).isAllZeroes)
        XCTAssertFalse((0b1 as Bitmask64).isAllZeroes)
        XCTAssertFalse((0b1010 as Bitmask64).isAllZeroes)
    }

    func testIsNonZero() {
        XCTAssertFalse((0b0 as Bitmask64).isNonZero)
        XCTAssertTrue((0b1 as Bitmask64).isNonZero)
        XCTAssertTrue((0b1010 as Bitmask64).isNonZero)
    }

    func testNonzeroBitCount() {
        let sut: Bitmask64 = 0b01010_00110_10101_11000_00100_11000_00001

        XCTAssertEqual(sut.nonzeroBitCount, 13)
    }

    func testIsBitSet() {
        let sut: Bitmask64 = 0b1001
        
        XCTAssertTrue(sut.isBitSet(0))
        XCTAssertFalse(sut.isBitSet(1))
        XCTAssertFalse(sut.isBitSet(2))
        XCTAssertTrue(sut.isBitSet(3))
    }

    func testIsBitRangeZero() {
        let sut: Bitmask64 = 0b1111_11000
        
        XCTAssertTrue(sut.isBitRangeZero(offset: 0, count: 3))
        XCTAssertFalse(sut.isBitRangeZero(offset: 0, count: 4))
        XCTAssertFalse(sut.isBitRangeZero(offset: 3, count: 6))
        XCTAssertTrue(sut.isBitRangeZero(offset: 9, count: 20))
    }

    func testSetBit() {
        var sut: Bitmask64 = 0b010

        sut.setBit(2, state: true)
        sut.setBit(1, state: false)

        assertEqual(sut, value: 0b100)
    }

    func testSetBitOn() {
        var sut: Bitmask64 = 0b010

        sut.setBitOn(1)
        sut.setBitOn(2)

        assertEqual(sut, value: 0b110)
    }

    func testSetBitOff() {
        var sut: Bitmask64 = 0b101

        sut.setBitOff(1)
        sut.setBitOff(2)

        assertEqual(sut, value: 0b001)
    }

    func testSetBitRangeOffsetCount_true() {
        var sut: Bitmask64 = 0b10010_00101

        sut.setBitRange(offset: 2, count: 6, state: true)

        assertEqual(sut, value: 0b10111_11101)
    }

    func testSetBitRangeOffsetCount_false() {
        var sut: Bitmask64 = 0b10010_00101

        sut.setBitRange(offset: 2, count: 6, state: false)

        assertEqual(sut, value: 0b10000_00001)
    }

    func testSetBitRange_range_true() {
        var sut: Bitmask64 = 0b10010_00101

        sut.setBitRange(2..<7, state: true)

        assertEqual(sut, value: 0b10011_11101)
    }

    func testSetBitRange_range_false() {
        var sut: Bitmask64 = 0b10010_00101

        sut.setBitRange(2..<7, state: false)

        assertEqual(sut, value: 0b10000_00001)
    }

    func testSetBitRange_closedRange_true() {
        var sut: Bitmask64 = 0b10010_00101

        sut.setBitRange(2...7, state: true)

        assertEqual(sut, value: 0b10111_11101)
    }

    func testSetBitRange_closedRange_false() {
        var sut: Bitmask64 = 0b10010_00101

        sut.setBitRange(2...7, state: false)

        assertEqual(sut, value: 0b10000_00001)
    }

    func testSetAllBits_true() {
        var sut: Bitmask64 = 0b10010_00101

        sut.setAllBits(state: true)

        assertEqual(sut, value: UInt64.max)
    }

    func testSetAllBits_false() {
        var sut: Bitmask64 = 0b10010_00101

        sut.setAllBits(state: false)

        assertEqual(sut, value: 0b0)
    }

    func testWithStorage() {
        let sut: Bitmask64 = 0b10010_00101

        let result = extractStorage(sut)

        XCTAssertEqual(result, [0b10010_00101])
    }

    func testForEachOnBitIndex() {
        let sut: Bitmask64 = 0b11101_00011_10000_11110_00000_00111_11110
        var indices: [Int] = []

        sut.forEachOnBitIndex { index in
            indices.append(index)            
        }

        XCTAssertEqual(indices, [
            1, 2, 3, 4, 5, 6, 7, 16, 17, 18, 19, 24, 25, 26, 30, 32, 33, 34
        ])
    }

    func testForEachOnBitIndex_copyBitmasks() {
        let sut: Bitmask64 = 0b11101_00011_10000_11110_00000_00111_11110
        var copy = Bitmask64()

        sut.forEachOnBitIndex { index in
            copy.setBitOn(index)
        }

        XCTAssertEqual(sut, copy)
    }

    func testAndOperator() {
        let bitmask1: Bitmask64 = 0b10010_00101
        let bitmask2: Bitmask64 = 0b01010_11001

        let result = bitmask1 & bitmask2

        assertEqual(result, value: 0b00010_00001)
    }

    func testOrOperator() {
        let bitmask1: Bitmask64 = 0b10010_00101
        let bitmask2: Bitmask64 = 0b01010_11001

        let result = bitmask1 | bitmask2

        assertEqual(result, value: 0b11010_11101)
    }

    func testXOrOperator() {
        let bitmask1: Bitmask64 = 0b10010_00101
        let bitmask2: Bitmask64 = 0b01010_11001

        let result = bitmask1 ^ bitmask2

        assertEqual(result, value: 0b11000_11100)
    }

    func testNegateOperator() {
        let bitmask: Bitmask64 = 0b10010_00101

        let result = ~bitmask

        assertEqual(
            result,
            value: 0b1111_11111_11111_11111_11111_11111_11111_11111_11111_11111_11111_01101_11010
        )
    }

    // MARK: Past 64 bits

    func testInitOnBitRange_range_past64Bits() {
        let sut = Bitmask64(onBitRange: 32..<80)

        assertEqual(
            sut,
            value: [0b1111_11111_11111_11111_11111_11111_11100_00000_00000_00000_00000_00000_00000, 0b1_11111_11111_11111]
        )
    }

    func testInitOnBitRange_closedRange_past64Bits() {
        let sut = Bitmask64(onBitRange: 32...80)

        assertEqual(
            sut,
            value: [0b1111_11111_11111_11111_11111_11111_11100_00000_00000_00000_00000_00000_00000, 0b11_11111_11111_11111]
        )
    }
    
    func testInitWithBits_past64Bits() {
        let sut = Bitmask64(bits: [0b01011, 0b11001_0000])

        assertEqual(
            sut,
            value: [0b01011, 0b11001_0000]
        )
    }

    func testInitWithBitmask_64BitsInto8Bits() throws {
        let sut = Bitmask64(bits: [
            0xDEADBEEFBADF00D0,
        ])
        
        let result = Bitmask8(sut)

        assertEqual(
            result,
            value: [
                0xD0,
                0x00,
                0xDF,
                0xBA,
                0xEF,
                0xBE,
                0xAD,
                0xDE,
            ]
        )
    }

    func testInitWithBitmask_8BitsInto64Bits() throws {
        let sut = Bitmask8(bits: [
            0xD0,
            0x00,
            0xDF,
            0xBA,
            0xEF,
            0xBE,
            0xAD,
            0xDE,
        ])
        
        let result = Bitmask64(sut)

        assertEqual(
            result,
            value: [
                0xDEADBEEFBADF00D0,
            ]
        )
    }

    func testInitWithBitmask_8BitsInto64Bits_partial() throws {
        let sut = Bitmask8(bits: [
            0xD0,
            0x00,
            0xDF,
            0xBA,
            0xEF,
            0xBE,
            0xAD,
            0xDE,
            0xD0,
            0x00,
            0xDF,
            0xBA,
        ])
        
        let result = Bitmask64(sut)

        assertEqual(
            result,
            value: [
                0xDEADBEEFBADF00D0,
                0xBADF00D0,
            ]
        )
    }

    func testInitWithBitmask_8BitsInto64Bits_partial_small() throws {
        let sut = Bitmask8(bits: [
            0xD0,
            0x00,
            0xDF,
            0xBA,
        ])
        
        let result = Bitmask64(sut)

        assertEqual(
            result,
            value: [
                0xBADF00D0,
            ]
        )
    }

    func testInitWithBitmask_8BitsInto64Bits_empty() throws {
        let sut = Bitmask8()
        
        let result = Bitmask64(sut)

        assertEqual(
            result,
            value: [
                0b0,
            ]
        )
    }
    
    func testCodable() throws {
        let sut = Bitmask64(bits: [
            0xDEADBEEF,
            0xBADF00D,
            0xF00DBAD,
            0xABEEACEE,
            0xBADDCAFE,
            0xBEEFBABE,
            0xB0BBAC0FFEE,
            0x8BADF00D,
        ])
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let data = try encoder.encode(sut)
        let result = try decoder.decode(Bitmask64.self, from: data)

        XCTAssertEqual(result, sut)
    }

    func testStorageLength_past64Bits() {
        var sut = Bitmask64()
        sut.setBit(180, state: true)

        XCTAssertEqual(sut.storageLength, 3)
    }

    func testBitWidth_past64Bits() {
        var sut = Bitmask64()
        sut.setBit(180, state: true)

        XCTAssertEqual(sut.bitWidth, 192)
    }

    func testIsAllZeroes_past64Bits() {
        XCTAssertTrue(Bitmask64(bits: [0b0, 0b0]).isAllZeroes)
        XCTAssertFalse(Bitmask64(bits: [0b1011, 0b0]).isAllZeroes)
        XCTAssertFalse(Bitmask64(bits: [0b0, 0b1011]).isAllZeroes)
    }

    func testIsNonZero_past64Bits() {
        XCTAssertFalse(Bitmask64(bits: [0b0, 0b0]).isNonZero)
        XCTAssertTrue(Bitmask64(bits: [0b1011, 0b0]).isNonZero)
        XCTAssertTrue(Bitmask64(bits: [0b0, 0b1011]).isNonZero)
    }

    func testNonzeroBitCount_past64Bits() {
        XCTAssertEqual(Bitmask64(onBitRange: 32..<80).nonzeroBitCount, 48)
    }

    func testEquatable_past64Bits_unequalLengthStorage() {
        let bitmask1 = Bitmask64(bits: [
            0b10110,
            0b0,
            0b0,
        ])
        let bitmask2 = Bitmask64(bits: [
            0b10110,
        ])

        XCTAssertEqual(bitmask1, bitmask2)
    }

    func testHashable_past64Bits_unequalLengthStorage() {
        let bitmask1 = Bitmask64(bits: [
            0b10110,
            0b0,
            0b0,
        ])
        let bitmask2 = Bitmask64(bits: [
            0b10110,
        ])

        XCTAssertEqual(bitmask1.hashValue, bitmask2.hashValue)
    }

    func testCompact_pas64Bits() {
        var bitmask1 = Bitmask64(bits: [
            0b10110,
            0b0,
            0b1,
        ])
        var bitmask2 = Bitmask64(bits: [
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
        let bitmask1 = Bitmask64(bits: [
            0b10110,
            0b0,
            0b1,
        ])
        let bitmask2 = Bitmask64(bits: [
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
        var sut: Bitmask64 = 0b1001
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
        var sut: Bitmask64 = 0b01010_11001
        sut.setBit(190, state: true)
        
        XCTAssertFalse(sut.isBitRangeZero(offset: 0, count: 1))
        XCTAssertTrue(sut.isBitRangeZero(offset: 1, count: 2))
        XCTAssertTrue(sut.isBitRangeZero(offset: 10, count: 120))
        XCTAssertFalse(sut.isBitRangeZero(offset: 63, count: 128))
    }

    func testExtractBits_past64Bits_aligned() {
        let sut: Bitmask64 = Bitmask64(bits: [
            0b01010_11001,
            ~UInt64() ^ 0b11011_00000_11101,
        ])
        
        assertEqual(
            sut.extractBits(offset: 0),
            bits: 0b01010_11001
        )
        assertEqual(
            sut.extractBits(offset: 64),
            bits: ~UInt64() ^ 0b11011_00000_11101
        )
    }

    func testExtractBits_past64Bits_unaligned_by_1bit() {
        let bits0: UInt64 = 0b01010_11001 | (0b10101_010101 << 32)
        let bits1: UInt64 = UInt64.max
        let sut: Bitmask64 = Bitmask64(bits: [
            bits0,
            bits1,
        ])
        
        assertEqual(
            sut.extractBits(offset: 1),
            bits: (bits0 >> 1) | (bits1 << 63)
        )
    }

    func testExtractBits_past64Bits_unaligned_by_4bits() {
        let bits0: UInt64 = 0b01010_11001 | (0b10101_010101 << 32)
        let bits1: UInt64 = UInt64.max
        let sut: Bitmask64 = Bitmask64(bits: [
            bits0,
            bits1,
        ])
        
        assertEqual(
            sut.extractBits(offset: 4),
            bits: (bits0 >> 4) | (bits1 << 60)
        )
    }

    func testExtractBits_past64Bits_unaligned() {
        let bits0: UInt64 = 0b01010_11001 | (0b10101_010101 << 32)
        let bits1: UInt64 = ~UInt64() ^ 0b11011_00000_11101
        let sut: Bitmask64 = Bitmask64(bits: [
            bits0,
            bits1,
        ])
        
        assertEqual(
            sut.extractBits(offset: 32),
            bits: (bits0 >> 32) | (bits1 << 32)
        )
    }

    func testExtractBits_past64Bits_pastEnd() {
        let sut: Bitmask64 = 0b01010_11001
        
        assertEqual(
            sut.extractBits(offset: 128),
            bits: 0b0
        )
    }

    func testSetBits_past64Bits_aligned() {
        let bits: UInt64 = 0b01010_11001 | (0b10101_010101 << 32)
        var sut: Bitmask64 = Bitmask64()

        sut.setBits(offset: 0, bits: bits)
        sut.setBits(offset: 64, bits: bits)
        
        assertEqual(
            sut,
            value: [
                bits,
                bits,
            ]
        )
    }

    func testSetBits_past64Bits_unaligned() {
        let bits0: UInt64 = 0b01010_11001 | (0b10101_010101 << 32)
        let bits1: UInt64 = ~UInt64() ^ 0b11011_00000_11101
        let bits = (bits0 >> 32) | (bits1 << 32)
        var sut: Bitmask64 = Bitmask64()

        sut.setBits(offset: 24, bits: bits)
        
        XCTAssertEqual(sut.nonzeroBitCount, bits.nonzeroBitCount)
        assertEqual(
            sut,
            value: [
                bits << 24,
                bits >> 40,
            ]
        )
    }

    func testSetBits_past64Bits_negativeOffset() {
        let bits0: UInt64 = 0b01010_11001 | (0b10101_010101 << 32)
        let bits1: UInt64 = ~UInt64() ^ 0b11011_00000_11101
        let bits = (bits0 >> 32) | (bits1 << 32)
        var sut: Bitmask64 = Bitmask64()

        sut.setBits(offset: -24, bits: bits)
        
        assertEqual(
            sut,
            value: [
                bits >> 24,
            ]
        )
    }

    func testSetBits_past64Bits_negativeOffset_overwriting() {
        let bits0: UInt64 = 0b01010_11001 | (0b10101_010101 << 32)
        let bits1: UInt64 = ~UInt64() ^ 0b11011_00000_11101
        let bits = (bits0 >> 32) | (bits1 << 32)
        var sut: Bitmask64 = Bitmask64(bits: [
            ~UInt64()
        ])

        sut.setBits(offset: -24, bits: bits)
        
        assertEqual(
            sut,
            value: [
                0b1111_11111_11111_11111_11111_11111_11111_11111_11001_00111_11000_10000_00000,
            ]
        )
    }

    func testSetBit_past64Bits() {
        var sut: Bitmask64 = 0b110

        sut.setBit(64, state: true)
        sut.setBit(1, state: false)

        assertEqual(sut, value: [0b100, 0b1])
    }

    func testSetBitOn_past64Bits() {
        var sut: Bitmask64 = 0b100

        sut.setBitOn(64)
        sut.setBitOn(1)

        assertEqual(sut, value: [0b110, 0b1])
    }

    func testSetBitOff_past64Bits_past64Bits() {
        var sut: Bitmask64 = 0b101

        sut.setBitOff(64)
        sut.setBitOff(2)

        assertEqual(sut, value: [0b001, 0b0])
    }

    func testSetBitRangeOffsetCount_true_past64Bits() {
        var sut: Bitmask64 = 0b10010_00101

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
        var sut: Bitmask64 = 0b10010_00101

        sut.setBitRange(offset: 8, count: 64, state: false)

        assertEqual(sut, value: [0b00010_00101, 0b0])
    }

    func testSetBitRange_range_true_past64Bits() {
        var sut: Bitmask64 = 0b10010_00101

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
        var sut: Bitmask64 = 0b10010_00101

        sut.setBitRange(8..<72, state: false)

        assertEqual(sut, value: [0b00010_00101, 0b0])
    }

    func testSetBitRange_closedRange_true_past64Bits() {
        var sut: Bitmask64 = 0b10010_00101

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
        var sut: Bitmask64 = 0b10010_00101

        sut.setBitRange(8...72, state: false)

        assertEqual(sut, value: [0b00010_00101, 0b0])
    }

    func testSetAllBits_true_past64Bits() {
        var sut: Bitmask64 = Bitmask64(onBitRange: 32...80)

        sut.setAllBits(state: true)

        assertEqual(sut, value: [UInt64.max, UInt64.max])
    }

    func testSetAllBits_false_past64Bits() {
        var sut: Bitmask64 = Bitmask64(onBitRange: 32...80)

        sut.setAllBits(state: false)

        assertEqual(sut, value: [0b0, 0b0])
    }

    func testShiftingBitsLeft_past64Bits() {
        let sut: Bitmask64 = 0b10000_10001

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
        var sut: Bitmask64 = 0b10000_10001

        sut.shiftBitsLeft(count: 59)

        assertEqual(
            sut,
            value: [
                0b1000_10000_00000_00000_00000_00000_00000_00000_00000_00000_00000_00000_00000,
                0b10000,
            ]
        )
    }

    func testShiftBitsLeft_past64Bits_64BitMultiple() {
        var sut: Bitmask64 = 0b10000_10001

        sut.shiftBitsLeft(count: 192)

        assertEqual(
            sut,
            value: [
                0b0,
                0b0,
                0b0,
                0b10000_10001,
            ]
        )
    }

    func testShiftingBitsRight_past64Bits() {
        let sut: Bitmask64 = Bitmask64(bits: [
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
        var sut: Bitmask64 = Bitmask64(bits: [
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

    func testShiftBitsRight_past64Bits_64BitMultiple() {
        var sut: Bitmask64 = Bitmask64(bits: [
            0b0,
            0b0,
            0b0,
            0b10000_10001,
        ])

        sut.shiftBitsRight(count: 192)

        assertEqual(
            sut,
            value: [
                0b10000_10001,
            ]
        )
    }

    func testWithStorage_past64Bits() {
        var sut: Bitmask64 = 0b10010_00101
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
        let sut = Bitmask64(bits: [
            0b11101_00011_10000_11110_00000_00111_11110,
            0b11110_01001_00101_00100_11101_11110_00111,
        ])
        var indices: [Int] = []

        sut.forEachOnBitIndex { index in
            indices.append(index)            
        }

        XCTAssertEqual(indices, [
            1, 2, 3, 4, 5, 6, 7, 16, 17, 18, 19, 24, 25, 26, 30, 32, 33, 34, 64,
            65, 66, 70, 71, 72, 73, 74, 76, 77, 78, 81, 84, 86, 89, 92, 95, 96,
            97, 98,
        ])
    }

    func testForEachOnBitIndex_copyBitmasks_past64Bits() {
        let sut = Bitmask64(bits: [
            0b11101_00011_10000_11110_00000_00111_11110,
            0b11110_01001_00101_00100_11101_11110_00111,
        ])
        var copy = Bitmask64()

        sut.forEachOnBitIndex { index in
            copy.setBitOn(index)
        }

        XCTAssertEqual(sut, copy)
    }

    func testAndOperator_past64Bits() {
        let bitmask1 = Bitmask64(bits: [0b10010_00101, 0b00101_10010])
        let bitmask2 = Bitmask64(bits: [0b01010_11001, 0b11001_01010])

        let result = bitmask1 & bitmask2

        assertEqual(result, value: [0b00010_00001, 0b0001_00010])
    }

    func testAndOperator_inPlace_past64Bits() {
        var bitmask1 = Bitmask64(bits: [0b10010_00101, 0b00101_10010])
        let bitmask2 = Bitmask64(bits: [0b01010_11001, 0b11001_01010])

        bitmask1 &= bitmask2

        assertEqual(bitmask1, value: [0b00010_00001, 0b0001_00010])
    }

    func testOrOperator_past64Bits() {
        let bitmask1 = Bitmask64(bits: [0b10010_00101, 0b00101_10010])
        let bitmask2 = Bitmask64(bits: [0b01010_11001, 0b11001_01010])

        let result = bitmask1 | bitmask2

        assertEqual(result, value: [0b11010_11101, 0b11101_11010])
    }

    func testOrOperator_inPlace_past64Bits() {
        var bitmask1 = Bitmask64(bits: [0b10010_00101, 0b00101_10010])
        let bitmask2 = Bitmask64(bits: [0b01010_11001, 0b11001_01010])

        bitmask1 |= bitmask2

        assertEqual(bitmask1, value: [0b11010_11101, 0b11101_11010])
    }

    func testXOrOperator_past64Bits() {
        let bitmask1 = Bitmask64(bits: [0b10010_00101, 0b00101_10010])
        let bitmask2 = Bitmask64(bits: [0b01010_11001, 0b11001_01010])

        let result = bitmask1 ^ bitmask2

        assertEqual(result, value: [0b11000_11100, 0b11100_11000])
    }

    func testXOrOperator_past64Bits_unequalLength() {
        let bitmask1 = Bitmask64(bits: [0b10010_00101, 0b00101_10010, 0b10010_00101])
        let bitmask2 = Bitmask64(bits: [0b01010_11001, 0b11001_01010])

        let result = bitmask1 ^ bitmask2

        assertEqual(result, value: [0b11000_11100, 0b11100_11000, 0b10010_00101])
    }

    func testXOrOperator_past64Bits_unequalLength_singleAndArray() {
        let bitmask1 = Bitmask64(bits: [0b10010_00101, 0b00101_10010, 0b10010_00101])
        let bitmask2 = Bitmask64(bits: [0b01010_11001])

        assertEqual(bitmask1 ^ bitmask2, value: [0b11000_11100, 0b00101_10010, 0b10010_00101])
        assertEqual(bitmask2 ^ bitmask1, value: [0b11000_11100, 0b00101_10010, 0b10010_00101])
    }

    func testXOrOperator_inPlace_past64Bits() {
        var bitmask1 = Bitmask64(bits: [0b10010_00101, 0b00101_10010])
        let bitmask2 = Bitmask64(bits: [0b01010_11001, 0b11001_01010])

        bitmask1 ^= bitmask2

        assertEqual(bitmask1, value: [0b11000_11100, 0b11100_11000])
    }

    func testNegateOperator_past64Bits() {
        let bitmask = Bitmask64(bits: [0b10010_00101, 0b00101_10010])

        let result = ~bitmask

        assertEqual(
            result,
            value: [
                0b1111_11111_11111_11111_11111_11111_11111_11111_11111_11111_11111_01101_11010,
                0b1111_11111_11111_11111_11111_11111_11111_11111_11111_11111_11111_11010_01101,
            ]
        )
    }

    func testXorSwap() {
        let bitmask1 = Bitmask64(bits: [
            0xBADF00D,
            0xF00DBAD,
        ])
        let bitmask2 = Bitmask64(bits: [
            0x1234567,
            0xAABBCC,
        ])

        var bit1 = bitmask1
        var bit2 = bitmask2

        bit1 = bit1 ^ bit2
        bit2 = bit2 ^ bit1
        bit1 = bit1 ^ bit2

        assertEqual(bit2, bitmask: bitmask1)
        assertEqual(bit1, bitmask: bitmask2)
    }

    func testXorSwap_unequalLength() {
        let bitmask1 = Bitmask64(bits: [
            0xBADF00D,
            0xF00DBAD,
        ])
        let bitmask2 = Bitmask64(bits: [
            0x1234567,
        ])

        var bit1 = bitmask1
        var bit2 = bitmask2

        bit1 = bit1 ^ bit2
        bit2 = bit2 ^ bit1
        bit1 = bit1 ^ bit2

        assertEqual(bit2, bitmask: bitmask1)
        assertEqual(bit1, bitmask: bitmask2)
    }

    func testWithContiguousStorageIfAvailable_past64Bits() {
        let sut = Bitmask64(bits: [
            0xBADF00D,
            0xF00DBAD,
        ])

        let result = sut._storage.withContiguousStorageIfAvailable { ptr -> Bool in
            XCTAssertEqual(ptr.count, 2)

            assertEqual(ptr[0], bits: 0xBADF00D)
            assertEqual(ptr[1], bits: 0xF00DBAD)

            return true
        }

        XCTAssertEqual(result, true)
    }
    
    func testPerformance_64BitsTo8BitsBitmask() {
        measure {
            let sut = Bitmask64(bits: [
                0xDEADBEEFBADF00D0,
            ])

            let iterations = 10_000

            for _ in 0..<iterations {
                let _ = Bitmask8(sut)
            }
        }
    }

    func testPerformance_8BitsTo64BitsBitmask() {
        measure {
            let sut = Bitmask8(bits: [
                0xD0,
                0x00,
                0xDF,
                0xBA,
                0xEF,
                0xBE,
                0xAD,
                0xDE,
            ])

            let iterations = 10_000

            for _ in 0..<iterations {
                let _ = Bitmask64(sut)
            }
        }
    }

    func testPerformance_8BitsTo64BitsBitmask_partial() {
        measure {
            let sut = Bitmask8(bits: [
                0xD0,
                0x00,
                0xDF,
                0xBA,
                0xEF,
                0xBE,
                0xAD,
                0xDE,
                0xD0,
                0x00,
                0xDF,
                0xBA,
            ])

            let iterations = 10_000

            for _ in 0..<iterations {
                let _ = Bitmask64(sut)
            }
        }
    }

    func testPerformance_setBitRange() {
        measure {
            let iterations = 10_000

            for _ in 0..<iterations {
                var sut: Bitmask64 = 0b10010_00101

                sut.setBitRange(0...1024, state: true)
            }
        }
    }

    func testPerformance_xorSwap() {
        measure {
            let bitmask1 = Bitmask64(bits: [
                0xDEADBEEF,
                0xBADF00D,
                0xF00DBAD,
                0xABEEACEE,
                0xBADDCAFE,
                0xBEEFBABE,
                0xB0BBAC0FFEE,
                0x8BADF00D,
            ])
            let bitmask2 = Bitmask64(bits: [
                0x1234567890,
                0x9876543210,
                0xAABBCCDDEE,
                0xEEDDCCBBAA,
                0x0A1B2C3D4E,
                0x4E3D2C1B0A,
                0x1122334455,
                0x5544332211,
            ])

            let iterations = 100_000

            for _ in 0..<iterations {
                var bit1 = bitmask1
                var bit2 = bitmask2

                bit1 ^= bit2
                bit2 ^= bit1
                bit1 ^= bit2
            }
        }
    }

    func testPerformance_xorSwap_unequalLength_singleAndArray() {
        measure {
            let bitmask1 = Bitmask64(bits: [
                0xDEADBEEF,
                0xBADF00D,
                0xF00DBAD,
                0xABEEACEE,
                0xBADDCAFE,
                0xBEEFBABE,
                0xB0BBAC0FFEE,
                0x8BADF00D,
            ])
            let bitmask2 = Bitmask64(bits: [
                0x1234567890,
            ])

            let iterations = 100_000

            for _ in 0..<iterations {
                var bit1 = bitmask1
                var bit2 = bitmask2

                bit1 ^= bit2
                bit2 ^= bit1
                bit1 ^= bit2
            }
        }
    }

    func testPerformance_xorSwap_unequalLength_arrayAndArray() {
        measure {
            let bitmask1 = Bitmask64(bits: [
                0xDEADBEEF,
                0xBADF00D,
                0xF00DBAD,
                0xABEEACEE,
                0xBADDCAFE,
                0xBEEFBABE,
                0xB0BBAC0FFEE,
                0x8BADF00D,
            ])
            let bitmask2 = Bitmask64(bits: [
                0x1234567890,
                0x9876543210,
            ])

            let iterations = 100_000

            for _ in 0..<iterations {
                var bit1 = bitmask1
                var bit2 = bitmask2

                bit1 ^= bit2
                bit2 ^= bit1
                bit1 ^= bit2
            }
        }
    }

    func testPerformance_bitwiseShiftLeftXOrOr_past64Bits() {
        measure {
            var bitmask = Bitmask64()
            let fixedMask: Bitmask64 = 0b10101

            let iterations = 10_000

            for index in 0..<iterations {
                let mask = Bitmask64(bits: [
                    0b1111_11111_11111_11111_11111_11111_11111_11111_11111_11111_11111_01101_11010,
                    0b1111_11111_11111_11111_11111_11111_01101_11101_11111_11111_11111_11111_10110,
                ])

                bitmask = bitmask | (fixedMask ^ mask.shiftingBitsLeft(count: index))
            }
        }
    }

    // MARK: - Test utils

    private func assertEqual<Storage>(_ actual: Bitmask<Storage>, bitmask: Bitmask<Storage>, line: UInt = #line) {
        let storage1 = extractStorage(actual)
        let storage2 = extractStorage(bitmask)

        XCTAssertEqual(
            actual,
            bitmask,
            "\(formatStorage(storage1)) != \(formatStorage(storage2))",
            line: line
        )
    }

    private func assertEqual<Storage>(_ bitmask: Bitmask<Storage>, value: [Storage], line: UInt = #line) {
        let storage = extractStorage(bitmask)

        XCTAssertEqual(
            storage,
            value,
            "\(formatStorage(storage)) != \(formatStorage(value))",
            line: line
        )
    }

    private func assertEqual<Storage>(_ bitmask: Bitmask<Storage>, value: Storage, line: UInt = #line) {
        let storage = extractStorage(bitmask)
        let expected = [value]

        XCTAssertEqual(
            storage,
            expected,
            "\(formatStorage(storage)) != \(formatStorage(expected))",
            line: line
        )
    }

    private func assertEqual<Storage: FixedWidthInteger>(_ actual: Storage, bits: Storage, line: UInt = #line) {
        let storage = [actual]
        let expected = [bits]

        XCTAssertEqual(
            actual,
            bits,
            "\(formatStorage(storage)) != \(formatStorage(expected))",
            line: line
        )
    }

    private func extractStorage<Storage>(_ bitmask: Bitmask<Storage>) -> [Storage] {
        var result: [Storage] = []

        bitmask.withStorage {
            result.append($0)
        }

        return result
    }

    private func formatStorage<Storage: FixedWidthInteger>(_ storage: [Storage], separator: Int = 8) -> String {
        var result: [String] = []

        for binary in storage {
            var binaryString = String(binary, radix: 2)

            // Underscore every five digits
            binaryString = String(binaryString.reversed())

            for sep in stride(from: 0, to: binaryString.count, by: separator).dropFirst().reversed() {
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
