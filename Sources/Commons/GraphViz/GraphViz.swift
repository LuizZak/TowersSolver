import Foundation

/// Helper class for generating GraphViz visualizations of graphs.
public class GraphViz {
    public typealias NodeId = Int

    private var _nextId: Int = 0
    private var _rootGroup: Group

    public init() {
        _rootGroup = Group(title: nil, isCluster: false)
    }

    public func generateFile() -> String {
        let simplified = _rootGroup.simplify()

        let out = StringOutput()

        out(beginBlock: "digraph") {
            out(line: "graph [rankdir=LR]")
            out()

            var clusterCounter = 0
            simplified.generateGraph(in: out, clusterCounter: &clusterCounter)
        }

        return out.buffer.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public func nodeId(forLabel label: String) -> NodeId? {
        _rootGroup.findNodeId(label: label)
    }

    @discardableResult
    public func createNode(label: String, groups: [String] = []) -> NodeId {
        defer { _nextId += 1 }

        let id = _nextId

        let node = Node(id: id, label: label)
        
        _rootGroup.getOrCreateGroup(groups).addNode(node)

        return node.id
    }

    public func getOrCreate(label: String) -> NodeId {
        if let id = nodeId(forLabel: label) {
            return id
        }

        let id = createNode(label: label)

        return id
    }

    public func addConnection(fromLabel: String, toLabel: String, label: String? = nil, color: String? = nil) {
        let from = getOrCreate(label: fromLabel)
        let to = getOrCreate(label: toLabel)

        addConnection(from: from, to: to, label: label, color: color)
    }

    public func addConnection(from: NodeId, to: NodeId, label: String? = nil, color: String? = nil) {
        _rootGroup.addConnection(.init(idFrom: from, idTo: to, label: label, color: color))
    }

    private struct Node: Comparable {
        var id: NodeId
        var label: String

        static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.label < rhs.label
        }
    }

    private struct Connection: Comparable {
        var idFrom: NodeId
        var idTo: NodeId
        var label: String?
        var color: String?

        static func < (lhs: Self, rhs: Self) -> Bool {
            guard lhs.idTo == rhs.idTo else {
                return lhs.idTo < rhs.idTo
            }
            guard lhs.idFrom == rhs.idFrom else {
                return lhs.idFrom < rhs.idFrom
            }
            
            switch (lhs.label, rhs.label) {
            case (nil, nil):
                return false
            case (let a?, let b?):
                return a < b
            case (_?, _):
                return true
            case (_, _?):
                return false
            }
        }
    }

    /// A group of node definitions.
    private class Group {
        var title: String?
        var isCluster: Bool
        var subgroups: [Group] = []
        var nodes: [Node] = []
        var connections: [Connection] = []

        var isSingleGroup: Bool {
            subgroups.count == 1 && nodes.isEmpty && connections.isEmpty
        }
        var isSingleNode: Bool {
            subgroups.isEmpty && nodes.count == 1 && connections.isEmpty
        }

        weak var supergroup: Group?

        init(title: String?, isCluster: Bool) {
            self.title = title
            self.isCluster = isCluster
        }

        /// Recursively simplifies this group's hierarchy, returning the root of
        /// the new simplified hierarchy.
        func simplify() -> Group {
            if isSingleGroup {
                let group = subgroups[0].simplify()
                switch (title, group.title) {
                case (let t1?, let t2?):
                    group.title = "\(t1)/\(t2)"
                case (let t1?, nil):
                    group.title = t1
                default:
                    break
                }

                return group
            }

            let group = Group(title: title, isCluster: isCluster)
            group.nodes = nodes
            group.connections = connections

            for subgroup in subgroups {
                let newSubgroup = subgroup.simplify()

                if newSubgroup.isSingleNode {
                    group.nodes.append(newSubgroup.nodes[0])
                } else {
                    group.addSubgroup(newSubgroup)
                }
            }

            return group
        }

        func generateGraph(in out: StringOutput, clusterCounter: inout Int) {
            // If this group contains only a single subgroup, forward printing
            // to that group transparently, instead.
            if isSingleGroup {
                subgroups[0].generateGraph(in: out, clusterCounter: &clusterCounter)
                return
            }

            struct SpacerToken {
                var out: StringOutput
                var didApply: Bool = false

                mutating func apply() {
                    guard !didApply else { return }

                    out()
                }
            }

            var spacer: SpacerToken?

            if let title = title {
                out(line: #"label = "\#(title)""#)

                spacer = SpacerToken(out: out)
            }

            if !nodes.isEmpty {
                spacer?.apply()

                for node in nodes {
                    out(line: #"\#(node.id) [label="\#(node.label)"]"#)
                }

                spacer = SpacerToken(out: out)
            }

            if !subgroups.isEmpty {
                // Populate subgroups
                for group in subgroups {
                    spacer?.apply()
                    spacer = SpacerToken(out: out)

                    let name: String
                    if group.isCluster {
                        clusterCounter += 1
                        name = "cluster_\(clusterCounter)"
                    } else {
                        name = ""
                    }

                    out(beginBlock: "subgraph \(name)") {
                        group.generateGraph(in: out, clusterCounter: &clusterCounter)
                    }
                }
            }

            if !connections.isEmpty {
                spacer?.apply()

                for connection in connections.sorted() {
                    let conString = "\(connection.idFrom) -> \(connection.idTo)"
                    var properties: [(name: String, value: String)] = []

                    if let label = connection.label {
                        properties.append(("label", #""\#(label)""#))
                    }
                    if let color = connection.color {
                        properties.append(("color", color))
                    }

                    if !properties.isEmpty {
                        let propString = properties.map { "\($0.name)=\($0.value)" }.joined(separator: ", ")

                        out(line: conString + " [\(propString)]")
                    } else {
                        out(line: conString)
                    }
                }
            }
        }

        func findNode(id: NodeId) -> Node? {
            if let node = nodes.first(where: { $0.id == id }) {
                return node
            }

            for group in subgroups {
                if let node = group.findNode(id: id) {
                    return node
                }
            }

            return nil
        }

        func findNodeId(label: String) -> NodeId? {
            if let node = nodes.first(where: { $0.label == label }) {
                return node.id
            }

            for group in subgroups {
                if let id = group.findNodeId(label: label) {
                    return id
                }
            }

            return nil
        }

        func findConnection(from: NodeId, to: NodeId) -> Connection? {
            if let connection = connections.first(where: { $0.idFrom == from && $0.idTo == to }) {
                return connection
            }

            for group in subgroups {
                if let connection = group.findConnection(from: from, to: to) {
                    return connection
                }
            }

            return nil
        }

        func findGroupForNode(id: NodeId) -> Group? {
            if nodes.contains(where: { $0.id == id }) {
                return self
            }

            for group in subgroups {
                if let g = group.findGroupForNode(id: id) {
                    return g
                }
            }

            return nil
        }

        func getOrCreateGroup(_ path: [String]) -> Group {
            if path.isEmpty {
                return self
            }

            let next = path[0]
            let remaining = Array(path.dropFirst())

            for group in subgroups {
                if group.title == next {
                    return group.getOrCreateGroup(remaining)
                }
            }

            let group = Group(title: next, isCluster: true)
            addSubgroup(group)
            return group.getOrCreateGroup(remaining)
        }
        
        func addSubgroup(_ group: Group) {
            group.supergroup = self
            subgroups.append(group)
        }

        func addNode(_ node: Node) {
            nodes.append(node)
        }

        func addConnection(_ connection: Connection) {
            let target: Group

            let g1 = findGroupForNode(id: connection.idFrom)
            let g2 = findGroupForNode(id: connection.idTo)

            if let g1 = g1, let g2 = g2, let ancestor = Self.firstCommonAncestor(between: g1, g2) {
                target = ancestor
            } else {
                target = self
            }

            target.connections.append(connection)
        }

        func isDescendant(of view: Group) -> Bool {
            var parent: Group? = self
            while let p = parent {
                if p === view {
                    return true
                }
                parent = p.supergroup
            }

            return false
        }

        static func firstCommonAncestor(between group1: Group, _ group2: Group) -> Group? {
            if group1 === group2 {
                return group1
            }

            var parent: Group? = group1
            while let p = parent {
                if group2.isDescendant(of: p) {
                    return p
                }

                parent = p.supergroup
            }

            return nil
        }
    }
}

/// Outputs to a string buffer
private final class StringOutput {
    var indentDepth: Int = 0
    var ignoreCallChange = false
    private(set) public var buffer: String = ""
    
    init() {
        
    }

    func callAsFunction() {
        output(line: "")
    }

    func callAsFunction(line: String) {
        output(line: line)
    }

    func callAsFunction(lineAndIndent line: String, _ block: () -> Void) {
        output(line: line)
        indented(perform: block)
    }

    func callAsFunction(beginBlock line: String, _ block: () -> Void) {
        output(line: "\(line) {")
        indented(perform: block)
        output(line: "}")
    }
    
    func outputRaw(_ text: String) {
        buffer += text
    }
    
    func output(line: String) {
        if !line.isEmpty {
            outputIndentation()
            buffer += line
        }
        
        outputLineFeed()
    }
    
    func outputIndentation() {
        buffer += indentString()
    }
    
    func outputLineFeed() {
        buffer += "\n"
    }
    
    func outputInline(_ content: String) {
        buffer += content
    }
    
    func increaseIndentation() {
        indentDepth += 1
    }
    
    func decreaseIndentation() {
        guard indentDepth > 0 else { return }
        
        indentDepth -= 1
    }
    
    func outputInlineWithSpace(_ content: String) {
        outputInline(content)
        outputInline(" ")
    }
    
    func indented(perform block: () -> Void) {
        increaseIndentation()
        block()
        decreaseIndentation()
    }
    
    private func indentString() -> String {
        return String(repeating: " ", count: 4 * indentDepth)
    }
}
