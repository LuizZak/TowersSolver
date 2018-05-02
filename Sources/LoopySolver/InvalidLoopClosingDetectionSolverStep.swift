/// Detects patterns where a single selected edge between two edges would form a
/// loop, but such loop would be invalid due to it not including other edges.
public class InvalidLoopClosingDetectionSolverStep: SolverStep {
    public func apply(to field: LoopyField) -> LoopyField {
        let solver = InternalSolver(field: field)
        solver.apply()
        
        return solver.field
    }
}

private class InternalSolver {
    var controller: LoopyFieldController
    
    var field: LoopyField {
        return controller.field
    }
    
    init(field: LoopyField) {
        controller = LoopyFieldController(field: field)
    }
    
    func apply() {
        let entries = collectEdges()
        let allMarked = field.edges.filter { $0.state == .marked }
        
        for edge in entries {
            apply(on: edge, allMarked: allMarked)
        }
    }
    
    private func collectEdges() -> [Entry] {
        var entries: [Entry] = []
        
        // Search for all edges, unmarked, which connect two vertices that point
        // to two dead-end marked edges (in a 'doorway' or 'window' fashion)
        for edge in field.edges where edge.state == .normal {
            let edgesInStart =
                field.edgesSharing(vertexIndex: edge.start)
                    .filter { $0.state == .marked }
            
            guard edgesInStart.count == 1 else {
                continue
            }
            
            let edgesInEnd =
                field.edgesSharing(vertexIndex: edge.end)
                    .filter { $0.state == .marked }
            
            guard edgesInEnd.count == 1 else {
                continue
            }
            
            entries.append(Entry(edge: edge, firstEdge: edgesInStart[0],
                                 secondEdge: edgesInEnd[0]))
        }
        
        return entries
    }
    
    private func apply(on entry: Entry, allMarked: [Edge]) {
        // Check if the edges from the entry link to one another
        let path =
            GraphUtils.singlePathEdges(in: field, fromEdge: entry.firstEdge) { edge in
                edge.state == .marked
            }
        
        // If path doesn't include both ends, it won't form a loop
        guard path.contains(entry.secondEdge) else {
            return
        }
        
        // If the path is actually the combination of all marked edges, then this
        // is just a valid possible path-closing edge.
        guard Set(allMarked) != Set(path) else {
            return
        }
        
        controller.setEdge(state: .disabled, forEdge: entry.edge)
    }
    
    private struct Entry {
        var edge: Edge
        
        var firstEdge: Edge
        var secondEdge: Edge
    }
}
