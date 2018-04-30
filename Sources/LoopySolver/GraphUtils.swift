/// General utility functions to use with a Loopy field
public enum GraphUtils {
    
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
    public static func singlePathEdges(in graph: LoopyField, fromEdge edge: Edge.Id, excludeDisabled: Bool = true) -> [Edge] {
        return singlePathEdges(in: graph, fromEdge: edge.edge(in: graph), excludeDisabled: excludeDisabled)
    }
    
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
    public static func singlePathEdges(in graph: LoopyField, fromEdge edge: Edge, excludeDisabled: Bool = true) -> [Edge] {
        var result: [Edge] = []
        var stack = [edge]
        
        // Only include edges not already accounted for in the result array
        let includeFilter: (Edge) -> Bool = { edge in
            if excludeDisabled && edge.state == .disabled {
                return false
            }
            
            return !result.contains(where: edge.matchesEdgeVertices)
        }
        
        while let next = stack.popLast() {
            // Already visited
            if result.contains(where: next.matchesEdgeVertices) {
                continue
            }
            
            result.append(next)
            
            let edgesLeft =
                graph.edgesSharing(vertexIndex: next.start)
                    .edges(in: graph)
                    .filter(includeFilter)
            
            let edgesRight =
                graph.edgesSharing(vertexIndex: next.end)
                    .edges(in: graph)
                    .filter(includeFilter)
            
            if edgesLeft.count == 1 {
                stack.append(edgesLeft[0])
            }
            if edgesRight.count == 1 {
                stack.append(edgesRight[0])
            }
        }
        
        return result
    }
}
