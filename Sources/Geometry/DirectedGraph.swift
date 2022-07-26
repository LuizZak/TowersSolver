/// A protocol for representing directed graphs
public protocol DirectedGraph {
    typealias VisitElement = DirectedGraphVisitElement<Edge, Node>

    associatedtype Edge: DirectedGraphEdge
    associatedtype Node: DirectedGraphNode
    
    /// Gets a list of all nodes in this directed graph
    var nodes: [Node] { get }
    /// Gets a list of all edges in this directed graph
    var edges: [Edge] { get }
    
    /// Returns `true` iff two edges are equivalent (i.e. have the same start/end
    /// nodes).
    @inlinable
    func areEdgesEqual(_ edge1: Edge, _ edge2: Edge) -> Bool
    
    /// Returns `true` iff two node references represent the same underlying node
    /// in this graph.
    @inlinable
    func areNodesEqual(_ node1: Node, _ node2: Node) -> Bool
    
    /// Returns the starting edge for a given node on this graph.
    @inlinable
    func startNode(for edge: Edge) -> Node
    
    /// Returns the ending edge for a given node on this graph.
    @inlinable
    func endNode(for edge: Edge) -> Node
    
    /// Returns all ingoing and outgoing edges for a given directed graph node.
    ///
    /// A reference equality test (===) is used to determine graph node equality.
    @inlinable
    func allEdges(for node: Node) -> [Edge]
    
    /// Returns all outgoing edges for a given directed graph node.
    ///
    /// A reference equality test (===) is used to determine graph node equality.
    @inlinable
    func edges(from node: Node) -> [Edge]
    
    /// Returns all ingoing edges for a given directed graph node.
    ///
    /// A reference equality test (===) is used to determine graph node equality.
    @inlinable
    func edges(towards node: Node) -> [Edge]
    
    /// Returns an existing edge between two nodes, or `nil`, if no edges between
    /// them currently exist.
    ///
    /// A reference equality test (===) is used to determine graph node equality.
    @inlinable
    func edge(from start: Node, to end: Node) -> Edge?
    
    /// Returns all graph nodes that are connected from a given directed graph
    /// node.
    ///
    /// A reference equality test (===) is used to determine graph node equality.
    @inlinable
    func nodesConnected(from node: Node) -> [Node]
    
    /// Returns all graph nodes that are connected towards a given directed graph
    /// node.
    ///
    /// A reference equality test (===) is used to determine graph node equality.
    @inlinable
    func nodesConnected(towards node: Node) -> [Node]
    
    /// Returns all graph nodes that are connected towards and from the given
    /// graph node.
    ///
    /// A reference equality test (===) is used to determine graph node equality.
    @inlinable
    func allNodesConnected(to node: Node) -> [Node]

    /// Returns true if there exists an edge that connects two nodes on the
    /// specified direction.
    @inlinable
    func hasEdge(from start: Node, to end: Node) -> Bool
    
    /// Performs a depth-first visiting of this directed graph, finishing once
    /// all nodes are visited, or when `visitor` returns false.
    @inlinable
    func depthFirstVisit(start: Node, _ visitor: (VisitElement) -> Bool)
    
    /// Performs a breadth-first visiting of this directed graph, finishing once
    /// all nodes are visited, or when `visitor` returns false.
    @inlinable
    func breadthFirstVisit(start: Node, _ visitor: (VisitElement) -> Bool)
}

/// Element for a graph visiting operation.
///
/// - start: The item represents the start of a visit.
/// - edge: The item represents an edge, pointing to a node of the graph. Also
/// contains information about the path leading up to that edge.
public enum DirectedGraphVisitElement<E, N> {
    case start(N)
    indirect case edge(E, from: Self, towards: N)
    
    /// Gets the node at the end of this visit element.
    public var node: N {
        switch self {
        case .start(let node),
             .edge(_, _, let node):
            return node
        }
    }

    /// Gets an array of all nodes from this visit element.
    public var allNodes: [N] {
        switch self {
        case .start(let node):
            return [node]
        case .edge(_, let from, let node):
            return from.allNodes + [node]
        }
    }

    /// Returns the length of the path represented by this visit element.
    ///
    /// Lengths start at 1 from `.start()`, and increase by one for every nested
    /// element in `.edge()`.
    public var length: Int {
        switch self {
        case .start:
            return 1
        case .edge(_, let from, _):
            return 1 + from.length
        }
    }
}

public extension DirectedGraph {
    @inlinable
    func areEdgesEqual(_ edge1: Edge, _ edge2: Edge) -> Bool {
        areNodesEqual(startNode(for: edge1), startNode(for: edge2))
            && areNodesEqual(endNode(for: edge1), endNode(for: edge2))
    }
    
    @inlinable
    func allEdges(for node: Node) -> [Edge] {
        edges(towards: node) + edges(from: node)
    }
    
    @inlinable
    func nodesConnected(from node: Node) -> [Node] {
        edges(from: node).map(self.endNode(for:))
    }
    
    @inlinable
    func nodesConnected(towards node: Node) -> [Node] {
        edges(towards: node).map(self.startNode(for:))
    }
    
    @inlinable
    func allNodesConnected(to node: Node) -> [Node] {
        nodesConnected(towards: node) + nodesConnected(from: node)
    }
    
    @inlinable
    func hasEdge(from start: Node, to end: Node) -> Bool {
        return edge(from: start, to: end) != nil
    }
    
    /// Performs a depth-first visiting of this directed graph, finishing once
    /// all nodes are visited, or when `visitor` returns false.
    @inlinable
    func depthFirstVisit(start: Node, _ visitor: (VisitElement) -> Bool) {
        var visited: Set<Node> = []
        var queue: [VisitElement] = []
        
        queue.append(.start(start))
        
        while let next = queue.popLast() {
            visited.insert(next.node)
            
            if !visitor(next) {
                return
            }
            
            for nextEdge in edges(from: next.node) {
                let node = endNode(for: nextEdge)
                if visited.contains(node) {
                    continue
                }
                
                queue.append(.edge(nextEdge, from: next, towards: node))
            }
        }
    }
    
    /// Performs a breadth-first visiting of this directed graph, finishing once
    /// all nodes are visited, or when `visitor` returns false.
    @inlinable
    func breadthFirstVisit(start: Node, _ visitor: (VisitElement) -> Bool) {
        var visited: Set<Node> = []
        var queue: [VisitElement] = []
        
        queue.append(.start(start))
        
        while !queue.isEmpty {
            let next = queue.removeFirst()
            visited.insert(next.node)
            
            if !visitor(next) {
                return
            }
            
            for nextEdge in edges(from: next.node) {
                let node = endNode(for: nextEdge)
                if visited.contains(node) {
                    continue
                }
                
                queue.append(.edge(nextEdge, from: next, towards: node))
            }
        }
    }
}

public extension DirectedGraph {
    /// Returns a list which represents the [topologically sorted](https://en.wikipedia.org/wiki/Topological_sorting)
    /// nodes of this graph.
    ///
    /// Returns nil, in case it cannot be topologically sorted, e.g. when any
    /// cycles are found.
    ///
    /// - Returns: A list of the nodes from this graph, topologically sorted, or
    /// `nil`, in case it cannot be sorted.
    @inlinable
    func topologicalSorted() -> [Node]? {
        var permanentMark: Set<Node> = []
        var temporaryMark: Set<Node> = []
        
        var unmarkedNodes: [Node] = nodes
        var list: [Node] = []
        
        func visit(_ node: Node) -> Bool {
            if permanentMark.contains(node) {
                return true
            }
            if temporaryMark.contains(node) {
                return false
            }
            temporaryMark.insert(node)
            for next in nodesConnected(from: node) {
                if !visit(next) {
                    return false
                }
            }
            permanentMark.insert(node)
            list.insert(node, at: 0)
            return true
        }
        
        while let node = unmarkedNodes.popLast() {
            if !visit(node) {
                return nil
            }
        }
        
        return list
    }
    
    /// Returns true if there exists a path in this graph that connect two given
    /// nodes.
    ///
    /// In case the two nodes are not connected, or are connected in the opposite
    /// direction, false is returned.
    @inlinable
    func hasPath(from start: Node, to end: Node) -> Bool {
        var found = false
        breadthFirstVisit(start: start) { visit in
            if visit.node == end {
                found = true
                return false
            }
            
            return true
        }
        
        return found
    }
    
    /// Returns all possible paths found between two nodes.
    ///
    /// If `start == end`, `[start]` is returned.
    ///
    /// Note that the results of this method are only valid for acyclic graphs.
    ///
    /// In case the two nodes are not connected, or are connected in the opposite
    /// direction, `nil` is returned.
    ///
    /// A closure is used to provide fine-grained control over which visits should
    /// be considered.
    @inlinable
    func allPaths(from start: Node, to end: Node, confirmVisit: (VisitElement) -> Bool) -> [[Node]] {
        typealias State = (visited: Set<Node>, next: VisitElement)

        var paths: [[Node]] = []

        var states: [State] = [
            ([], .start(start))
        ]

        while !states.isEmpty {
            var state = states.removeFirst()

            let next = state.next

            if next.node == end {
                paths.append(next.allNodes)
            }

            state.visited.insert(next.node)
            
            for nextEdge in edges(from: next.node) {
                let node = endNode(for: nextEdge)
                if state.visited.contains(node) {
                    continue
                }

                let nextVisit = VisitElement.edge(nextEdge, from: next, towards: node)
                
                if !confirmVisit(nextVisit) {
                    continue
                }
                
                var newState = state
                newState.next = nextVisit
                states.append(newState)
            }
        }

        return paths
    }
    
    /// Returns the first path found between two nodes.
    ///
    /// If `start == end`, `[start]` is returned.
    ///
    /// In case the two nodes are not connected, or are connected in the opposite
    /// direction, `nil` is returned.
    @inlinable
    func firstPath(from start: Node, to end: Node) -> [Node]? {
        var path: VisitElement?

        breadthFirstVisit(start: start) { visit in
            if visit.node == end {
                path = visit
                return false
            }
            
            return true
        }
        
        return path?.allNodes
    }
    
    /// Returns any of the shortest paths found between two nodes.
    ///
    /// If `start == end`, `[start]` is returned.
    ///
    /// In case the two nodes are not connected, or are connected in the opposite
    /// direction, `nil` is returned.
    @inlinable
    func shortestPath(from start: Node, to end: Node) -> [Node]? {
        var paths: [[Node]] = []

        breadthFirstVisit(start: start) { visit in
            if visit.node == end {
                paths.append(visit.allNodes)
            }
            
            return true
        }
        
        if paths.isEmpty {
            return []
        }

        return paths.sorted(by: { $0.count < $1.count }).first
    }
}

/// A protocol for representing a directed graph's edge
public protocol DirectedGraphEdge: Hashable {
    
}

/// A protocol for representing a directed graph's node
public protocol DirectedGraphNode: Hashable {
    
}

public extension DirectedGraphEdge where Self: AnyObject {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs === rhs
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

public extension DirectedGraphNode where Self: AnyObject {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs === rhs
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
