/// A bitmask with 8 bits of contiguous storage.
public typealias Bitmask8 = Bitmask<UInt8>

/// A bitmask with 16 bits of contiguous storage.
public typealias Bitmask16 = Bitmask<UInt16>

/// A bitmask with 32 bits of contiguous storage.
public typealias Bitmask32 = Bitmask<UInt32>

/// A bitmask with 64 bits of contiguous storage.
public typealias Bitmask64 = Bitmask<UInt64>

/// A type used to describe runs of bits for quick, compact querying of boolean
/// states, using a specified fixed-width integer type for the backing storage.
public struct Bitmask<Storage: FixedWidthInteger> {
    /// Main bitmask with the initial `Storage.bitWidth` bits of this bitmask
    /// along with a trailing array of `Storage` values, if storage is larger
    /// than one value long.
    @usableFromInline
    var _storage: _Storage

    @usableFromInline
    subscript(bitIndex bitIndex: Int) -> Storage {
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
    subscript(storageIndex storageIndex: Int) -> Storage {
        get {
            _storage[storageIndex]
        }
        set {
            _storage[storageIndex] = newValue
        }
    }

    /// Indexes using 0-based storage index. 0 index into `self._storage`, while
    /// indices 1 or greater index into `_remaining` array with a -1 offset
    /// 
    /// Indices past `self.storageLength` result in a return value of `0`.
    @usableFromInline
    subscript(safeStorageIndex storageIndex: Int) -> Storage {
        get {
            if storageIndex >= storageLength {
                return 0
            }

            return _storage[storageIndex]
        }
    }

    /// The number of bits available on this type.
    @inlinable
    public var bitWidth: Int {
        _storage.count * Storage.bitWidth
    }

    /// Returns the length of the storage for this bitmask, as in the number of
    /// individual `Storage.bitWidth` numbers in the backing storage.
    ///
    /// When calling `withStorage`, the closure will be called `storageLength`
    /// times with the individual `Storage.bitWidth` numbers.
    @inlinable
    public var storageLength: Int {
        _storage.count
    }

    /// Returns whether all bits in this bitmask are zero.
    @inlinable
    public var isAllZeroes: Bool {
        for index in 0..<storageLength {
            if self[storageIndex: index] != 0 {
                return false
            }
        }

        return true
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
        self._storage = .single(0)
    }

    @usableFromInline
    internal init(_lead: Storage, _remaining: [Storage]) {
        self._storage = .multiple(_lead, _remaining)
    }

    @usableFromInline
    internal init(_storage: _Storage) {
        self._storage = _storage
    }

    @usableFromInline
    mutating func ensureBitCount(_ count: Int) {
        let storageIndex = storageIndex(for: count) + 1
        
        _storage.ensureCapacity(count: storageIndex)
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

    /// Initializes a new bitmask with a specified list of `Storage` bits sequences.
    @inlinable
    public init(bits: [Storage]) {
        self.init()

        guard !bits.isEmpty else {
            return
        }

        self._storage = .multiple(bits[0], Array(bits.dropFirst()))
    }

    /// Initializes this bitmask object by extracting all of the bits from a given
    /// bitmask object of arbitrary bit count.
    @inlinable
    public init<T>(_ bitmask: Bitmask<T>) {
        self.init()

        if Storage.bitWidth < T.bitWidth {
            for bitIndex in stride(from: 0, to: bitmask.bitWidth, by: Storage.bitWidth) {
                let bits = bitmask.extractBits(offset: bitIndex)

                let cast = Storage(truncatingIfNeeded: bits)

                setBits(offset: bitIndex, bits: cast)
            }
        } else {
            for (i, storage) in bitmask._storage.enumerated() {
                let cast = Storage(truncatingIfNeeded: storage)

                setBits(offset: i * T.bitWidth, bits: cast)
            }
        }

        compact()
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
            try closure(_storage[0], start, count)
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
            try closure(&_storage[0], start, count)
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
            var mask: Storage = ~0 >> (Storage.bitWidth - count)
            mask = mask << Storage(start)

            result = result && (bits & mask) == 0
        }

        return result
    }

    /// Extracts `Storage.bitWidth` of bits from the bitmask starting at the
    /// specified bit offset. Bits that are referenced beyond `self.bitWidth`
    /// are set to 0.
    public func extractBits(offset: Int) -> Storage {
        let bitStart = offset
        let bitEnd = offset + Storage.bitWidth

        let startIndex = storageIndex(for: bitStart)
        let endIndex = storageIndex(for: bitEnd)

        assert(
            endIndex <= startIndex + 1,
            "Expected \(Storage.bitWidth) bits of storage to span a maximum of two consecutive \(Storage.self) indices."
        )

        if startIndex == endIndex {
            return self[safeStorageIndex: startIndex]
        }

        let modOffset = offset % Storage.bitWidth
        var result: Storage = 0b0

        let bits0 = self[safeStorageIndex: startIndex]
        let bits1 = self[safeStorageIndex: endIndex]

        result = (bits0 >> modOffset) | ((bits1 << (Storage.bitWidth - modOffset)))

        return result
    }

    /// Sets `Storage.bitWidth` bits on the bitmask starting at the specified bit
    /// offset.
    /// Extra storage is created if offset + Storage.bitWidth is beyond the end
    /// of this bitmask's range.
    public mutating func setBits(offset: Int, bits: Storage) {
        if offset < -Storage.bitWidth {
            return
        }
        if offset < 0 {
            let mask: Storage = ~0b0 << (Storage.bitWidth - -offset)
            self[storageIndex: 0] = (self[storageIndex: 0] & mask) | (bits >> -offset)

            return
        }

        let bitStart = offset
        let bitEnd = offset + Storage.bitWidth - 1

        ensureBitCount(bitEnd)

        let startIndex = max(0, storageIndex(for: bitStart))
        let endIndex = max(0, storageIndex(for: bitEnd))

        assert(
            endIndex <= startIndex + 1,
            "Expected \(Storage.bitWidth) bits of storage to span a maximum of two consecutive \(Storage.self) indices."
        )

        if startIndex == endIndex {
            self[storageIndex: startIndex] = bits
        } else {
            let modOffset = offset % Storage.bitWidth

            self[storageIndex: startIndex] |= (bits << modOffset)
            self[storageIndex: endIndex] |= (bits >> (Storage.bitWidth - modOffset))
        }
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
            var mask: Storage = ~0 >> (Storage.bitWidth - count)
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
    /// The total number of bits set is always `Storage.bitWidth * self.storageLength`
    @inlinable
    public mutating func setAllBits(state: Bool) {
        if state {
            _storage = _Storage._unaryOp(value: _storage, op: { _ in ~0 })
        } else {
            _storage = _Storage._unaryOp(value: _storage, op: { _ in 0 })
        }
    }

    /// Returns a copy of this bitmask object with all on bits shifted left by a
    /// given amount.
    @inlinable
    public func shiftingBitsLeft(count: Int) -> Self {
        var copy = self
        copy.shiftBitsLeft(count: count)
        return copy
    }

    /// Shifts all on bits left by a given amount.
    @inlinable
    public mutating func shiftBitsLeft(count: Int) {
        _shift(count: count)
    }

    /// Returns a copy of this bitmask object with all on bits shifted right by a
    /// given amount.
    @inlinable
    public func shiftingBitsRight(count: Int) -> Self {
        var copy = self
        copy.shiftBitsRight(count: count)
        return copy
    }

    /// Shifts all on bits right by a given amount.
    @inlinable
    public mutating func shiftBitsRight(count: Int) {
        _shift(count: -count)
    }

    @inlinable
    mutating func _shift(count: Int) {
        switch count.quotientAndRemainder(dividingBy: Storage.bitWidth) {
        case (let q, 0):
            // If shift is a multiple of Storage.bitWidth, do a full storage
            // shift instead.
            _storage.shift(count: q)

        default:
            var result = Bitmask()

            let bitStart = count
            let bitEnd = bitWidth + count

            result.ensureBitCount(bitEnd)

            for (index, bits) in _storage.enumerated() {
                result.setBits(offset: bitStart + index * Storage.bitWidth, bits: bits)
            }

            self = result.compacted()
        }
    }

    /// Returns a copy of this bitmask where the storage is the minimal count of
    /// `Storage` bits capable of representing the on bits on this bitmask.
    @inlinable
    public func compacted() -> Self {
        var copy = self
        copy.compact()
        return copy
    }

    /// Reduces the storage elements of this bitmask to be the minimal count of
    /// `Storage` bits capable of representing the on bits on this bitmask.
    @inlinable
    public mutating func compact() {
        _storage.compact()
    }

    /// Exposes the storage of this bitmask with a given closure, invoking it
    /// in sequence from the earliest bit indices to the latest, packing the
    /// boolean states into sequences of `Storage.bitWidth` bits in `Storage`
    /// values.
    @inlinable
    public func withStorage(_ closure: (Storage) throws -> Void) rethrows {
        try _storage.withStorage(closure)
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

    /// Internal storage for a Bitmask type, supporting trailing storage elements
    /// in an array, as necessary.
    @usableFromInline
    internal enum _Storage: Hashable, Collection {
        case single(Storage)
        case multiple(Storage, [Storage])

        @inlinable
        var firstValue: Storage {
            switch self {
            case .single(let value), .multiple(let value, _):
                return value
            }
        }

        @inlinable
        var leadingZeroBitCount: Int {
            switch self {
            case .single(let value):
                return value.leadingZeroBitCount

            case .multiple(let value, let rem):
                guard let last = rem.last else {
                    return value.leadingZeroBitCount
                }

                return last.leadingZeroBitCount
            }
        }

        @inlinable
        var startIndex: Int {
            0
        }
        
        @inlinable
        var endIndex: Int {
            switch self {
            case .single:
                return 1

            case .multiple(_, let remaining):
                return 1 + remaining.count
            }
        }

        @inlinable
        subscript(position: Int) -> Storage {
            @inlinable
            get {
                switch self {
                case .single(let value):
                    assert(position == 0, "position == 0")
                    return value

                case .multiple(let lead, let remaining):
                    assert(position <= remaining.count, "position <= remaining.count")
                    if position == 0 {
                        return lead
                    }

                    return remaining[position - 1]
                }
            }
            @inlinable
            set {
                let storageCount = position
                if storageCount > endIndex {
                    ensureCapacity(count: storageCount)
                }

                switch self {
                case .single:
                    self = .single(newValue)

                case .multiple(let lead, let remaining):
                    if position == 0 {
                        self = .multiple(newValue, remaining)
                    } else {
                        var remaining = remaining
                        remaining[position - 1] = newValue

                        self = .multiple(lead, remaining)
                    }
                }
            }
        }

        @inlinable
        init(values: [Storage]) {
            if values.isEmpty {
                self = .single(0)
            } else if values.count == 1 {
                self = .single(values[0])
            } else {
                self = .multiple(values[0], Array(values.dropFirst()))
            }
        }

        @inlinable
        func index(after i: Int) -> Int {
            i + 1
        }

        @inlinable
        func compacted() -> Self {
            switch self {
            case .single:
                return self
                
            case .multiple(let lead, let remaining):
                if let lastNonZero = remaining.lastIndex(where: { $0 != 0 }) {
                    return .multiple(lead, Array(remaining.prefix(through: lastNonZero)))
                } else {
                    return .single(lead)
                }
            }
        }

        @inlinable
        mutating func compact() {
            self = compacted()
        }

        /// Shifts whole storage multiples of `Storage` to the left or right,
        /// depending on the sign of `count`, filling the initial storage with
        /// zeroed-out values if shifting to the left, and subtracting storage
        /// if shifting to the right.
        ///
        /// Shifting by zero is a no-op.
        @inlinable
        mutating func shift(count: Int) {
            if count == 0 {
                return
            }

            if count > 0 {
                self = .init(values: Array(repeating: 0b0, count: count) + Array(self))
            } else {
                self = .init(values: Array(self.dropFirst(-count)))
            }
        }
        
        @inlinable
        func withStorage(_ closure: (Storage) throws -> Void) rethrows {
            switch self {
            case .single(let value):
                try closure(value)
            
            case .multiple(let lead, let remaining):
                try closure(lead)

                for entry in remaining {
                    try closure(entry)
                }
            }
        }

        @inlinable
        mutating func ensureCapacity(count: Int) {
            guard count > self.count else {
                return
            }

            switch self {
            case .single(let storage):
                self = .multiple(storage, [Storage](repeating: 0, count: count - 1))
            
            case .multiple(let storage, var remaining):
                let extraStorage = (count + 1) - remaining.count

                if extraStorage > 0 {
                    remaining.append(contentsOf: [Storage](repeating: 0, count: extraStorage))
                    self = .multiple(storage, remaining)
                }
            }
        }

        @inlinable
        static func _binaryOp(lhs: Self, rhs: Self, op: (Storage, Storage) -> Storage) -> Self {
            switch (lhs, rhs) {
            case (.single(let lValue), .single(let rValue)):
                return .single(op(lValue, rValue))
            
            case (.single(let lValue), .multiple(let rValue, let rRem)):
                return .multiple(op(lValue, rValue), rRem.map { op(0b0, $0) })
            
            case (.multiple(let lValue, let lRem), .single(let rValue)):
                return .multiple(op(lValue, rValue), lRem.map { op($0, 0b0) })
            
            case (.multiple(let lValue, let lRem), .multiple(let rValue, let rRem)):
                let lead = op(lValue, rValue)

                let totalCount = Swift.max(lRem.count, rRem.count)
                var remaining = [Storage](repeating: 0b0, count: totalCount)

                let minCount = Swift.min(lRem.count, rRem.count)
                for index in 0..<minCount {
                    remaining[index] = op(lRem[index], rRem[index])
                }

                if lRem.count > rRem.count {
                    for index in minCount..<totalCount {
                        remaining[index] = op(lRem[index], 0b0)
                    }
                } else if lRem.count < rRem.count {
                    for index in minCount..<totalCount {
                        remaining[index] = op(0b0, rRem[index])
                    }
                }

                return .multiple(lead, remaining)
            }
        }

        @inlinable
        static func _unaryOp(value: Self, op: (Storage) -> Storage) -> Self {
            switch value {
            case .single(let v):
                return .single(op(v))

            case .multiple(let lead, let rem):
                return .multiple(op(lead), rem.map(op))
            }
        }
    }
}

extension Bitmask: Equatable {
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        let lhs = lhs.compacted()
        let rhs = rhs.compacted()

        return lhs._storage == rhs._storage
    }
}

extension Bitmask: Hashable {
    @inlinable
    public func hash(into hasher: inout Hasher) {
        let value = compacted()

        hasher.combine(value._storage)
    }
}

extension Bitmask: Decodable where Storage: Decodable {
    /// Decodes a bitmask from a given decoder.
    ///
    /// Accepted values:
    /// - `Storage` single value containers.
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        guard let count = container.count else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: [], debugDescription: "Expected proper collection of \(Storage.self) values")
            )
        }
        
        self.init()

        self.ensureBitCount(count * Storage.bitWidth)

        for index in 0..<count {
            self[storageIndex: index] = try container.decode(Storage.self)
        }
    }
}

extension Bitmask: Encodable where Storage: Encodable {
    /// Encodes this bitmask into a given encoder.
    ///
    /// Possible outputs of encoding:
    /// - `Storage` single value container.
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
        if UInt64.bitWidth == Storage.bitWidth {
            self.init(_storage: .single(Storage(value)))
        } else {
            self.init()

            let multiples = UInt64.bitWidth / Storage.bitWidth
            let mask: UInt64 = ~0b0 >> (UInt64.bitWidth - Storage.bitWidth)

            for index in 0...multiples {
                let bitIndex = index * Storage.bitWidth
                let bits = (value >> bitIndex) & mask

                self.setBits(offset: bitIndex, bits: Storage(bits))
            }

            self.compact()
        }
    }
}

public extension Bitmask {
    /// Returns the union of two bitmasks.
    @inlinable
    static func | (lhs: Self, rhs: Self) -> Self {
        _binaryOp(lhs, rhs, op: |)
    }

    /// Performs an in-place union of two bitmasks.
    @inlinable
    static func |= (lhs: inout Self, rhs: Self) {
        lhs = _binaryOp(lhs, rhs, op: |)
    }

    /// Returns the intersection of two bitmasks.
    @inlinable
    static func & (lhs: Self, rhs: Self) -> Self {
        _binaryOp(lhs, rhs, op: &)
    }

    /// Performs an in-place intersection of two bitmasks.
    @inlinable
    static func &= (lhs: inout Self, rhs: Self) {
        lhs = _binaryOp(lhs, rhs, op: &)
    }

    /// Returns the xor of two bitmasks.
    @inlinable
    static func ^ (lhs: Self, rhs: Self) -> Self {
        _binaryOp(lhs, rhs, op: ^)
    }

    /// Performs an in-place xor of two bitmasks.
    @inlinable
    static func ^= (lhs: inout Self, rhs: Self) {
        lhs = _binaryOp(lhs, rhs, op: ^)
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

        Self(_storage: _Storage._binaryOp(lhs: lhs._storage, rhs: rhs._storage, op: op))
    }

    @inlinable
    static internal func _unaryOp(
        _ value: Self,
        op: (Storage) -> Storage
    ) -> Self {
        
        Self(_storage: _Storage._unaryOp(value: value._storage, op: op))
    }
}
