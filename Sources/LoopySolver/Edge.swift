import Commons
import Geometry

/// Common protocol to abstract edge references between actual edge structures and
/// edge IDs.
public protocol EdgeReferenceConvertible {
    var edgeIndex: Int { get }
}

/// Represents an edge between two vertices.
///
/// Edges are bidirectional and always start from a lower vertex index pointing
/// to a higher vertex index.
public struct Edge: Equatable, EdgeProtocol {
    public typealias Id = Key<Edge, Int>

    /// Starting vertex index for this edge
    public let start: Int
    /// Ending vertex index for this edge
    public let end: Int

    public var state: State

    public init(start: Int, end: Int) {
        self.init(start: start, end: end, state: .normal)
    }

    public init(start: Int, end: Int, state: State) {
        self.start = min(start, end)
        self.end = max(start, end)
        self.state = state
    }

    /// Returns `true` if either the start/end vertices match a given vertex index.
    @inlinable
    public func sharesVertex(_ vertex: Int) -> Bool {
        return start == vertex || end == vertex
    }

    /// Returns `true` if this edge shares a vertex index with a given edge.
    @inlinable
    public func sharesVertex(with edge: Edge) -> Bool {
        return sharesVertex(edge.start) || sharesVertex(edge.end)
    }

    /// In case this edge shares a vertex with another edge, returns the index of
    /// the common vertex; otherwise returns nil
    @inlinable
    public func sharedVertex(with edge: Edge) -> Int? {
        if edge.start == start || edge.end == start {
            return start
        }
        if edge.start == end || edge.end == end {
            return end
        }

        return nil
    }

    /// Returns `true` if this edge has the same vertex start/end values as a given
    /// edge, without taking into account the directionality of the start/end
    /// values.
    @inlinable
    public func matchesEdgeVertices(_ edge: Edge) -> Bool {
        return sharesVertex(edge.start) && sharesVertex(edge.end)
    }

    @inlinable
    public static func == (lhs: Edge, rhs: Edge) -> Bool {
        if lhs.state != rhs.state {
            return false
        }

        return lhs.start == rhs.start && lhs.end == rhs.end
    }

    /// Enumeration of possible states for an edge.
    ///
    /// - normal: Edge is not disabled nor marked as part of the solution.
    /// - marked: Edge is marked as part of the solution.
    /// - disabled: Edge is disabled. Used for marking an edge as definitely not
    /// part of the solution.
    public enum State: CustomStringConvertible {
        case normal
        case marked
        case disabled

        /// Returns `true` if `self != .disabled`
        @inlinable
        public var isEnabled: Bool {
            return self != .disabled
        }

        public var description: String {
            switch self {
            case .normal:
                return "n"
            case .marked:
                return "m"
            case .disabled:
                return "d"
            }
        }
    }
}

extension Key: EdgeReferenceConvertible where T == Edge, U == Int {
    @inlinable
    public var edgeIndex: Int {
        return value
    }
}

public func == (lhs: EdgeReferenceConvertible, rhs: EdgeReferenceConvertible) -> Bool {
    lhs.edgeIndex == rhs.edgeIndex
}
