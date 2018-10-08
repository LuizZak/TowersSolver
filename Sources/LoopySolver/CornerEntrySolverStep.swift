/// A solver step that deals with loopy lines that touch a face in a corner in
/// such a way that the line has to traverse through the face, marking a minimal
/// number of edges around the face.
///
/// Ex: On the following grid, the top-right marked edge has to pass through the
/// 1-hinted face to be able to continue. Since we know that it will have to cross
/// the edges of the face, we know the left edge of the cell cannot be marked
/// (since it would exceed the requiremet for the cell), and the right and bottom
/// edges of the face also cannot be marked, since it would require marking the
/// two edges to make the corner, which would exceed the requirement, as well.
///
///     . _ . _ .
///     ! _ ! _ ║
///     ! _ ! 1 !
///
/// This solver step also deals with cases of semi-complete edges that have an
/// entry point that enters through an edge:
///     . _ . _ .
///     ! _ ! _ ║
///     ! _ ! 3 !
///
public class CornerEntrySolverStep: SolverStep {
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
        for i in 0..<grid.vertices.count {
            applyToVertex(i)
        }
    }
    
    func applyToVertex(_ vertexIndex: Int) {
        if metadata.matchesStoredVertexState(vertexIndex, from: grid) {
            return
        }
        defer {
            metadata.storeVertexState(vertexIndex, from: grid)
        }
        
        let edges = grid.edgesSharing(vertexIndex: vertexIndex)
        
        let marked = edges.filter { grid.edgeState(forEdge: $0) == .marked }
        let normal = edges.filter { grid.edgeState(forEdge: $0) == .normal }
        
        // Can only do work on loose ends of a loopy line (a vertex with a single
        // marked edge)
        guard marked.count == 1 else {
            return
        }
        
        // If any of the faces is semi-complete, apply a different logic here to
        // 'hijack' the line into it's own path
        if let semiComplete = grid.facesSharing(vertexIndex: vertexIndex).first(where: grid.isFaceSemicomplete) {
            if grid.isFaceSolved(semiComplete) {
                return
            }
            
            // Can only account for edges coming into the face from an outside
            // edge
            if grid.faceContainsEdge(face: semiComplete, edge: marked[0]) {
                return
            }
            
            let oppositeEdges = grid.edges(forFace: semiComplete)
                .filter { !grid.edgeSharesVertex($0, vertex: vertexIndex) }
            
            grid.setEdges(state: .marked, forEdges: oppositeEdges)
            
            // Disable edges from other faces that share that vertex to finish
            // hijacking the line path
            let otherEdges = edges
                .filter { !grid.faceContainsEdge(face: semiComplete, edge: grid.edgeId(forEdge: $0)!) }
                .filter { marked[0] != $0 }
            
            grid.setEdges(state: .disabled, forEdges: otherEdges)
            
            return
        }
        
        // Find the face that all path candidate edges share
        let allFaces = normal.map { Set(grid.facesSharing(edge: $0)) }
        if allFaces.count == 0 {
            return
        }
        
        let commonFaces = allFaces.reduce(allFaces[0]) { result, faces in
            result.intersection(faces)
        }
        
        // Expect a single common face to work with
        if commonFaces.count != 1 {
            return
        }
        
        let faceId = commonFaces.first!
        
        applyToFace(faceId, vertex: vertexIndex)
    }
    
    func applyToFace(_ face: Face.Id, vertex: Int) {
        if metadata.matchesStoredFaceState(face, from: grid) {
            return
        }
        defer {
            metadata.storeFaceState(face, from: grid)
        }
        
        if grid.isFaceSolved(face) {
            return
        }
        
        // Requires hint!
        guard let hint = grid.hintForFace(face) else {
            return
        }
        
        let allEdges = grid.edges(forFace: face)
        
        let edges = allEdges.filter { grid.edgeSharesVertex($0, vertex: vertex) }
        
        let normalEdges = edges.filter { grid.edgeState(forEdge: $0) == .normal }
        
        if normalEdges.isEmpty {
            return
        }
        
        var leastCount = Int.max
        
        for edge in normalEdges {
            let edgesPath =
                grid.singlePathEdges(fromEdge: edge)
                    .filter { grid.faceContainsEdge(face: face, edge: $0) }
            
            let edgeCount = edgesPath.count
            leastCount = min(edgeCount, leastCount)
            
            // If we follow this path, we'll end up with more edges marked than
            // the face requirement; disable this path, then
            if edgeCount > hint {
                grid.setEdges(state: .disabled, forEdges: edgesPath)
            }
        }
        
        if leastCount >= hint {
            // Disable all edges not sharing the common vertex
            let toDisable = allEdges.filter { !grid.edgeSharesVertex($0, vertex: vertex) }
            
            grid.setEdges(state: .disabled, forEdges: toDisable)
        }
    }
}
