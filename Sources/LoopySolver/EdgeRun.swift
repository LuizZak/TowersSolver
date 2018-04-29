/// Represents a sequence of vertices that form a line segment.
/// Full line segment represented by this structure may or may not be looped.
public struct EdgeRun {
    /// index of vertices within this edge run
    public var vertexIndices: [Int]
    
    /// Creates a new edge run using a given edges run list.
    public init(vertexIndices: [Int]) {
        self.vertexIndices = vertexIndices
    }
}
