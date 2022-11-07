public struct PriorityQueue<T: PriorityQueueElement> {
    var storage: [T]
    
    public init() {
        self.storage = []
    }
    
    public mutating func enqueue(_ element: T) {
        let index = storage.binarySearchInsert(value: element, transform: { -$0.priority })
        
        storage.insert(element, at: index)
    }
    
    public mutating func dequeue() -> T? {
        guard !storage.isEmpty else {
            return nil
        }
        
        return storage.removeFirst()
    }
}

/// An element of a ``PriorityQueue``
public protocol PriorityQueueElement {
    /// The priority of this element
    ///
    /// Element priority should not change throught the lifetime of the object.
    var priority: Int { get }
}
