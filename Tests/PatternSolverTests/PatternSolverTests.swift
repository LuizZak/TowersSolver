import XCTest
import Console

@testable import PatternSolver

class PatternSolverTests: XCTestCase {
    func testSolve_5x5() throws {
        // Game available at:
        // https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/pattern.html#5x5:1/2/1.1/2.2/2.2/4/1.2/1/2/3
        let gen = try PatternGridGenerator(gameId: "5x5:1/2/1.1/2.2/2.2/4/1.2/1/2/3")
        let sut = PatternSolver(grid: gen.grid)

        XCTAssertEqual(sut.solve(), .solved)

        assertStatesMatch(sut.grid, [
            0b01111,
            0b01011,
            0b10000,
            0b00011,
            0b00111,
        ])

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

        assertStatesMatch(sut.grid, [
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
        ])

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

        assertStatesMatch(sut.grid, [
            //
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
        ])

        printGrid(sut.grid)
    }
    
    func testSolve_15x20() throws {
        // Game available at:
        // https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/pattern.html#15x20:3.1/3.1.2/1.4.3/1.4.4/1.3.4.4/1.4.3.4/2.4.4.3/3.5.2.3/3.8.6/11.1.1/11.3/11.1/2.1.1/3.2.3/1.1.3/2.9.2/2.6.1/2.5.2/3/1.1.4/3.6/10/7/7/5.2/2.8/3.1.2/6.2/5/5/4/3.1/7.1/8.1/11

        let gen = try PatternGridGenerator(gameId: """
            15x20:3.1/3.1.2/1.4.3/1.4.4/1.3.4.4/1.4.3.4/2.4.4.3/3.5.2.3/3.8.6/11.1.1/11.3/11.1/2.1.1/3.2.3/1.1.3/2.9.2/2.6.1/2.5.2/3/1.1.4/3.6/10/7/7/5.2/2.8/3.1.2/6.2/5/5/4/3.1/7.1/8.1/11
            """)
        
        let sut = PatternSolver(grid: gen.grid)

        XCTAssertEqual(sut.solve(), .solved)

        assertStatesMatch(sut.grid, [
            //
            0b11011_11111_11011_00000,
            0b11000_01111_11010_00000,
            0b11000_00111_11011_00000,
            0b00000_00001_11000_00000,
            0b00101_00011_11000_00000,
            //
            0b00001_11011_11110_00000,
            0b00001_11111_11110_00000,
            0b00000_11111_11000_00000,
            0b00000_11111_11000_00000,
            0b00000_00111_11011_00000,
            //
            0b00110_00111_11111_00000,
            0b00111_00010_00011_00000,
            0b01111_11000_01100_00000,
            0b00111_11000_00000_00000,
            0b00001_11110_00000_00000,
            //
            0b00000_01111_00000_00000,
            0b00011_10010_00000_00000,
            0b00111_11110_10000_00000,
            0b01111_11110_10000_00000,
            0b11111_11111_10000_00000,
        ])

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

        assertStatesMatch(sut.grid, [
            //
            0b11111_11111_00000_00000_00111,
            0b01011_11110_00010_10000_00111,
            0b00000_01000_00000_11101_00011,
            0b00000_11000_00011_00000_00011,
            0b00001_11000_00010_00000_00111,
            //
            0b00011_11000_00111_00010_10011,
            0b00111_10000_01110_00000_00111,
            0b01110_00010_11110_00111_11111,
            0b11110_00000_11111_11100_01111,
            0b10000_00110_10111_11101_11111,
            //
            0b10010_10110_10101_11001_11111,
            0b00011_10111_11101_10001_11111,
            0b00011_11100_11100_00001_11100,
            0b01110_11101_11100_00011_10111,
            0b00000_11101_11101_11111_10111,
            //
            0b00010_10001_11111_11111_10111,
            0b00000_00011_11111_11111_11111,
            0b00010_00011_11110_00011_11111,
            0b10011_00011_11110_00111_11000,
            0b01111_01111_11110_00111_11100,
            //
            0b00001_11011_00010_00001_00100,
            0b00000_00000_00000_00000_01111,
            0b00000_00000_00000_00000_11111,
            0b00110_00000_00000_01011_11111,
            0b00110_00110_00001_11111_10011,
        ])

        printGrid(sut.grid)
    }

    func testSolve_35x35() throws {
        // Game available at:
        // https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/pattern.html#35x35:7.3.3.7/9.8.8.3/11.2.13.1/3.3.2.5.5.4/1.2.6.3.2.5/2.4.3.2.3/5.3.2.4.4/1.3.2.2/1.5.8.3/3.1.7.2/1.1.8.4/2.3.4/2.4.3.4/1.1.6/2.2.1.3.2.4/4.2.7.3.3/4.3.10.5.1/3.3.1.1.6.4/4.5.1.6.4.1/3.3.1.2/2.5.4/4.3.4/3.1.3.5.5.1/1.1.3.1.1.2.6.1/4.1.3.3/6.3.8.3/1.1.11.1.14/6.8.16/6.6.13.1/4.2.3.1.1.1.11/3.3.5.1/5.3.3.1.3/9.3.5.2/6.4.1.5.2/6.4.3.5.1.1/5.2.3.3/2.3.6.1.3.3/5.6.1.3.3/4.2.1.2.3.4.3/3.1.2.4/3.1.4.5/5.2.4.4/5.3.3.1.3.4/4.4.8.2/3.1.1.13.1.2/4.1.6.5.1.2/6.1.2.4.4.1.2/2.1.3.3.4/2.2.1.3.3.3.1/3.2.1.2.2.3.1/4.2.4.3.4.1/1.1.2.1.1.3.1.2.1/1.1.8.4.5.2/14.3.1.2.1/6.4.4.2.4/3.1.3.4.7/1.3.6.3.4/3.4.6.1.4.3/4.4.1.7.2/4.1.1.11.1/7.1.3.11.1/7.1.3.4.8/3.1.1.1.1.4.6.1.1/3.1.1.9.6/5.11.5/5.7.3.5/6.3.1.3.4.1/1.5.1.8/1.1.4.1.1.1/2.1.1.8.2

        let gen = try PatternGridGenerator(gameId: """
            35x35:7.3.3.7/9.8.8.3/11.2.13.1/3.3.2.5.5.4/1.2.6.3.2.5/2.4.3.2.3/\
            5.3.2.4.4/1.3.2.2/1.5.8.3/3.1.7.2/1.1.8.4/2.3.4/2.4.3.4/1.1.6/\
            2.2.1.3.2.4/4.2.7.3.3/4.3.10.5.1/3.3.1.1.6.4/4.5.1.6.4.1/3.3.1.2/\
            2.5.4/4.3.4/3.1.3.5.5.1/1.1.3.1.1.2.6.1/4.1.3.3/6.3.8.3/1.1.11.1.14/\
            6.8.16/6.6.13.1/4.2.3.1.1.1.11/3.3.5.1/5.3.3.1.3/9.3.5.2/6.4.1.5.2/\
            6.4.3.5.1.1/5.2.3.3/2.3.6.1.3.3/5.6.1.3.3/4.2.1.2.3.4.3/3.1.2.4/\
            3.1.4.5/5.2.4.4/5.3.3.1.3.4/4.4.8.2/3.1.1.13.1.2/4.1.6.5.1.2/\
            6.1.2.4.4.1.2/2.1.3.3.4/2.2.1.3.3.3.1/3.2.1.2.2.3.1/4.2.4.3.4.1/\
            1.1.2.1.1.3.1.2.1/1.1.8.4.5.2/14.3.1.2.1/6.4.4.2.4/3.1.3.4.7/\
            1.3.6.3.4/3.4.6.1.4.3/4.4.1.7.2/4.1.1.11.1/7.1.3.11.1/7.1.3.4.8/\
            3.1.1.1.1.4.6.1.1/3.1.1.9.6/5.11.5/5.7.3.5/6.3.1.3.4.1/1.5.1.8/\
            1.1.4.1.1.1/2.1.1.8.2
            """)
        
        let sut = PatternSolver(grid: gen.grid)

        XCTAssertEqual(sut.solve(), .solved)
        
        assertStatesMatch(sut.grid, [
            //
            0b00000_00000_00001_11110_00110_00111_00111,
            0b00110_01110_00001_11111_00100_00111_00111,
            0b00111_11000_00000_11111_10100_00111_00111,
            0b11110_11000_10000_11011_10000_01111_00111,
            0b11100_01000_00000_00000_00000_00110_01111,
            //
            0b11100_01000_00000_00000_00000_11110_11111,
            0b11111_00000_01100_00000_00111_10001_11100,
            0b11111_00000_11100_01110_10001_11001_11100,
            0b11110_00000_00000_11110_11111_11100_01100,
            0b11101_01000_00000_11111_11111_11101_00011,
            //
            0b01111_01000_00000_00011_11110_11111_01011,
            0b01111_11001_00001_10011_11000_01111_01011,
            0b00001_10001_00011_10000_00000_01110_01111,
            0b11001_10001_00000_11100_01110_01110_00100,
            0b11101_10010_00000_11000_01100_01110_00100,
            //
            0b11110_00011_00000_11110_01110_11110_00001,
            0b01010_00110_10101_11000_00100_11000_00001,
            0b01010_11111_11100_11110_00111_11000_00011,
            0b11111_11111_11110_01110_00010_00001_10100,
            0b11111_10001_11100_01111_00000_01100_11110,
            //
            0b11101_00011_10000_11110_00000_00111_11110,
            0b00100_00011_10001_11111_00000_01110_01111,
            0b01110_00111_10001_11111_00010_01111_00111,
            0b11110_00111_10001_00000_00111_11110_00011,
            0b11110_00010_00100_00000_11111_11111_10001,
            //
            0b11111_11010_00111_00000_11111_11111_10001,
            0b11111_11010_00111_00000_11110_11111_11100,
            0b11100_01010_00010_10000_11110_11111_10101,
            0b11101_01000_11111_11110_00000_11111_10000,
            0b11111_00011_11111_11110_00000_11111_00000,
            //
            0b00111_11011_11111_01110_00000_11111_00000,
            0b00011_11110_11101_01110_00000_01111_01000,
            0b01011_11100_00000_01000_00001_11111_11000,
            0b01000_01000_00000_00000_00001_11101_01010,
            0b01100_00000_00000_01010_00111_11111_00011,
        ])

        printGrid(sut.grid)
    }

    func testSolve_40x40() throws {
        // Game available at:
        // https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/pattern.html#40x40:3.9.2.1.3.1/1.7.8.3.1/5.4.6.2/1.6.4.3.2/2.3.1.4.1.10/7.5.1.1.3.2/7.6.7.1.2/9.2.9.6.1.2/7.11.6.10/2.11.3.10/1.1.4.1.3.1.1.1.7/3.3.4.1.3.2/2.1.3.1.4.1.5.3.2/2.2.20.2.3/9.6.1.6/4.5.1.3.1.2/7.3.2.2/2.6.1.1.1.3/4.3.3.1.1.3.2.4/1.1.3.2.1.1.3.2.3/7.3.1.3.2.3.2/2.3.6.3.3.1.2/1.3.3.3.3.2/1.1.1.3.2.2.1.1/1.1.1.1.1.4.1.4.1/5.1.3.6.3.2/4.1.2.5.3.1/4.4.4.3.2/2.5.2.3.1/4.3.1.2.9/1.2.2.2.3.9/3.3.1.6.2.4.4/7.3.7.2.3.3/5.11.10.2/6.2.17.4/2.2.1.3.6.4.3/1.4.1.1.4.3/2.3.3.4.6.1/3.4.4.6.2/3.5.4.8/7.2.2.1.5/6.2.4.4.1.3/4.1.1.1.3.1.2/4.7.6.2.1/5.2.2.5.6/9.3.5.1.6/1.1.5.1.1.6.3.1.4.4/4.1.1.6.5.4/3.1.3.4.2/3.1.2.1.2/1.1.5.4.1.1.1/1.1.6.2.5.2.1/2.1.10.8.4.3/2.4.6.5.3/1.1.2.3.6.3.3/1.3.3.2.1.3.2.3/2.2.3.2.1.1.7/2.1.3.2.1.1.6.3/15.8.5/16.8.4/8.6.19/8.3.12.1/2.3.1.1.7.1/2.4.2.1.6.1/3.1.1.6/8.2.6/1.4.5.2.3/1.4.5.1.3.3/3.4.4.6.2/2.3.2.6/1.7.2.3.1.4/1.1.1.4.8.6.4/1.1.4.1.1.17.1/1.1.7.2.10.1/15.1.5/6.7.4.1/2.8.1.3.2.1.3.1/1.3.7.2.4.2/14.5.1.7/15.4.4.7

        let gen = try PatternGridGenerator(gameId: """
            40x40:3.9.2.1.3.1/1.7.8.3.1/5.4.6.2/1.6.4.3.2/2.3.1.4.1.10/\
            7.5.1.1.3.2/7.6.7.1.2/9.2.9.6.1.2/7.11.6.10/2.11.3.10/1.1.4.1.3.1.1.1.7\
            /3.3.4.1.3.2/2.1.3.1.4.1.5.3.2/2.2.20.2.3/9.6.1.6/4.5.1.3.1.2/\
            7.3.2.2/2.6.1.1.1.3/4.3.3.1.1.3.2.4/1.1.3.2.1.1.3.2.3/7.3.1.3.2.3.2/\
            2.3.6.3.3.1.2/1.3.3.3.3.2/1.1.1.3.2.2.1.1/1.1.1.1.1.4.1.4.1/\
            5.1.3.6.3.2/4.1.2.5.3.1/4.4.4.3.2/2.5.2.3.1/4.3.1.2.9/1.2.2.2.3.9/\
            3.3.1.6.2.4.4/7.3.7.2.3.3/5.11.10.2/6.2.17.4/2.2.1.3.6.4.3/1.4.1.1.4.3/\
            2.3.3.4.6.1/3.4.4.6.2/3.5.4.8/7.2.2.1.5/6.2.4.4.1.3/4.1.1.1.3.1.2/\
            4.7.6.2.1/5.2.2.5.6/9.3.5.1.6/1.1.5.1.1.6.3.1.4.4/4.1.1.6.5.4/\
            3.1.3.4.2/3.1.2.1.2/1.1.5.4.1.1.1/1.1.6.2.5.2.1/2.1.10.8.4.3/\
            2.4.6.5.3/1.1.2.3.6.3.3/1.3.3.2.1.3.2.3/2.2.3.2.1.1.7/2.1.3.2.1.1.6.3/\
            15.8.5/16.8.4/8.6.19/8.3.12.1/2.3.1.1.7.1/2.4.2.1.6.1/3.1.1.6/8.2.6/\
            1.4.5.2.3/1.4.5.1.3.3/3.4.4.6.2/2.3.2.6/1.7.2.3.1.4/1.1.1.4.8.6.4/\
            1.1.4.1.1.17.1/1.1.7.2.10.1/15.1.5/6.7.4.1/2.8.1.3.2.1.3.1/1.3.7.2.4.2/\
            14.5.1.7/15.4.4.7
            """)
        
        let sut = PatternSolver(grid: gen.grid)

        XCTAssertEqual(sut.solve(), .solved)

        assertStatesMatch(sut.grid, [
            //
            0b00001_11111_10110_00110_00000_10000_00000_11111,
            0b00001_11111_00110_00111_10001_11100_00000_10111,
            0b00000_11110_10000_00010_10000_11100_01000_00011,
            0b00000_11110_00000_01111_11101_11111_01101_00000,
            0b00001_11110_00000_01100_11000_11111_01111_11000,
            //
            0b11111_11110_01110_01111_10000_00001_00111_11100,
            0b10101_11110_01010_11111_10001_11001_01111_01111,
            0b11110_00100_01000_11111_10000_00000_11111_01111,
            0b01110_00100_00000_11100_00000_00000_01111_00011,
            0b01110_00010_00000_11000_00000_00000_00100_00011,
            //
            0b01010_00011_11100_00000_11110_00000_01000_00101,
            0b01010_00011_11110_11011_11100_00001_10000_00100,
            0b11010_00111_11111_11011_11111_10111_10000_11100,
            0b11000_00111_10011_11110_00000_11111_00111_00000,
            0b10001_00011_00011_10000_00011_11110_00111_00111,
            //
            0b10000_00011_10011_10011_01000_00111_00110_00111,
            0b11000_00011_00111_00000_11000_00010_10011_11111,
            0b11000_10111_00011_00000_01000_01000_11111_10111,
            0b11111_11111_11111_00000_11111_11100_01111_10000,
            0b11111_11111_11111_10000_11111_11100_01111_00000,
            //
            0b11111_11101_11111_00111_11111_11111_11111_10000,
            0b01111_11110_01110_00000_00001_11111_11111_10001,
            0b11000_01110_00010_00000_00000_10000_01111_11101,
            0b11000_01111_00110_00000_00000_10000_00111_11101,
            0b00000_00111_00010_00010_00000_00000_00001_11111,
            //
            0b00000_00111_11111_00011_00000_00000_00001_11111,
            0b00000_00010_00111_10011_11100_00000_00011_00111,
            0b00000_00000_10111_10001_11110_00000_10111_00111,
            0b00001_11000_00111_10000_01111_00000_11111_10011,
            0b00000_01100_00111_00000_00000_00000_11011_11110,
            //
            0b00101_11111_10011_00000_11101_00000_00011_11000,
            0b10101_01111_00000_00111_11111_01111_11011_11000,
            0b00101_01111_00001_01011_11111_11111_11111_00010,
            0b00101_01111_11100_11000_00001_11111_11110_00010,
            0b11111_11111_11111_00000_00000_10001_11110_00000,
            //
            0b11111_10011_11111_00000_00000_00111_10010_00000,
            0b11011_11111_10001_01110_01100_00101_11001_00000,
            0b00001_00011_10011_11111_00110_00001_11101_10000,
            0b00111_11111_11111_10111_11000_10001_11111_10000,
            0b11111_11111_11111_00011_11011_11001_11111_10000,
        ])

        printGrid(sut.grid)
    }
    
    func test_45x75LightBulb() throws {
        // This pattern was aquired from a Nanogram website, contributed by a
        // community member, but I've since lost the original source link. Any
        // hints as to the original author for proper credit are apreciated.
        let gen = try PatternGridGenerator(gameId: """
            45x75:27/4.4.10.4/15.3.1.3/13.4.2.3.3/5.5.3.3.5.3/9.1.4.7.3/8.2.2.8.2/\
            7.1.2.1.10.3/1.4.3.1.10.3/5.3.1.4.7.5/4.4.2.8.5.4/3.3.3.7.8.9.1/\
            3.3.4.9.1.8.13.5.4.1/2.1.2.1.5.2.1.4.1.4.7.1.2.2.5/\
            2.1.1.2.1.4.3.4.1.9.5.2.2.3.3/1.1.5.2.4.4.3.2.13.1.1.2.2.2.2/\
            1.2.2.1.4.3.1.7.5.1.1.1.2.3.2/1.3.3.1.3.2.3.2.14.2.1.1.2.2/\
            1.1.2.4.3.1.3.7.4.6.1.3.1.2.1.3/1.2.1.3.6.3.1.6.4.1.1.1.2.1.2.2/\
            1.2.2.3.10.11.1.1.2.2.1.1.1/3.10.3.10.10.3.1.1.2.1.2/\
            1.4.3.2.3.11.8.3.1.1.1.1.1.1/2.2.1.5.13.2.4.1.1.1.1.2.1.1/\
            2.2.1.1.1.3.4.9.2.1.1.1.1.2.1/1.1.1.4.1.1.3.9.4.5.1.2.2.1.1.1/\
            1.1.3.1.1.3.7.2.8.3.1.1.1.1.2/1.1.2.5.2.5.7.4.8.2.1.1.1.1.3/\
            1.2.2.1.2.1.3.1.7.1.1.11.1.2.1.2.2/1.3.1.2.2.1.4.2.2.4.2.5.3.1.1.1.1.2.1/\
            1.1.4.1.3.3.1.6.1.1.11.4.6/2.1.2.1.3.1.3.8.1.9.5.2.2/\
            2.1.2.3.1.4.8.1.7.2/3.1.1.7.3.7.5.4/3.1.4.6.15.4/4.2.3.2.3.13.3/\
            5.2.3.3.3.7.3.2/2.3.2.5.3.10.2/7.2.5.3.9.3/8.3.5.7.2/9.4.3.6.1/\
            5.5.4.3.4.2/13.5.1.2.3/3.3.8.1.3/28/19.12.4/8.6.14/13.1.1.4.7/\
            11.8.1/1.8.9/4.4.4.3/8.2.7/7.6.2.4.1/6.4.4.2.5/1.3.4.1.1.2.5/\
            5.4.2.1.3.1.2.2.4/4.1.2.1.1.3.1.1.3/4.1.2.3.2.1.6.2.3/\
            3.1.1.1.1.4.4.3.1.2/3.1.2.1.1.2.3.3.2.1.2/2.1.1.2.1.2.2.2.1.1.1.2/\
            2.1.5.1.1.5.2.1.1.1/2.1.2.2.3.1.3.1.2.1.1/2.1.1.2.3.1.1.1.2.2.1/\
            2.1.2.3.8.2.1.3.2.1/1.1.1.2.2.1.4.1.3.1.1/1.1.5.7.5.2.1.1.1/\
            1.1.8.2.3.1.1.1/1.11.2.3.1.3.2/1.4.5.2.6.1.5.1/1.3.6.1.1.10.1/\
            2.1.34.1.1/1.3.28.3.1/1.5.18.4.1/2.4.3.1.7.1/1.7.3.4.3.8.1/\
            1.9.2.4.12.1/1.9.1.4.10.1/1.8.1.7.13.1/2.3.5.23.1/1.10.12.9.1/\
            2.10.1.16.2.1/1.10.19.1/2.2.2.2.5.8.4.1/1.3.1.1.1.11.3.1/\
            1.3.3.6.2.2.1/1.4.3.5.1.2.2.2/2.9.4.3.2.1/1.11.3.2.1.2.1/\
            1.11.2.3.3.1/1.7.3.2.4.1/1.2.9.1.8.1/1.12.1.7.2/1.13.8.1/\
            1.4.2.4.8.1/1.11.8.1/1.2.9.4.2.1/1.6.5.6.1/1.12.7.1/1.4.1.1.3.1/\
            1.1.5.4.1.1/7.2.5.2/1.10.1.1/1.1.2/5.7/1.5.2/1.7.3/4.4.1/2.8.1/\
            1.7.2/4.4.2/3.5.3/1.7.3/5.3.1/2.1.3.1/2.5.3/5.5/3.3.2/2.1.1/6
            """)
        
        let sut = PatternSolver(grid: gen.grid)
        
        XCTAssertEqual(sut.solve(), .solved)
        XCTAssertTrue(sut.state != .invalid && sut.state != .unsolvable)
        
        printGrid(sut.grid)
    }
}

extension PatternSolverTests {
    fileprivate func printGrid(_ grid: PatternGrid) {
        let target = StringBufferConsolePrintTarget()
        let gridPrinter = PatternGridPrinter(bufferForGrid: grid)
        gridPrinter.target = target
        gridPrinter.printGrid(grid: grid)

        Swift.print(target.buffer)
    }

    fileprivate func assertStatesMatch(
        _ grid: PatternGrid,
        _ numbers: [UInt64],
        line: UInt = #line
    ) {

        let binaryRows = extractBinaryRows(grid)

        XCTAssertEqual(
            binaryRows,
            numbers,
            "Solution grid doesn't match expected value",
            line: line
        )
    }

    fileprivate func generateBinaryRowStringList(_ grid: PatternGrid) -> String {
        var result: String = "[\n"

        let rows = extractBinaryRowStrings(grid)
        for (i, row) in rows.enumerated() {
            if i % 5 == 0 {
                result += "    //\n"
            }
            result += "    \(row),\n"
        }

        return result + "]"
    }

    fileprivate func extractBinaryRowStrings(_ grid: PatternGrid) -> [String] {
        let rowLength = grid.rows

        return extractBinaryRows(grid).map { binary in
            var binaryString = String(binary, radix: 2)
            let targetLength = rowLength
            if binaryString.count > targetLength {
                binaryString = String(binaryString.dropFirst(UInt64.bitWidth - targetLength))
            } else if binaryString.count < targetLength {
                binaryString = "\(String(repeating: "0", count: targetLength - binaryString.count))\(binaryString)"
            }

            // Underscore every five digits
            for sep in stride(from: 0, to: binaryString.count, by: 5).dropFirst().reversed() {
                binaryString.insert("_", at: binaryString.index(binaryString.startIndex, offsetBy: sep))
            }

            return "0b\(binaryString)"
        }
    }

    fileprivate func extractBinaryRows(_ grid: PatternGrid) -> [UInt64] {
        assert(grid.columns <= 64)

        var result: [UInt64] = []

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

            result.append(binary)
        }

        return result
    }
}
