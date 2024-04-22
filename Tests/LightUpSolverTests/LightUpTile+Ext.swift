@testable import LightUpSolver

extension LightUpTile: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: IntegerLiteralType) {
        self.init(state: .wall(hint: value))
    }
}
