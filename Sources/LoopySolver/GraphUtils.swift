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
    public static func singlePathEdges(in graph: LoopyField, fromEdge edge: Edge.Id,
                                       excludeDisabled: Bool = true) -> [Edge.Id] {
        
        return singlePathEdges(in: graph, fromEdge: edge) { edge in
            if excludeDisabled && graph.edgeState(forEdge: edge) == .disabled {
                return false
            }
            
            return true
        }
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
    ///   - includeTest: A custom test to perform when considering edges to form
    /// the path.
    /// - Returns: A list of all single-path edges connected to the starting edge,
    /// including the starting edge itself.
    /// If the starting edge is not connected to any edges uniquely, an array with
    /// just the starting edge is returned.
    public static func singlePathEdges(in graph: LoopyField, fromEdge edge: Edge.Id,
                                       includeTest: (Edge.Id) -> Bool) -> [Edge.Id] {
        return withoutActuallyEscaping(includeTest) { includeTest in
            var result: [Edge.Id] = []
            
            // Only include edges not already accounted for in the result array
            let includeFilter: (Edge.Id) -> Bool = { edge in
                if !includeTest(edge) {
                    return false
                }
                
                return !result.contains { graph.edgesMatchVertices(edge, $0) }
            }
            
            // First, find the logical start of the traversal by traversing through
            // the left of the edges until the beginning of the straight edges chain
            let edgeStart: Edge.Id = { () -> Edge.Id in
                var next = edge
                var visited: [Edge.Id] = []
                
                while true {
                    visited.append(next)
                    
                    let edgesLeft =
                        graph.edgesSharing(vertexIndex: graph.vertices(forEdge: next).start)
                            .filter(includeFilter)
                            .filter { !visited.contains($0) }
                    
                    if edgesLeft.count == 1 {
                        next = edgesLeft[0]
                    } else {
                        break
                    }
                }
                
                return next
            }()
            
            var stack = [edgeStart]
            
            while let next = stack.popLast() {
                // Already visited
                if result.contains(where: { graph.edgesMatchVertices(next, $0) }) {
                    continue
                }
                
                result.append(next)
                
                let edgesLeft =
                    graph.edgesSharing(vertexIndex: graph.vertices(forEdge: next).start)
                        .filter(includeFilter)
                
                let edgesRight =
                    graph.edgesSharing(vertexIndex: graph.vertices(forEdge: next).end)
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
}
