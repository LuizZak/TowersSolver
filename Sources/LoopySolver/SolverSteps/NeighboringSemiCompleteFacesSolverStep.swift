/// Solver step that deals with cases of semi-complete (`hint == edge_count - 1`)
/// faces that touch either edge-wise or across corners via a common vertex.
public class NeighboringSemiCompleteFacesSolverStep: SolverStep {
    public func apply(to grid: LoopyGrid, _ delegate: SolverStepDelegate) -> LoopyGrid {
        let solver = InternalSolver(grid: grid)
        solver.apply()

        return solver.grid
    }
}

private class InternalSolver {
    var controller: LoopyGridController

    var grid: LoopyGrid {
        return controller.grid
    }

    init(grid: LoopyGrid) {
        controller = LoopyGridController(grid: grid)
    }

    func apply() {
        // Collect pairs of semi-complete faces to work on
        let pairs = collect()

        for pair in pairs {
            apply(to: pair)
        }
    }

    private func collect() -> [FacePair] {
        var pairs: [FacePair] = []

        let semifaces = controller.semiCompleteFaces()
        if semifaces.count == 0 {
            return pairs
        }

        for i in 0..<semifaces.count - 1 {
            let semi1 = semifaces[i]
            if grid.isFaceSolved(semi1) {
                continue
            }

            for j in i + 1..<semifaces.count {
                let semi2 = semifaces[j]
                if grid.isFaceSolved(semi2) {
                    continue
                }

                // Test for a shared edge
                if let edge = grid.sharedEdge(between: semi1, semi2) {
                    pairs.append(FacePair(face1: semi1, face2: semi2, sharing: .edge(edge)))
                    continue
                }

                // Test for a shared vertex
                let vertices = grid.sharedVertices(between: semi1, semi2)
                if vertices.count == 1 {
                    pairs.append(
                        FacePair(face1: semi1, face2: semi2, sharing: .vertex(vertices[0]))
                    )
                }
            }
        }

        return pairs
    }

    private func apply(to pair: FacePair) {

        switch pair.sharing {
        case .edge(let shared):
            controller.setEdge(state: .marked, forEdge: shared)

            // Mark all opposing edges from the shared edge on both faces
            for edge in grid.edges(forFace: pair.face1) {
                if !grid.edgesShareVertex(edge, shared) {
                    controller.setEdge(state: .marked, forEdge: edge)
                }
            }
            for edge in grid.edges(forFace: pair.face2) {
                if !grid.edgesShareVertex(edge, shared) {
                    controller.setEdge(state: .marked, forEdge: edge)
                }
            }

            let (sharedStart, sharedEnd) = grid.vertices(forEdge: shared)

            // Now take the shared edge's vertices and disable any other edge that
            // shares those vertices, and is not part of either of the paired faces
            var otherEdges =
                grid.edgesSharing(vertexIndex: sharedStart)
                + grid.edgesSharing(vertexIndex: sharedEnd)

            otherEdges = otherEdges.filter { edge in
                !grid.faceContainsEdge(face: pair.face1, edge: edge)
                    && !grid.faceContainsEdge(face: pair.face2, edge: edge)
            }

            controller.setEdges(state: .disabled, forEdges: otherEdges)

        case .vertex(let vertex):
            // Set all edges not connected to the target vector on both faces as
            // marked
            let edges1 =
                grid.edges(forFace: pair.face1)
                .filter { !grid.edgeSharesVertex($0, vertex: vertex) }

            let edges2 =
                grid.edges(forFace: pair.face2)
                .filter { !grid.edgeSharesVertex($0, vertex: vertex) }

            controller.setEdges(state: .marked, forEdges: edges1)
            controller.setEdges(state: .marked, forEdges: edges2)
        }
    }

    private struct FacePair {
        var face1: Face.Id
        var face2: Face.Id

        var sharing: SharedElement

        enum SharedElement {
            case edge(Edge.Id)
            case vertex(Int)
        }
    }
}
