import Geometry

extension LoopyGrid {
    /// From a starting edge in a graph, extract all connected edges that share
    /// a vertex in such a way that the connected vertex has only two edges connected.
    ///
    /// This essentially returns a single unambiguous path from the starting
    /// edge until it reaches a vertex that has more than a single ovious path
    /// to go through.
    ///
    /// - Parameters:
    ///   - graph: The graph to search.
    ///   - edge: The starting edge.
    ///   - excludeDisabled: If `true`, edges that have their `.state` as `.disabled`
    /// are not included in the result, and not traversed through.
    /// - Returns: A list of all single-path edges connected to the starting edge,
    /// including the starting edge itself.
    /// If the starting edge is not connected to any edges uniquely, an array with
    /// just the starting edge is returned.
    public func singlePathEdges(fromEdge edge: Edge.Id,
                                excludeDisabled: Bool = true) -> [Edge.Id] {
        
        return singlePathEdges(fromEdge: edge) { edge in
            if excludeDisabled && edgeState(forEdge: edge) == .disabled {
                return false
            }
            
            return true
        }
    }
    
    /// Returns an array of all edges that enclose a face with a given id.
    public func edges(forFace face: Int) -> [Edge.Id] {
        return edges(forFace: Face.Id(face))
    }
}
