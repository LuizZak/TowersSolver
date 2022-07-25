import XCTest

@testable import NetSolver

class BaseSolverStepTestClass: XCTestCase {
    var mockDelegate: MockNetSolverDelegate!

    override func setUp() {
        super.setUp()

        mockDelegate = MockNetSolverDelegate()
    }

    override func tearDown() {
        super.tearDown()

        mockDelegate = nil
    }

    func assertEnqueuedNone(file: StaticString = #file, line: UInt = #line) {
        guard !mockDelegate.didCallEnqueue.isEmpty else {
            return
        }

        XCTFail(
            """
            Expected no solver steps enqueued, but \(mockDelegate.didCallEnqueue.count) steps where found:

            \(mockDelegate.didCallEnqueue.map(String.init(describing:)).joined(separator: "\n"))
            """,
            file: file,
            line: line
        )
    }

    func assertEnqueued<Step: NetSolverStep & Equatable>(
        _ step: Step,
        file: StaticString = #file,
        line: UInt = #line
    ) {

        guard !mockDelegate.didCallEnqueue.isEmpty else {
            XCTFail(
                """
                Expected solver step \(step) is not enqueued.
                0 steps are currently enqueued.
                """,
                file: file,
                line: line
            )
            return
        }

        for s in mockDelegate.didCallEnqueue {
            if s as? Step == step {
                return
            }
        }

        XCTFail(
            """
            Expected solver step \(step) to be present, but isn't.
            \(mockDelegate.didCallEnqueue.count) steps are currently enqueued:

            \(mockDelegate.didCallEnqueue.map(String.init(describing:)).joined(separator: "\n"))
            """,
            file: file,
            line: line
        )
    }

    func assertOrientation(
        of tile: Tile,
        oneOf orientations: Set<Tile.Orientation>,
        file: StaticString = #file,
        line: UInt = #line
    ) {

        XCTAssertTrue(
            orientations.contains(tile.orientation),
            """
            Expected either \
            [\(orientations.map(String.init(describing:)).joined(separator: ", "))] \
            but result is '\(tile.orientation)'
            """,
            file: file,
            line: line
        )
    }
}
