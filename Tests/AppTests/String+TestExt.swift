import XCTest

/// Asserts that two multi-line strings match after stripping leading/trailing
/// whitespace lines, as well as whitespace trailing each line.
func assertMultilineMatches(
    _ actual: String,
    _ expected: String,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    func fail(_ message: String) {
        XCTFail(
            message,
            file: file,
            line: line
        )
    }

    // Split by lines, trimming whitespace lines along the way
    let actualLines = actual.splitLines().trimmingWhitespace()
    let expectedLines = expected.splitLines().trimmingWhitespace()

    if actualLines.count != expectedLines.count {
        fail("(\(actual)) is not equal to (\(expected))")

        return
    }

    guard let index = firstMismatchedLineIndex(actualLines, expectedLines) else {
        return
    }

    let actualLine = actualLines[index]
    let expectedLine = expectedLines[index]

    fail(
        """
        ("\(actual)") is not equal to ("\(expected)")

        Line at index \(line) does not match:
        ("\(actualLine)") vs ("\(expectedLine)")
        """
    )
}

/// Asserts that a multi-line string contains a contiguous sub-sequence of lines
/// that match the expected string.
func assertMultilineContains(
    _ actual: String,
    _ expected: String,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    func fail(_ message: String) {
        XCTFail(
            message,
            file: file,
            line: line
        )
    }

    let actualLines = actual.splitLines().trimmingWhitespace()
    let expectedLines = expected.splitLines().trimmingWhitespace()

    if actualLines.isEmpty && expectedLines.isEmpty {
        return
    }
    if expectedLines.isEmpty {
        fail("Expected one or more non-whitespace line in 'expectedLines'")
        return
    }

    // Find indices to start comparing the two collections from
    let matches = actualLines.indices.filter {
        actualLines[$0] == expectedLines[0]
    }

    for match in matches {
        guard let endIndex = actualLines.index(match, offsetBy: expectedLines.count, limitedBy: actualLines.endIndex) else {
            continue
        }

        let slice = actualLines[match..<endIndex]
        
        if firstMismatchedLineIndex(slice, expectedLines) == nil {
            // Success!
            return
        }
    }

    fail(
        """
        ("\(actual)") does not contain subsequence of lines ("\(expected)")
        """
    )
}

private func assertLinesMatch(
    _ actualLines: [Substring],
    _ expectedLines: [Substring],
    errorMessagePrefix: String,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    func fail(_ message: String) {
        XCTFail(
            message,
            file: file,
            line: line
        )
    }

    guard let index = firstMismatchedLineIndex(actualLines, expectedLines) else {
        return
    }

    let actualLine = actualLines[index]
    let expectedLine = expectedLines[index]

    fail(
        """
        \(errorMessagePrefix)

        Line at index \(line) does not match:
        ("\(actualLine)") vs ("\(expectedLine)")
        """
    )
}

/// If two sequences of lines do not match after trimming trailing whitespace,
/// returns the index of the first non-matching index in the sequences.
///
/// - precondition: `actualLines.count == expectedLines.count`
private func firstMismatchedLineIndex<C: Collection>(
    _ actualLines: C,
    _ expectedLines: C
) -> Int? where C.Element == Substring {
    
    precondition(actualLines.count == expectedLines.count)

    for (line, (actualLine, expectedLine)) in zip(actualLines, expectedLines).enumerated() {
        let actualTrimmed = actualLine.trailingTrimmed()
        let expectedTrimmed = expectedLine.trailingTrimmed()

        if actualTrimmed == expectedTrimmed {
            continue
        }

        return line
    }

    return nil
}

// MARK: - Extensions

extension String {
    func splitLines() -> [Substring] {
        self.split(separator: "\n")
    }
}

extension Substring {
    func trimmed() -> Self {
        let isWhitespace = CharacterSet.whitespacesAndNewlines.contains

        let start = self.firstIndex {
            !$0.unicodeScalars.contains(where: isWhitespace)
        }
        let end = self.lastIndex {
            !$0.unicodeScalars.contains(where: isWhitespace)
        }

        guard let start = start, let end = end else {
            return self
        }

        return self[start...end]
    }

    func trailingTrimmed() -> Self {
        let isWhitespace = CharacterSet.whitespacesAndNewlines.contains

        let end = self.lastIndex {
            !$0.unicodeScalars.contains(where: isWhitespace)
        }

        guard let end = end else {
            return self
        }

        return self[...end]
    }
}

extension Array where Element == Substring {
    func trimmingWhitespace() -> ArraySlice<Substring> {
        let start = self.firstIndex {
            !$0.trimmed().isEmpty
        }
        let end = self.lastIndex {
            !$0.trimmed().isEmpty
        }

        guard let start = start, let end = end else {
            return []
        }

        return self[start...end]
    }
}
