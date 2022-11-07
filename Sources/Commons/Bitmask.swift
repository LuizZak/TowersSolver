/// A type used to describe bitmasks for quick, compact querying of boolean states.
public struct Bitmask {
    @usableFromInline
    typealias Storage = UInt64

    /// Main bitmask with the initial 64 bits of this bitmask.
    @usableFromInline
    var _storage: Storage

    /// List of UInt64 past the initial 64 bits.
    @usableFromInline
    var _remaining: [Storage]

    @usableFromInline
    subscript(bitIndex bitIndex: Int) -> UInt64 {
        get {
            let storageIndex = storageIndex(for: bitIndex)
            return self[storageIndex: storageIndex]
        }
        set {
            let storageIndex = storageIndex(for: bitIndex)
            self[storageIndex: storageIndex] = newValue
        }
    }

    /// Indexes using 0-based storage index. 0 index into `self._storage`, while
    /// indices 1 or greater index into `_remaining` array with a -1 offset.
    @usableFromInline
    subscript(storageIndex storageIndex: Int) -> UInt64 {
        get {
            guard storageIndex > 0 else {
                return _storage
            }

            return _remaining[storageIndex - 1]
        }
        set {
            if storageIndex == 0 {
                _storage = newValue
            } else {
                _remaining[storageIndex - 1] = newValue
            }
        }
    }

    /// The number of bits available on this type.
    @inlinable
    public var bitWidth: Int {
        Storage.bitWidth + _remaining.count * Storage.bitWidth
    }

    /// Returns the length of the storage for this bitmask, as in the number of
    /// individual 64-bit numbers in the backing storage.
    ///
    /// When calling `withStorage`, the closure will be called `storageLength`
    /// times with the individual 64-bit numbers.
    @inlinable
    public var storageLength: Int {
        1 + _remaining.count
    }

    /// Returns whether all bits in this bitmask are zero.
    @inlinable
    public var isAllZeroes: Bool {
        var result = true

        withStorage { value in
            result = result && value == 0
        }

        return result
    }

    /// Returns whether any bit in this bitmask is not a zero.
    @inlinable
    public var isNonZero: Bool {
        !isAllZeroes
    }

    /// The number of bits in this bitmask that are on.
    @inlinable
    public var nonzeroBitCount: Int {
        var result: Int = 0

        withStorage { value in
            result += value.nonzeroBitCount
        }

        return result
    }

    /// Initializes a zeroed-out bitmask value.
    @inlinable
    public init() {
        self._storage = 0
        self._remaining = []
    }

    @usableFromInline
    internal init(_storage: Bitmask.Storage, _remaining: [Storage]) {
        self._storage = _storage
        self._remaining = _remaining
    }

    @usableFromInline
    mutating func ensureBitCount(_ count: Int) {
        let storageIndex = storageIndex(for: count)
        guard storageIndex > 0 else {
            return
        }

        let extraStorage = storageIndex - _remaining.count

        if extraStorage > 0 {
            _remaining.append(contentsOf: [Storage](repeating: 0, count: extraStorage))
        }
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

    /// Initializes a new bitmask with a specified list of UInt64 bits sequences.
    @inlinable
    public init(bits: [UInt64]) {
        self.init()

        guard !bits.isEmpty else {
            return
        }

        self._storage = bits[0]
        self._remaining = Array(bits.dropFirst())
    }

    @inlinable
    func storageIndex(for bitIndex: Int) -> Int {
        bitIndex / Storage.bitWidth
    }

    @inlinable
    func withStorageRange(
        start: Int,
        count: Int,
        _ closure: (Storage, _ start: Int, _ count: Int) throws -> Void
    ) rethrows {
        let startStorage = storageIndex(for: start)
        let endStorage = storageIndex(for: start + count)

        if startStorage == 0 && startStorage == endStorage {
            try closure(_storage, start, count)
            return
        }

        let finalBitOffset = (start + count) % Storage.bitWidth
        for index in startStorage...endStorage {
            let startBit = index > startStorage ? 0 : start % Storage.bitWidth
            let endBit = index < endStorage ? Storage.bitWidth : finalBitOffset

            try closure(self[storageIndex: index], startBit, endBit - startBit)
        }
    }

    @inlinable
    mutating func withMutableStorageRange(
        start: Int,
        count: Int,
        _ closure: (inout Storage, _ start: Int, _ count: Int) throws -> Void
    ) rethrows {
        let startStorage = storageIndex(for: start)
        let endStorage = storageIndex(for: start + count)

        if startStorage == 0 && startStorage == endStorage {
            try closure(&_storage, start, count)
            return
        }

        let finalBitOffset = (start + count) % Storage.bitWidth
        for index in startStorage...endStorage {
            let startBit = index > startStorage ? 0 : start
            let endBit = index < endStorage ? Storage.bitWidth : finalBitOffset

            try closure(&self[storageIndex: index], startBit, endBit - startBit)
        }
    }

    /// Returns whether a bit on a given index is set within this bitmask.
    ///
    /// - precondition: `index >= 0`.
    @inlinable
    public func isBitSet(_ index: Int) -> Bool {
        let modBit = index % Storage.bitWidth
        let mask: Storage = 0b1 << modBit

        return (self[bitIndex: index] & mask) != 0
    }

    /// Returns whether all bits on a given range are off within this bitmask.
    @inlinable
    public func isBitRangeZero(offset: Int, count: Int) -> Bool {
        var result = true

        withStorageRange(start: offset, count: count) { (bits, start, count) in
            var mask: UInt64 = ~0 >> (Storage.bitWidth - count)
            mask = mask << Storage(start)

            result = result && (bits & mask) == 0
        }

        return result
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
        ensureBitCount(index)

        let modBit = index % Storage.bitWidth
        let mask: Storage = 0b1 << modBit

        self[bitIndex: index] |= mask
    }

    /// Sets a specific bit off within this bitmask.
    ///
    /// - precondition: `index >= 0`.
    @inlinable
    public mutating func setBitOff(_ index: Int) {
        ensureBitCount(index)
        
        let modBit = index % Storage.bitWidth
        let mask: Storage = 0b1 << modBit

        self[bitIndex: index] &= ~mask
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
        ensureBitCount(offset + count)

        withMutableStorageRange(start: offset, count: count) { (bits, offset, count) in
            var mask: UInt64 = ~0 >> (Storage.bitWidth - count)
            mask = mask << Storage(offset)
            
            if state {
                bits |= mask
            } else {
                bits &= ~mask
            }
        }
    }

    /// Sets all the bits available on this bitmask to a specified state.
    ///
    /// The total number of bits set is always `64 * self.storageLength`
    @inlinable
    public mutating func setAllBits(state: Bool) {
        if state {
            _storage = ~0
            _remaining = _remaining.map { _ in ~0 }
        } else {
            _storage = 0
            _remaining = _remaining.map { _ in 0 }
        }
    }

    /// Returns a copy of this bitmask where the storage is the minimal count of
    /// `UInt64` bits capable of representing the on bits on this bitmask.
    @inlinable
    public func compacted() -> Self {
        var copy = self
        copy.compact()
        return copy
    }

    /// Reduces the storage elements of this bitmask to be the minimal count of
    /// `UInt64` bits capable of representing the on bits on this bitmask.
    @inlinable
    public mutating func compact() {
        if let lastNonZero = _remaining.lastIndex(where: { $0 != 0 }) {
            _remaining = Array(_remaining.prefix(through: lastNonZero))
        } else {
            _remaining = []
        }
    }

    /// Exposes the storage of this bitmask with a given closure, invoking it
    /// in sequence from the earliest bit indices to the latest, packing the
    /// boolean states into sequences of 64 bits in `UInt64` values.
    @inlinable
    public func withStorage(_ closure: (UInt64) throws -> Void) rethrows {
        try closure(_storage)

        for entry in _remaining {
            try closure(entry)
        }
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

extension Bitmask: Equatable {
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        let lhs = lhs.compacted()
        let rhs = rhs.compacted()

        return lhs._storage == rhs._storage && lhs._remaining == rhs._remaining
    }
}

extension Bitmask: Hashable {
    @inlinable
    public func hash(into hasher: inout Hasher) {
        let value = compacted()

        hasher.combine(value._storage)
        for rem in value._remaining {
            hasher.combine(rem)
        }
    }
}

extension Bitmask: Decodable {
    /// Decodes a bitmask from a given decoder.
    ///
    /// Accepted values:
    /// - `UInt64` single value containers.
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        guard let count = container.count else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: [], debugDescription: "Expected proper collection of \(Storage.self) values")
            )
        }
        
        _storage = 0
        _remaining = []

        self.ensureBitCount(count * Storage.bitWidth)

        for index in 0..<count {
            self[storageIndex: index] = try container.decode(Storage.self)
        }
    }
}

extension Bitmask: Encodable {
    /// Encodes this bitmask into a given encoder.
    ///
    /// Possible outputs of encoding:
    /// - `UInt64` single value container.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()

        for index in 0..<storageLength {
            try container.encode(self[storageIndex: index])
        }
    }
}

extension Bitmask: ExpressibleByIntegerLiteral {
    @inlinable
    public init(integerLiteral value: UInt64) {
        self._storage = value
        self._remaining = []
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
        let maxStorage = max(lhs._remaining.count, rhs._remaining.count)
        let lhsIndexer = _StorageIndexer(bitmask: lhs)
        let rhsIndexer = _StorageIndexer(bitmask: rhs)

        var result = Bitmask()
        result.ensureBitCount(Storage.bitWidth * maxStorage)

        for index in 0...maxStorage {
            result[storageIndex: index] = op(lhsIndexer[index], rhsIndexer[index])
        }

        return result
    }

    @inlinable
    static internal func _unaryOp(
        _ value: Self,
        op: (Storage) -> Storage
    ) -> Self {
        return Bitmask(
            _storage: op(value._storage),
            _remaining: value._remaining.map(op)
        )
    }

    @usableFromInline
    internal struct _StorageIndexer: Collection {
        @usableFromInline
        let bitmask: Bitmask

        @usableFromInline
        let startIndex: Int = 0
        @usableFromInline
        let endIndex: Int = Int.max
        
        @usableFromInline
        subscript(position: Int) -> Bitmask.Storage {
            if position > bitmask.storageLength {
                return 0
            }

            return bitmask[storageIndex: position]
        }

        @usableFromInline
        init(bitmask: Bitmask) {
            self.bitmask = bitmask
        }

        @usableFromInline
        func index(after i: Int) -> Int {
            i + 1
        }
    }
}
