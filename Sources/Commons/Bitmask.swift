/// A type used to describe bitmasks for quick, compact querying of boolean states.
public struct Bitmask: Hashable {
    @usableFromInline
    typealias Storage = UInt64

    @usableFromInline
    var _storage: Storage

    /// The number of bits available on this type.
    @inlinable
    public var bitWidth: Int {
        _storage.bitWidth
    }

    /// Returns the length of the storage for this bitmask, as in the number of
    /// individual 64-bit numbers in the backing storage.
    ///
    /// When calling `withStorage`, the closure will be called `storageLength`
    /// times with the individual 64-bit numbers.
    @inlinable
    public var storageLength: Int {
        return 1
    }

    /// Returns whether all bits in this bitmask are zero.
    @inlinable
    public var isAllZeroes: Bool {
        _storage == 0
    }

    /// Returns whether any bit in this bitmask is not a zero.
    @inlinable
    public var isNonZero: Bool {
        _storage != 0
    }

    /// The number of bits in this bitmask that are on.
    @inlinable
    public var nonzeroBitCount: Int {
        _storage.nonzeroBitCount
    }

    /// Initializes a zeroed-out bitmask value.
    @inlinable
    public init() {
        self._storage = 0
    }

    @usableFromInline
    internal init(_storage: Bitmask.Storage) {
        self._storage = _storage
    }

    /// Initializes a new bitmask with a specified bit range on.
    @inlinable
    public init(onBitRange: Range<Int>) {
        self.init()

        setBitRange(onBitRange, state: true)
    }

    /// Initializes a new bitmask with a specified bit range on.
    @inlinable
    public init(onBitRange: ClosedRange<Int>) {
        self.init()

        setBitRange(onBitRange, state: true)
    }

    /// Returns whether a bit on a given index is set within this bitmask.
    ///
    /// - precondition: `index >= 0`.
    @inlinable
    public func isBitSet(_ index: Int) -> Bool {
        let mask: Storage = 0b1 << index

        return (_storage & mask) != 0
    }

    /// Returns whether all bits on a given range are off within this bitmask.
    @inlinable
    public func isBitRangeZero(offset: Int, count: Int) -> Bool {
        var mask: UInt64 = ~0 >> (Storage.bitWidth - count)
        mask = mask << Storage(offset)

        return (_storage & mask) == 0
    }

    /// Changes the state of a specific bit on this bitmask.
    ///
    /// - precondition: `index >= 0`.
    @inlinable
    public mutating func setBit(_ index: Int, state: Bool) {
        if state {
            setBitOn(index)
        } else {
            setBitOff(index)
        }
    }

    /// Sets a specific bit on within this bitmask.
    ///
    /// - precondition: `index >= 0`.
    @inlinable
    public mutating func setBitOn(_ index: Int) {
        let mask: Storage = 0b1 << index

        _storage = _storage | mask
    }

    /// Sets a specific bit off within this bitmask.
    ///
    /// - precondition: `index >= 0`.
    @inlinable
    public mutating func setBitOff(_ index: Int) {
        let mask: Storage = 0b1 << index

        _storage = _storage & ~mask
    }

    /// Sets a range of bits in this bitmask to a specified state.
    @inlinable
    public mutating func setBitRange(_ range: Range<Int>, state: Bool) {
        setBitRange(offset: range.lowerBound, count: range.count, state: state)
    }

    /// Sets a range of bits in this bitmask to a specified state.
    @inlinable
    public mutating func setBitRange(_ range: ClosedRange<Int>, state: Bool) {
        setBitRange(offset: range.lowerBound, count: range.count, state: state)
    }

    /// Sets a range of bits in this bitmask to a specified state.
    @inlinable
    public mutating func setBitRange(offset: Int, count: Int, state: Bool) {
        var mask: UInt64 = ~0 >> (Storage.bitWidth - count)
        mask = mask << Storage(offset)
        
        if state {
            _storage |= mask
        } else {
            _storage &= ~mask
        }
    }

    /// Sets all the bits available on this bitmask to a specified state.
    ///
    /// The total number of bits set is always `64 * self.storageLength`
    @inlinable
    public mutating func setAllBits(state: Bool) {
        if state {
            _storage = ~0
        } else {
            _storage = 0
        }
    }

    /// Exposes the storage of this bitmask with a given closure, invoking it
    /// in sequence from the earliest bit indices to the latest, packing the
    /// boolean states into sequences of 64 bits in `UInt64` values.
    @inlinable
    public func withStorage<T>(_ closure: (UInt64) throws -> T) rethrows -> T {
        try closure(_storage)
    }

    /// Invokes a given closure for every bit index in this bitmask that are set
    /// on, from the lowest bit index to the largest.
    @inlinable
    public func forEachOnBitIndex(_ closure: (Int) throws -> Void) rethrows {
        var totalLength: Int = 0

        try withStorage { bitmask in
            for i in 0..<bitmask.bitWidth {
                if (bitmask >> i) & 0b1 == 0b1 {
                    try closure(totalLength + i)
                }
            }

            totalLength += bitmask.bitWidth
        }
    }
}

extension Bitmask: Decodable {
    /// Decodes a bitmask from a given decoder.
    ///
    /// Accepted values:
    /// - `UInt64` single value containers.
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        _storage = try container.decode(Storage.self)
    }
}

extension Bitmask: Encodable {
    /// Encodes this bitmask into a given encoder.
    ///
    /// Possible outputs of encoding:
    /// - `UInt64` single value container.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        try container.encode(_storage)
    }
}

extension Bitmask: ExpressibleByIntegerLiteral {
    @inlinable
    public init(integerLiteral value: UInt64) {
        self._storage = value
    }
}

public extension Bitmask {
    /// Returns the union of two bitmasks.
    @inlinable
    static func | (lhs: Self, rhs: Self) -> Self {
        _binaryOp(lhs, rhs, op: |)
    }

    /// Returns the intersection of two bitmasks.
    @inlinable
    static func & (lhs: Self, rhs: Self) -> Self {
        _binaryOp(lhs, rhs, op: &)
    }

    /// Returns the xor of two bitmasks.
    @inlinable
    static func ^ (lhs: Self, rhs: Self) -> Self {
        _binaryOp(lhs, rhs, op: ^)
    }

    /// Returns the inverse of a bitmask.
    @inlinable
    static prefix func ~ (value: Self) -> Self {
        _unaryOp(value, op: ~)
    }

    @inlinable
    static internal func _binaryOp(
        _ lhs: Self,
        _ rhs: Self,
        op: (Storage, Storage) -> Storage
    ) -> Self {

        Bitmask(_storage: op(lhs._storage, rhs._storage))
    }

    @inlinable
    static internal func _unaryOp(
        _ value: Self,
        op: (Storage) -> Storage
    ) -> Self {

        Bitmask(_storage: op(value._storage))
    }
}
