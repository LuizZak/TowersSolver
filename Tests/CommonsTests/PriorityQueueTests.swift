import XCTest
@testable import Commons

class PriorityQueueTests: XCTestCase {
    func testEnqueue_emptyQueue() {
        var queue = PriorityQueue<TestQueueElement>()
        
        queue.enqueue(.init(priority: 0))
        
        XCTAssertEqual(queue.storage, [.init(priority: 0)])
    }
    
    func testEnqueue_lowPriorityElement() {
        var queue = PriorityQueue<TestQueueElement>()
        queue.storage = [.init(priority: 2), .init(priority: 1)]
        
        queue.enqueue(.init(priority: 0))
        
        XCTAssertEqual(queue.storage, [
            .init(priority: 2),
            .init(priority: 1),
            .init(priority: 0)
        ])
    }
    
    func testEnqueue_highPriorityElement() {
        var queue = PriorityQueue<TestQueueElement>()
        queue.storage = [.init(priority: 1), .init(priority: 0)]
        
        queue.enqueue(.init(priority: 2))
        
        XCTAssertEqual(queue.storage, [
            .init(priority: 2),
            .init(priority: 1),
            .init(priority: 0)
        ])
    }
    
    func testDequeue_emptyQueue() {
        var queue = PriorityQueue<TestQueueElement>()
        
        XCTAssertNil(queue.dequeue())
    }
    
    func test_priorityQueue_roundtrip() {
        var queue = PriorityQueue<TestQueueElement>()
        
        queue.enqueue(.init(priority: 2))
        queue.enqueue(.init(priority: 0))
        queue.enqueue(.init(priority: 1))
        
        XCTAssertEqual(queue.dequeue()?.priority, 2)
        XCTAssertEqual(queue.dequeue()?.priority, 1)
        XCTAssertEqual(queue.dequeue()?.priority, 0)
    }
}

private struct TestQueueElement: PriorityQueueElement, Equatable {
    var priority: Int
}
