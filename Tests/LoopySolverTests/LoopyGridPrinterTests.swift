import Console
import Geometry
import XCTest

@testable import LoopySolver

class LoopyGridPrinterTests: XCTestCase {
    private var target: TestConsolePrintTarget!

    override func setUp() {
        super.setUp()

        target = TestConsolePrintTarget()
    }

    func testPrintEdgeIndices() {
        let generator = LoopySquareGridGen(width: 6, height: 6)
        generator.setHint(x: 1, y: 1, hint: 1)
        generator.setHint(x: 2, y: 3, hint: 3)
        generator.setHint(x: 0, y: 4, hint: 0)
        let grid = generator.generate()
        let controller = LoopyGridController(grid: grid)
        controller.setEdges(state: .disabled, forFace: 0)
        let printer = LoopyGridPrinter(bufferWidth: 120, bufferHeight: 60)
        printer.printEdgeIndices = true
        printer.target = target

        printer.printGrid(grid: controller.grid, width: 36, height: 24)

        assertPrintEquals(
            """
            •  0  •──4──•──7──•─10──•─13──•─16──•
                        │     │     │     │     │
            3     1     5     8    11    14    17
                        │     │     │     │     │
            •  2  •──6──•──9──•─12──•─15──•─18──•
            │     │     │     │     │     │     │
            1    19  1 22    24    26    28    30
            │     │     │     │     │     │     │
            •─20──•─23──•─25──•─27──•─29──•─31──•
            │     │     │     │     │     │     │
            4    32    35    37    39    41    43
            │     │     │     │     │     │     │
            •─33──•─36──•─38──•─40──•─42──•─44──•
            │     │     │     │     │     │     │
            7    45    48  3 50    52    54    56
            │     │     │     │     │     │     │
            •─46──•─49──•─51──•─53──•─55──•─57──•
            │     │     │     │     │     │     │
            0  0 58    61    63    65    67    69
            │     │     │     │     │     │     │
            •─59──•─62──•─64──•─66──•─68──•─70──•
            │     │     │     │     │     │     │
            3    71    74    76    78    80    82
            │     │     │     │     │     │     │
            •─72──•─75──•─77──•─79──•─81──•─83──•
            """
        )
    }

    func testPrintFaceIndices() {
        let generator = LoopySquareGridGen(width: 6, height: 6)
        generator.setHint(x: 1, y: 1, hint: 1)
        generator.setHint(x: 2, y: 3, hint: 3)
        generator.setHint(x: 0, y: 4, hint: 0)
        let grid = generator.generate()
        let controller = LoopyGridController(grid: grid)
        controller.setEdges(state: .disabled, forFace: 0)
        let printer = LoopyGridPrinter(bufferWidth: 120, bufferHeight: 60)
        printer.printFaceIndices = true
        printer.target = target

        printer.printGrid(grid: controller.grid, width: 72, height: 24)

        assertPrintEquals(
            """
            •           •───────────•───────────•───────────•───────────•───────────•
                                    │           │           │           │           │
                  0           1     │     2     │     3     │     4     │     5     │
                                    │           │           │           │           │
            •           •───────────•───────────•───────────•───────────•───────────•
            │           │           │           │           │           │           │
            │     6     │     7 [1] │     8     │     9     │     10    │     11    │
            │           │           │           │           │           │           │
            •───────────•───────────•───────────•───────────•───────────•───────────•
            │           │           │           │           │           │           │
            │     12    │     13    │     14    │     15    │     16    │     17    │
            │           │           │           │           │           │           │
            •───────────•───────────•───────────•───────────•───────────•───────────•
            │           │           │           │           │           │           │
            │     18    │     19    │     20 [3]│     21    │     22    │     23    │
            │           │           │           │           │           │           │
            •───────────•───────────•───────────•───────────•───────────•───────────•
            │           │           │           │           │           │           │
            │     24 [0]│     25    │     26    │     27    │     28    │     29    │
            │           │           │           │           │           │           │
            •───────────•───────────•───────────•───────────•───────────•───────────•
            │           │           │           │           │           │           │
            │     30    │     31    │     32    │     33    │     34    │     35    │
            │           │           │           │           │           │           │
            •───────────•───────────•───────────•───────────•───────────•───────────•
            """
        )
    }

    func testPrintPolygon() {
        var grid = LoopyGrid()
        grid.addVertex(Vertex(x: 0, y: 0))
        grid.addVertex(Vertex(x: 50, y: 19))
        grid.addVertex(Vertex(x: 88, y: 47))
        grid.addVertex(Vertex(x: 31, y: 112))
        grid.addVertex(Vertex(x: 423, y: 221))
        grid.addVertex(Vertex(x: 197, y: 249))
        grid.createFace(withVertexIndices: [0, 1, 3], hint: nil)
        grid.createFace(withVertexIndices: [1, 2, 3], hint: 3)
        grid.createFace(withVertexIndices: [2, 4, 3], hint: 1)
        grid.createFace(withVertexIndices: [3, 5, 4], hint: nil)
        let printer = LoopyGridPrinter(bufferWidth: 120, bufferHeight: 60)
        printer.target = target

        printer.printGrid(grid: grid)

        assertPrintEquals(
            """
            •╲
            \\ ╲╲╲
             \\   ╲╲╲╲
             \\       ╲╲╲
             \\          ╲•
              \\          │╲╲
              \\          │  ╲
              \\         │    ╲╲
              \\         │      ╲╲
               \\        │        ╲
               \\        │         ╲╲
               \\       │            •╲
                \\      │           ╱  ╲╲
                \\      │          ╱     ╲╲
                \\      │   3     ╱        ╲╲╲
                 \\    │         ╱            ╲╲
                 \\    │        ╱               ╲╲
                 \\    │       ╱                  ╲╲
                  \\   │     ╱╱                     ╲╲╲
                  \\   │    ╱                          ╲╲
                  \\  │    ╱                             ╲╲
                  \\  │   ╱                                ╲╲╲
                   \\ │  ╱                                    ╲╲
                   \\ │ ╱                                       ╲╲
                   \\│ ╱                                          ╲╲
                    \\╱                                             ╲╲╲
                    •──                                               ╲╲
                     ╲╲────                                             ╲╲
                       ╲   ────                                           ╲╲╲
                        ╲      ────                                          ╲╲
                         ╲╲        ─────                      1                ╲╲
                           ╲            ────                                     ╲╲
                            ╲╲              ────                                   ╲╲╲
                              ╲                 ────                                  ╲╲
                               ╲                    ────                                ╲╲
                                ╲╲                      ─────                             ╲╲╲
                                  ╲                          ────                            ╲╲
                                   ╲╲                            ────                          ╲╲
                                     ╲                               ────                        ╲╲╲
                                      ╲                                  ─────                      ╲╲
                                       ╲╲                                     ────                    ╲╲
                                         ╲                                        ────                  ╲╲
                                          ╲                                           ────                ╲╲╲
                                           ╲╲                                             ─────              ╲╲
                                             ╲                                                 ────            ╲╲
                                              ╲╲                                                   ────          ╲╲╲
                                                ╲                                                      ────         ╲╲
                                                 ╲                                                         ────       ╲╲
                                                  ╲╲                                                           ─────    ╲╲
                                                    ╲                                                               ────  ╲╲╲
                                                     ╲╲                                                                 ──── ╲╲
                                                       ╲                                                                    ────╲
                                                        ╲                                                                     ────•
                                                         ╲╲                                                          ─────────
                                                           ╲                                                ─────────
                                                            ╲╲                                    ──────────
                                                              ╲                          ─────────
                                                               ╲                ─────────
                                                                ╲╲     ─────────
                                                                  •────
            """
        )
    }

    func testPrintSquareGrid() {
        let generator = LoopySquareGridGen(width: 6, height: 6)
        generator.setHint(x: 1, y: 1, hint: 1)
        generator.setHint(x: 2, y: 3, hint: 3)
        generator.setHint(x: 0, y: 4, hint: 0)
        let grid = generator.generate()
        let controller = LoopyGridController(grid: grid)
        controller.setEdges(state: .disabled, forFace: 0)
        let printer = LoopyGridPrinter(bufferWidth: 120, bufferHeight: 60)
        printer.target = target

        printer.printGrid(grid: controller.grid, width: 60, height: 30)

        assertPrintEquals(
            """
            •         •─────────•─────────•─────────•─────────•─────────•
                                │         │         │         │         │
                                │         │         │         │         │
                                │         │         │         │         │
                                │         │         │         │         │
            •         •─────────•─────────•─────────•─────────•─────────•
            │         │         │         │         │         │         │
            │         │    1    │         │         │         │         │
            │         │         │         │         │         │         │
            │         │         │         │         │         │         │
            •─────────•─────────•─────────•─────────•─────────•─────────•
            │         │         │         │         │         │         │
            │         │         │         │         │         │         │
            │         │         │         │         │         │         │
            │         │         │         │         │         │         │
            •─────────•─────────•─────────•─────────•─────────•─────────•
            │         │         │         │         │         │         │
            │         │         │    3    │         │         │         │
            │         │         │         │         │         │         │
            │         │         │         │         │         │         │
            •─────────•─────────•─────────•─────────•─────────•─────────•
            │         │         │         │         │         │         │
            │    0    │         │         │         │         │         │
            │         │         │         │         │         │         │
            │         │         │         │         │         │         │
            •─────────•─────────•─────────•─────────•─────────•─────────•
            │         │         │         │         │         │         │
            │         │         │         │         │         │         │
            │         │         │         │         │         │         │
            │         │         │         │         │         │         │
            •─────────•─────────•─────────•─────────•─────────•─────────•
            """
        )
    }

    func testPrintHoneycombGrid() {
        let generator = LoopyHoneycombGridGenerator(width: 6, height: 6)
        generator.setHint(faceIndex: 0, hint: 1)
        generator.setHint(faceIndex: 1, hint: 3)
        generator.setHint(faceIndex: 2, hint: 0)
        let grid = generator.generate()
        let controller = LoopyGridController(grid: grid)
        controller.setEdges(state: .disabled, forFace: 0)
        let printer = LoopyGridPrinter(bufferWidth: 120, bufferHeight: 60)
        printer.target = target

        printer.printGrid(grid: controller.grid, width: 38, height: 26)

        assertPrintEquals(
            """
              •   •       •───•       •───•
                         /     \\     /     \\
            •   1   •───•   0   •───•       •───•
                         \\     /     \\     /     \\
              •   •   3   •───•       •───•       •
             /     \\     /     \\     /     \\     /
            •       •───•       •───•       •───•
             \\     /     \\     /     \\     /     \\
              •───•       •───•       •───•       •
             /     \\     /     \\     /     \\     /
            •       •───•       •───•       •───•
             \\     /     \\     /     \\     /     \\
              •───•       •───•       •───•       •
             /     \\     /     \\     /     \\     /
            •       •───•       •───•       •───•
             \\     /     \\     /     \\     /     \\
              •───•       •───•       •───•       •
             /     \\     /     \\     /     \\     /
            •       •───•       •───•       •───•
             \\     /     \\     /     \\     /     \\
              •───•       •───•       •───•       •
             /     \\     /     \\     /     \\     /
            •       •───•       •───•       •───•
             \\     /     \\     /     \\     /     \\
              •───•       •───•       •───•       •
                   \\     /     \\     /     \\     /
                    •───•       •───•       •───•
            """
        )
    }
}

extension LoopyGridPrinterTests {

    fileprivate func assertPrintEquals(_ expected: String, line: UInt = #line) {
        // Strip trailing whitespace (except newlines) and lines which are only
        // whitespace (including newline)
        let actual = target.buffer
            .split(separator: "\n")
            .compactMap { line -> String? in
                let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.isEmpty {
                    return nil
                }

                let leading = line.prefix(while: { $0 == " " || $0 == "\t" })

                return leading + trimmed
            }
            .joined(separator: "\n")

        if actual != expected {
            XCTFail(
                "\(actual)\n\nis not equal to expected\n\n\(expected)",
                file: #filePath,
                line: line
            )
        }
    }
}

private class TestConsolePrintTarget: ConsolePrintTarget {
    let supportsTerminalColors = false

    var buffer: String = ""

    func print(_ values: [Any], separator: String, terminator: String) {
        let total = values.map { String(describing: $0) }.joined(separator: separator)

        Swift.print(total, terminator: terminator, to: &buffer)
    }
}
