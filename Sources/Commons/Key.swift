/// Represents a type-safe variant of a unique key, with a type-tag to use as
/// discriminator when using the same key type (e.g. Int) across many different
/// key types.
public struct Key<T, U> {
    public var value: U

    @inlinable
    public init(_ value: U) {
        self.value = value
    }
}

extension Key: ExpressibleByIntegerLiteral where U: ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = U.IntegerLiteralType

    @inlinable
    public init(integerLiteral value: IntegerLiteralType) {
        self.init(U(integerLiteral: value))
    }
}

extension Key: Equatable where U: Equatable {
    @inlinable
    public static func == (lhs: Key, rhs: Key) -> Bool {
        return lhs.value == rhs.value
    }
}

extension Key: Hashable where U: Hashable {
    @inlinable
    public func hash(into hasher: inout Hasher) {
        value.hash(into: &hasher)
    }
}
