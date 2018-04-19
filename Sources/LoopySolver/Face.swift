import Foundation

/// Represents a loopy game's geometric face, which is just a list of reference
/// to vertices on the game map, joined in a loop. The face also features an
/// optional number specifying how many of its edges belong to the solution.
///
/// A vertex may be shared by one or more faces, and an edge may be shared between
/// one or two faces.
///
/// Vertice of faces are always concave and never intersect, neither with other
/// faces nor with themselves.
public struct Face: Equatable {
    public typealias Id = Int
    
    /// A unique identifier for this face
    public var id: Id
    
    /// Indices of vertices that make up this cell
    public var indices: [Int]
    
    public var hint: Int?
    
    public static func ==(lhs: Face, rhs: Face) -> Bool {
        return lhs.id == rhs.id && lhs.indices == rhs.indices && lhs.hint == rhs.hint
    }
}
