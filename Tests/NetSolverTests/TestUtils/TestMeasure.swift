import XCTest

extension XCTestCase {
    func doMeasure(block: () -> Void) {
        #if os(macOS)

            measure(metrics: [XCTClockMetric(), XCTMemoryMetric()], for: block)

        #else

            measure(block: block)

        #endif
    }
}
