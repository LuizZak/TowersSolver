import Foundation
import Geometry

/// Represents a sequence of vertices that form a line segment.
/// Full line segment represented by this structure may or may not be looped.
public struct LineSegment {
    /// Edges connected on this line segment
    public var vertices: [Vertex]
    
    public init(vertices: [Vertex]) {
        self.vertices = vertices
    }
}
