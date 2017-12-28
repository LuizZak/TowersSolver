/// Represents a vertex that has up to 4 cardinal connections to other vertices.
public struct Vertex: Hashable {
    public var x: Int
    public var y: Int
    
    public var hashValue: Int {
        var hash = 7
        hash = (hash * 13) + x
        hash = (hash * 13) + y
        return hash
    }
    
    public static func ==(lhs: Vertex, rhs: Vertex) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
}
