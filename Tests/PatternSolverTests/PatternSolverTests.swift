import XCTest

@testable import PatternSolver

class PatternSolverTests: XCTestCase {
    func testSolve_5x5() throws {
        // Game available at:
        // https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/pattern.html#5x5:1/2/1.1/2.2/2.2/4/1.2/1/2/3
        let gen = try PatternGridGenerator(gameId: "5x5:1/2/1.1/2.2/2.2/4/1.2/1/2/3")
        let sut = PatternSolver(grid: gen.grid)

        XCTAssertEqual(sut.solve(), .solved)

        assertStatesMatch(
            sut.grid, [
                0b01111,
                0b01011,
                0b10000,
                0b00011,
                0b00111,
            ]
        )

        printGrid(sut.grid)
    }
    
    func testSolve_10x10() throws {
        // Game available at:
        // https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/pattern.html#10x10:5/5/4/4.5/3.3.1/1.3/2.2/6/2.1.1/2/5.4/5.4/5.1/4.1.1/2.2/6/3/3/1/2.1
        let gen = try PatternGridGenerator(gameId: """
            10x10:5/5/4/4.5/3.3.1/1.3/2.2/6/2.1.1/2/5.4/5.4/5.1/4.1.1/2.2/6/3/3\
            /1/2.1
            """)
        let sut = PatternSolver(grid: gen.grid)

        XCTAssertEqual(sut.solve(), .solved)

        assertStatesMatch(
            sut.grid, [
                0b11111_01111,
                0b11111_01111,
                0b11111_00100,
                0b11110_10100,
                0b11000_01100,
                //
                0b00011_11110,
                0b00011_10000,
                0b00011_10000,
                0b00010_00000,
                0b00011_00010,
            ]
        )

        printGrid(sut.grid)
    }

    func testSolve_15x15() throws {
        // Game available at:
        // https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/pattern.html#15x15:3.6/6/1.1.1.3/1.5.1.2/10.3/9.3/6.3/9.2/4.1.1/3.4/1.4/1.5/1.1.1/1.2.2/3.2/1.5/1.6.3/1.6/7.1/5/6/3.1.2/4.1.2/3.1.2.1/5.3/2.3.2/2.2.7/3.3.1/8.1/4.3.1

        let gen = try PatternGridGenerator(gameId: """
            15x15:3.6/6/1.1.1.3/1.5.1.2/10.3/9.3/6.3/9.2/4.1.1/3.4/1.4/1.5/\
            1.1.1/1.2.2/3.2/1.5/1.6.3/1.6/7.1/5/6/3.1.2/4.1.2/3.1.2.1/5.3/\
            2.3.2/2.2.7/3.3.1/8.1/4.3.1
            """)
        let sut = PatternSolver(grid: gen.grid)

        XCTAssertEqual(sut.solve(), .solved)

        assertStatesMatch(
            sut.grid, [
                0b10011_11100_00000,
                0b10001_11111_01110,
                0b10001_11111_00000,
                0b00001_11111_10100,
                0b00001_11110_00000,
                //
                0b00111_11100_00000,
                0b00011_10100_00011,
                0b00111_10100_00011,
                0b00011_10101_10001,
                0b11111_00011_10000,
                //
                0b11000_00001_11011,
                0b11011_00011_11111,
                0b11101_11000_01000,
                0b11111_11100_01000,
                0b11110_11100_01000,
            ]
        )

        printGrid(sut.grid)
    }

    func testSolve_25x25() throws {
        // Game available at:
        // https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/pattern.html#25x25:1.3.1/2.2.1.1/1.3.1.1.2/2.4.4.1.3.2/2.3.2.3/2.4.6.1/6.3.2/2.6.1.1/2.1.3.5.1/1.1.8/13/3.9/15/1.7.6/1.1.4.3.1/2.4.3.1/1.3.3.2/1.3.3.2.1/1.1.7.2/1.1.12.2/1.1.11.3/6.4.3/2.1.12.5/12.5.4/12.5.4/10.3/1.6.1.1.3/1.3.1.2/2.2.2/3.1.3/4.3.1.1.2/4.3.3/3.1.4.8/4.8.4/1.2.1.6.6/1.1.1.2.1.1.3.6/3.6.2.6/5.3.4/3.3.4.3.3/3.4.7.3/1.1.12.3/17/1.6.7/1.2.6.5/4.8.6/3.2.1.1.1/4/5/2.1.7/2.2.7.2

        let gen = try PatternGridGenerator(gameId: """
            25x25:1.3.1/2.2.1.1/1.3.1.1.2/2.4.4.1.3.2/2.3.2.3/2.4.6.1/6.3.2/\
            2.6.1.1/2.1.3.5.1/1.1.8/13/3.9/15/1.7.6/1.1.4.3.1/2.4.3.1/1.3.3.2/\
            1.3.3.2.1/1.1.7.2/1.1.12.2/1.1.11.3/6.4.3/2.1.12.5/12.5.4/12.5.4/\
            10.3/1.6.1.1.3/1.3.1.2/2.2.2/3.1.3/4.3.1.1.2/4.3.3/3.1.4.8/4.8.4/\
            1.2.1.6.6/1.1.1.2.1.1.3.6/3.6.2.6/5.3.4/3.3.4.3.3/3.4.7.3/1.1.12.3/\
            17/1.6.7/1.2.6.5/4.8.6/3.2.1.1.1/4/5/2.1.7/2.2.7.2
            """)
        
        let sut = PatternSolver(grid: gen.grid)

        XCTAssertEqual(sut.solve(), .solved)

        print(extractBinaryRows(sut.grid))

        assertStatesMatch(
            sut.grid, [
                0b11111_11111_00000_00000_00111,
                0b01011_11110_00010_10000_00111,
                0b00000_01000_00000_11101_00011,
                0b00000_11000_00011_00000_00011,
                0b00001_11000_00010_00000_00111,
                0b00011_11000_00111_00010_10011,
                0b00111_10000_01110_00000_00111,
                0b01110_00010_11110_00111_11111,
                0b11110_00000_11111_11100_01111,
                0b10000_00110_10111_11101_11111,
                0b10010_10110_10101_11001_11111,
                0b00011_10111_11101_10001_11111,
                0b00011_11100_11100_00001_11100,
                0b01110_11101_11100_00011_10111,
                0b00000_11101_11101_11111_10111,
                0b00010_10001_11111_11111_10111,
                0b00000_00011_11111_11111_11111,
                0b00010_00011_11110_00011_11111,
                0b10011_00011_11110_00111_11000,
                0b01111_01111_11110_00111_11100,
                0b00001_11011_00010_00001_00100,
                0b00000_00000_00000_00000_01111,
                0b00000_00000_00000_00000_11111,
                0b00110_00000_00000_01011_11111,
                0b00110_00110_00001_11111_10011,
            ]
        )

        printGrid(sut.grid)
    }
}

extension PatternSolverTests {
    fileprivate func printGrid(_ grid: PatternGrid) {
        let target = TestConsolePrintTarget()
        let gridPrinter = PatternGridPrinter(bufferForGrid: grid)
        gridPrinter.target = target
        gridPrinter.printGrid(grid: grid)

        print(target.buffer)
    }

    fileprivate func assertStatesMatch(
        _ grid: PatternGrid,
        _ numbers: [UInt64],
        line: UInt = #line
    ) {

        XCTAssertEqual(
            grid.statesForTiles(),
            statesFromBinaryRows(rowLength: grid.rows, numbers),
            line: line
        )
    }

    fileprivate func extractBinaryRows(_ grid: PatternGrid) -> [String] {
        assert(grid.columns <= 64)

        var result: [String] = []

        let rowLength = grid.rows
        for row in 0..<grid.rows {
            var binary: UInt64 = 0b0

            for index in 0..<grid.columns {
                let bitIndex = (rowLength - index) - 1

                let bit: UInt64
                switch grid[column: index, row: row].state {
                case .dark:
                    bit = 0b1
                case .light, .undecided:
                    bit = 0b0
                }

                binary |= bit << bitIndex
            }

            var binaryString = String(binary, radix: 2)
            let targetLength = rowLength
            if binaryString.count > targetLength {
                binaryString = String(binaryString.dropFirst(UInt64.bitWidth - targetLength))
            } else if binaryString.count < targetLength {
                binaryString = "\(String(repeating: "0", count: targetLength - binaryString.count))\(binaryString)"
            }

            result.append("0b\(binaryString)")
        }

        return result
    }
}
