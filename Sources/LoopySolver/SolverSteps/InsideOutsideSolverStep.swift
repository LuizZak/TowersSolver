import Geometry

/// Solver step that analyzes a grid by detecting island of faces that are either
/// definitely inside or definitely outside of a loop, connecting neighboring
/// islands accordingly.
public class InsideOutsideSolverStep: SolverStep {
    public func apply(to grid: LoopyGrid, _ delegate: SolverStepDelegate) -> LoopyGrid {
        let solver = InnerSolver(grid: grid)
        solver.apply()

        return solver.grid
    }
}

private class InnerSolver {
    var grid: LoopyGrid

    init(grid: LoopyGrid) {
        self.grid = grid
    }

    func apply() {
        let outerFaces = outerFaces()
        let outerNetworks = toFaceNetworks(outerFaces)

        // Perform a breadth-first traversal across connected tile networks,
        // marking the edges of intermediary networks according to certain
        // conditions
        var remaining = outerNetworks.union(allConnectedNetworks(outerNetworks))

        while !remaining.isEmpty {
            var network = remaining.removeFirst()

            for other in remaining {
                if let newNetwork = processNeighbors(network, other) {
                    remaining.remove(other)
                    network = newNetwork
                }
            }

            processOuterEdges(network)
        }

        expandEnclosedSpaces()
    }

    /// Expands networks of tiles when more than one 'inside' network is present,
    /// and it has a single non-marked outer edge, indicating that the network
    /// must span at least one face further to meet other 'inside' networks further
    /// down.
    ///
    /// The same is done for 'outside' networks that are surrounded by marked
    /// edges and a single normal edge.
    func expandEnclosedSpaces() {
        let outerFaces = outerFaces()
        let outerNetworks = toFaceNetworks(outerFaces)

        let networks =
            outerNetworks.union(
                allConnectedNetworks(outerNetworks)
            )
        
        let insideNetworks = networks.filter {
            $0.state == .inside
        }
        let outsideNetworks = networks.filter {
            $0.state == .outside
        }
        
        if insideNetworks.count > 1 {
            for network in insideNetworks {
                let normalEdges = network.outerEdges(withStates: [.normal], in: grid)
                guard normalEdges.count == 1 else {
                    continue
                }

                grid.setEdge(state: .disabled, forEdge: normalEdges[0])
            }
        }

        for network in outsideNetworks {
            let edges = network.outerEdges(withStates: [.normal, .disabled], in: grid)
            let normalEdges = edges.filter { grid.edgeState(forEdge: $0) == .normal }
            let disabledEdges = edges.filter { grid.edgeState(forEdge: $0) == .disabled }
            guard normalEdges.count == 1 && disabledEdges.count == 0 else {
                continue
            }

            grid.setEdge(state: .disabled, forEdge: normalEdges[0])
        }
    }

    /// Process the neighboring state of two networks, and if both networks have
    /// the same containment status with undefined edges between them, returns
    /// the new merged networks, modifying the edge states on the underlying
    /// grid in the process.
    ///
    /// Returns `nil` if the neighbors are not connected.
    func processNeighbors(_ network1: FaceNetwork, _ network2: FaceNetwork) -> FaceNetwork? {
        guard network1.state != .unknown && network1.state == network2.state else {
            return nil
        }

        let modified = network1.connectWithNetwork(network2, in: &grid)

        guard modified else {
            return nil
        }

        return network1.merged(with: network2)
    }

    /// Processes the outer edges of a network, marking them if the network is
    /// supposed to be the inside of a loop, or disabling the outer edges if it
    /// is meant to be the outside of the loop.
    ///
    /// Does nothing for networks of `.unknown` containment status.
    func processOuterEdges(_ network: FaceNetwork) {
        guard network.state != .unknown else {
            return
        }

        for face in network.faces {
            let nonShared = grid.nonSharedEdges(forFace: face.id)
            
            switch network.state {
            case .inside:
                grid.setEdges(state: .marked, forEdges: nonShared)

            case .outside:
                grid.setEdges(state: .disabled, forEdges: nonShared)

            case .unknown:
                return
            }
        }
    }

    /// Returns a set of all networks that are connected to the provided set of
    /// networks, recursively.
    ///
    /// Does not include networks from the input itself.
    func allConnectedNetworks(_ networks: Set<FaceNetwork>) -> Set<FaceNetwork> {
        var result: Set<FaceNetwork> = []
        var visited: Set<FaceNetwork> = networks
        var queue = networks

        while let network = queue.popFirst() {
            visited.insert(network)

            for nextNetwork in collectNeighboringNetworks(network) {
                guard !visited.contains(nextNetwork) else {
                    continue
                }

                result.insert(nextNetwork)
            }
        }

        return result
    }

    func collectNeighboringNetworks(_ network: FaceNetwork) -> Set<FaceNetwork> {
        let neighbors = grid.neighboringNetworksFor(network.faces)
        var result: Set<FaceNetwork> = []

        for neighbor in neighbors {
            let network = FaceNetwork(subset: neighbor, state: network.state.reversed)
            result.insert(network)
        }

        return result
    }

    func toFaceNetworks(_ faces: [OuterFaceEntry]) -> Set<FaceNetwork> {
        var remaining = faces
        var result: Set<FaceNetwork> = []

        while let face = remaining.popLast() {
            let network = grid.networkForFace(face.faceId)
            var state: FaceNetwork.State = .unknown

            for edge in face.outerEdges {
                if edge.edge.state == .disabled {
                    state = .outside
                    break
                }
                if edge.edge.state == .marked {
                    state = .inside
                    break
                }
            }

            if network.faces.count == 1 && state == .unknown {
                continue
            }

            let entry = FaceNetwork(subset: network, state: state)
            result.insert(entry)
        }

        return result
    }

    /// Returns a list of all faces that have at least one edge touching the
    /// outside of the grid, along with the list of outside edges.
    func outerFaces() -> [OuterFaceEntry] {
        grid.faceIds.compactMap {
            let edges = grid.nonSharedEdges(forFace: $0)

            if edges.isEmpty {
                return nil
            }

            return OuterFaceEntry(
                faceId: $0,
                outerEdges: edges.map {
                    (edge: grid.edgeReferenceFrom($0), id: $0)
                }
            )
        }
    }

    struct OuterFaceEntry {
        var faceId: LoopyGrid.FaceId

        var outerEdges: [(edge: Edge, id: LoopyGrid.EdgeId)]
    }

    /// A network of faces with the associated inside/outside state
    struct FaceNetwork: Hashable {
        var subset: PolygonGraphSubset<LoopyGrid>
        var state: State

        var faces: Set<LoopyGrid.FaceId> {
            subset.faces
        }

        /// Returns a list of edges that are shared between `self.faces` and
        /// `other.faces`.
        ///
        /// Returns an empty set if no faces from `self` neighbor `other`.
        ///
        /// Return is undefined if the networks share one or more faces.
        func neighboringEdges(to network: FaceNetwork, in grid: LoopyGrid) -> Set<LoopyGrid.EdgeId> {
            var result: Set<LoopyGrid.EdgeId> = []

            for face in faces {
                for otherFace in network.faces {
                    if let shared = grid.sharedEdge(between: face, otherFace) {
                        result.insert(shared)
                    }
                }
            }

            return result
        }

        /// Modifies the provided grid where each edge from this network's face
        /// list that neighbors another network's faces has its state set
        /// depending on the containment state of each network.
        ///
        /// - If both networks are `.inside` or `.outside`, disables all edges
        /// common between the networks to connect the faces directly.
        /// - If one of the networks is `.inside` and the other `.outside`,
        /// marks all edges common between the networks as `.marked`
        /// - In case the containment state of either is `.unknown`, nothing is
        /// changed.
        ///
        /// In case neighboring edges with suitable states where modified, the
        /// function returns `true`, otherwise `false`.
        func connectWithNetwork(
            _ other: FaceNetwork,
            in grid: inout LoopyGrid
        ) -> Bool {

            let newState: Edge.State
            switch (state, other.state) {
            case (.inside, .inside), (.outside, .outside):
                newState = .disabled
            
            case (.inside, .outside), (.outside, .inside):
                newState = .marked

            case (.unknown, _), (_, .unknown):
                return false
            }
            
            let edges = neighboringEdges(to: other, in: grid)

            if edges.contains(where: { grid.edgeState(forEdge: $0) != newState }) {
                grid.setEdges(state: newState, forEdges: edges)

                return true
            }

            return false
        }

        /// Returns a new face network that has the combination of faces from
        /// `self` and `other`.
        ///
        /// This function assumes the networks both have the same containment
        /// state `self.state`.
        func merged(with other: FaceNetwork) -> FaceNetwork {
            FaceNetwork(subset: subset.combined(with: other.subset), state: state)
        }

        /// Returns a list of edges from all faces in this network that match
        /// a given state set.
        ///
        /// - note: Edges may be between internal faces and not necessarily at
        /// the boundary of the network.
        func edges(withStates states: Set<Edge.State>, in grid: LoopyGrid) -> [LoopyGrid.EdgeId] {
            return faces.reduce([]) { (edges: [LoopyGrid.EdgeId], face: LoopyGrid.FaceId) in
                return edges + grid.edges(forFace: face).filter { (edge: LoopyGrid.EdgeId) in
                    states.contains(grid.edgeState(forEdge: edge))
                }
            }
        }

        /// Returns a list of edges from all faces in this network that don't
        /// neighbor other faces within the network that match a given state set.
        func outerEdges(withStates states: Set<Edge.State>, in grid: LoopyGrid) -> [LoopyGrid.EdgeId] {
            let allEdges = edges(withStates: states, in: grid)

            return allEdges.filter { edge in
                let edgeFaces = grid.facesSharing(edge: edge)

                return faces.intersection(edgeFaces).count == 1
            }
        }

        /// The state of the face in regards to containment within the loop.
        enum State {
            case inside
            case outside
            case unknown

            /// Reverses this containment state to its logic counterpart.
            /// Unknown containment states return as `.unknown` when reversed.
            ///
            /// Returns `.inside` if `self == .outside`, `.outside` if
            /// `self == .inside`, and `.unknown` if `self == .unknown`
            var reversed: Self {
                switch self {
                case .inside:
                    return .outside
                case .outside:
                    return .inside
                case .unknown:
                    return .unknown
                }
            }
        }
    }
}
