import Foundation

/// Basic stopwatch for timing operations
class Stopwatch {
    typealias Seconds = Float

    private let start: clock_t
    private var end: clock_t?

    var isRunning: Bool {
        end == nil
    }

    var interval: Seconds {
        let duration = (end ?? clock()) - start

        return Float(duration) / Float(CLOCKS_PER_SEC)
    }

    /// Returns an interval string, in seconds, with two decimal places for the
    /// milliseconds.
    var intervalString: String {
        "\(String(format: "%.2f", interval))s"
    }

    private init() {
        self.start = clock()
    }

    @discardableResult
    func stop() -> Seconds {
        let now = clock()

        if isRunning {
            end = now
        }

        return interval
    }

    static func startNew() -> Stopwatch {
        return Stopwatch()
    }

    static func timing(_ operation: () throws -> Void) rethrows -> Stopwatch {
        let timer = startNew()
        defer {
            timer.stop()
        }
        
        try operation()

        return timer
    }
}
