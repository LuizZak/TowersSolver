/// Solver step that examines neighboring faces that share an edge to detect cases
/// of edges not being markable due to the implication it would result in invalid
/// edge count for either of the joined faces:
///
/// ```
/// •───•───•───•───•
/// │   │ 1 │ 1 │   │
/// •───•───•───•───•
/// │   │   │   │   │
/// •───•───•───•───•
/// ```
///
/// In the above case, the shared edge between the two `1` faces cannot be marked,
/// since it would require detouring around one of the two `1` faces to continue,
/// resulting in a guaranteed larger-than-one marked edges count for either face.
public class NeighboringShortFacesSolverStep: SolverStep {
    public static let metadataKey: String = "\(NeighboringShortFacesSolverStep.self)"
    
    public func apply(to grid: LoopyGrid, _ delegate: SolverStepDelegate) -> LoopyGrid {
        let metadata = delegate.metadataForSolverStepClass(type(of: self))
        
        let solver = InternalSolver(grid: grid, metadata: metadata)
        solver.apply()
        
        return solver.grid
    }
}
private class InternalSolver {
    var metadata: SolverStepMetadata
    
    var grid: LoopyGrid
    
    init(grid: LoopyGrid, metadata: SolverStepMetadata) {
        self.grid = grid
        self.metadata = metadata
    }
    
    func apply() {
        if metadata.isFlagMarked() {
            return
        }
        metadata.markFlag()
        
        // Collect pairs of semi-complete faces to work on
        let pairs = collect()
        
        for pair in pairs {
            apply(to: pair)
        }
    }
    
    private func collect() -> [FacePair] {
        var pairs: [FacePair] = []
        
        // Examine only faces with hints
        let faces = grid.faceIds.filter { grid.hintForFace($0) != nil }
        
        if faces.count == 0 {
            return pairs
        }
        
        for i in 0..<faces.count - 1 {
            let semi1 = faces[i]
            if grid.isFaceSolved(semi1) {
                continue
            }
            
            for j in i + 1..<faces.count {
                let semi2 = faces[j]
                if grid.isFaceSolved(semi2) {
                    continue
                }
                
                // Test for a shared edge
                if let edge = grid.sharedEdge(between: semi1, semi2) {
                    pairs.append(FacePair(face1: semi1, face2: semi2, edge: edge))
                }
            }
        }
        
        return pairs
    }
    
    private func apply(to pair: FacePair) {
        let edge = pair.edge
        
        let grid = self.grid
        
        let applyToEdges: (Edge.Id, Edge.Id) -> Void = {
            
            // Detect both edges belong to the pair we're looking at
            guard (grid.faceContainsEdge(face: pair.face1, edge: $0) || grid.faceContainsEdge(face: pair.face1, edge: $1)) && (grid.faceContainsEdge(face: pair.face2, edge: $0) || grid.faceContainsEdge(face: pair.face2, edge: $1)) else {
                return
            }
            
            let face1Edge = grid.faceContainsEdge(face: pair.face1, edge: $0) ? $0 : $1
            let face2Edge = grid.faceContainsEdge(face: pair.face2, edge: $0) ? $0 : $1
            
            // Check if the paths taken by the line exceeds the requirement of
            // the face's hint, when considered alone
            let count1 = grid
                .singlePathEdges(fromEdge: face1Edge)
                .count { grid.faceContainsEdge(face: pair.face1, edge: $0) }
            
            let count2 = grid
                .singlePathEdges(fromEdge: face2Edge)
                .count { grid.faceContainsEdge(face: pair.face2, edge: $0) }
            
            if count1 >= (grid.hintForFace(pair.face1) ?? Int.max) && count2 >= (grid.hintForFace(pair.face2) ?? Int.max) {
                self.grid.withEdge(edge) {
                    $0.state = .disabled
                }
            }
        }
        
        let (vStart, vEnd) = grid.vertices(forEdge: edge)
        
        // Pick connected edges (in both ends of the shared edge) and check if
        // they all belong to the two paired faces
        // Examine each end separately
        let edgesStart = grid
            .edgesSharing(vertexIndex: vStart)
            .filter { $0 != edge }
            .compactMap { grid.edgeId(forEdge: $0) }
        
        if edgesStart.count == 2 {
            applyToEdges(edgesStart[0], edgesStart[1])
            return
        }
        
        let edgesEnd = grid
            .edgesSharing(vertexIndex: vEnd)
            .filter { $0 != edge }
            .compactMap { grid.edgeId(forEdge: $0) }
        
        if edgesEnd.count == 2 {
            applyToEdges(edgesEnd[0], edgesEnd[1])
            return
        }
    }
    
    private struct FacePair {
        var face1: Face.Id
        var face2: Face.Id
        
        var edge: Edge.Id
    }
}
