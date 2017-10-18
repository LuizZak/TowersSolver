//
//  TowersSolverTests.swift
//  TowersSolver
//
//  Created by Luiz Fernando Silva on 14/10/17.
//

import XCTest
import TowersSolver

class TowersSolverTests: XCTestCase {

    static var allTests = [
        ("testResetToAllPossible", testResetToAllPossible),
        ("testIsConsistent", testIsConsistent),
        ("testIsConsistentWithNonSolvedGrid", testIsConsistentWithNonSolvedGrid),
        ("testTrivialSolve", testTrivialSolve),
        ("testTrivialSolveIncompleteHints", testTrivialSolveIncompleteHints),
        ("testSimpleSolve", testSimpleSolve),
        ("testComplexSolve", testComplexSolve),
        ("testVeryComplexSolve", testVeryComplexSolve)
    ]
    
    func testResetToAllPossible() {
        var grid = Grid(size: 5)
        grid.resetHints(toAllPossible: true)
        
        XCTAssert(grid.cells.reduce(true, { $0 && ($1.hints == [1, 2, 3, 4, 5]) }))
    }
    
    func testIsConsistent() {
        var grid = Grid(size: 3)
        
        grid.visibilities.top = [2, 2, 1]
        grid.visibilities.left = [2, 2, 1]
        grid.visibilities.right = [1, 2, 3]
        grid.visibilities.bottom = [1, 2, 3]
        
        grid.markSolved(x: 0, y: 0, height: 2)
        grid.markSolved(x: 1, y: 0, height: 1)
        grid.markSolved(x: 2, y: 0, height: 3)
        grid.markSolved(x: 0, y: 1, height: 1)
        grid.markSolved(x: 1, y: 1, height: 3)
        grid.markSolved(x: 2, y: 1, height: 2)
        grid.markSolved(x: 0, y: 2, height: 3)
        grid.markSolved(x: 1, y: 2, height: 2)
        grid.markSolved(x: 2, y: 2, height: 1)
        
        let solver = Solver(grid: grid)
        
        XCTAssert(solver.isConsistent())
        XCTAssertFalse(solver.hasEmptySolutionCells())
        
        // Flip all visibilities over.
        // Grid should still be valid, but now tower visibilities are flipped over
        (solver.grid.visibilities.top, solver.grid.visibilities.bottom) =
        (solver.grid.visibilities.bottom, solver.grid.visibilities.top)
        
        XCTAssertFalse(solver.isConsistent())
    }
    
    func testIsConsistentWithNonSolvedGrid() {
        var grid = Grid(size: 3)
        
        grid.visibilities.top = [2, 2, 1]
        grid.visibilities.left = [2, 2, 1]
        grid.visibilities.right = [1, 2, 3]
        grid.visibilities.bottom = [1, 2, 3]
        
        // Missing this cell
        // grid.markSolved(x: 0, y: 0, height: 2)
        grid.markSolved(x: 1, y: 0, height: 1)
        grid.markSolved(x: 2, y: 0, height: 3)
        grid.markSolved(x: 0, y: 1, height: 1)
        grid.markSolved(x: 1, y: 1, height: 3)
        grid.markSolved(x: 2, y: 1, height: 2)
        grid.markSolved(x: 0, y: 2, height: 3)
        grid.markSolved(x: 1, y: 2, height: 2)
        grid.markSolved(x: 2, y: 2, height: 1)
        
        let solver = Solver(grid: grid)
        
        XCTAssert(solver.isConsistent())
        XCTAssert(solver.hasEmptySolutionCells())
        
        // Create a duplicated number in the unsolved columns
        solver.grid.markSolved(x: 0, y: 1, height: 3)
        
        XCTAssertFalse(solver.isConsistent())
    }
    
    /// Tests a rather trivial solve that works with no need for complex steps.
    func testTrivialSolve() {
        var grid = Grid(size: 3)
        
        grid.visibilities.top = [2, 2, 1]
        grid.visibilities.left = [2, 2, 1]
        grid.visibilities.right = [1, 2, 3]
        grid.visibilities.bottom = [1, 2, 3]
        
        let solver = Solver(grid: grid)
        solver.fillHints()
        solver.runTrivialStep()
        
        GridPrinter.printGrid(grid: solver.grid)
        
        XCTAssert(solver.grid.isSolved)
        XCTAssert(solver.isConsistent())
        XCTAssertFalse(solver.hasEmptySolutionCells())
        
        XCTAssertEqual(
            solver.grid.cells.solutionHeights(),
            [2, 1, 3,
             1, 3, 2,
             3, 2, 1]
        )
    }
    
    /// Tests the same trivial board as above, but with just enough hints to make
    /// the puzzle unambiguous, then test how smart the trivial steps can be.
    func testTrivialSolveIncompleteHints() {
        var grid = Grid(size: 3)
        
        grid.visibilities.top = [0, 2, 0]
        grid.visibilities.left = [2, 0, 0]
        grid.visibilities.right = [1, 0, 0]
        grid.visibilities.bottom = [0, 2, 0]
        
        let solver = Solver(grid: grid)
        solver.fillHints()
        solver.runTrivialStep()
        
        GridPrinter.printGrid(grid: solver.grid)
        
        XCTAssert(solver.grid.isSolved)
        XCTAssert(solver.isConsistent())
        XCTAssertFalse(solver.hasEmptySolutionCells())
        
        XCTAssertEqual(
            solver.grid.cells.solutionHeights(),
            [2, 1, 3,
             1, 3, 2,
             3, 2, 1]
        )
    }
    
    /// Tests a simple solve attempt with no backtracking required
    func testSimpleSolve() {
        var grid = Grid(size: 5)
        
        grid.visibilities.top = [0, 4, 1, 0, 0]
        grid.visibilities.left = [0, 0, 0, 0, 4]
        grid.visibilities.right = [0, 0, 0, 0, 1]
        grid.visibilities.bottom = [4, 0, 3, 0, 0]
        
        let solver = Solver(grid: grid)
        solver.maxGuessAttempts = 0
        solver.solve()
        
        let printer = GridPrinter(bufferWidth: 80, bufferHeight: 30)
        printer.printGrid(grid: solver.grid)
        
        XCTAssert(solver.grid.isSolved)
        XCTAssert(solver.isConsistent())
        XCTAssertFalse(solver.hasEmptySolutionCells())
        
        XCTAssertEqual(
            solver.grid.cells.solutionHeights(),
            [4, 1, 5, 2, 3,
             5, 2, 3, 1, 4,
             3, 4, 1, 5, 2,
             2, 5, 4, 3, 1,
             1, 3, 2, 4, 5]
        )
    }
    
    /// Tests a more complicated solve attempt with backtracking/guessing required
    func testComplexSolve() {
        var grid = Grid(size: 6)
        
        grid.visibilities.top = [3, 4, 3, 0, 0, 1]
        grid.visibilities.left = [3, 0, 1, 2, 0, 0]
        grid.visibilities.right = [0, 2, 3, 0, 0, 0]
        grid.visibilities.bottom = [2, 0, 0, 4, 0, 0]
        
        grid.markSolved(x: 2, y: 5, height: 2)
        
        let solver = Solver(grid: grid)
        solver.solve()
        
        GridPrinter.printGrid(grid: solver.grid)
        
        XCTAssert(solver.grid.isSolved)
        XCTAssert(solver.isConsistent())
        XCTAssertFalse(solver.hasEmptySolutionCells())
        
        XCTAssertEqual(
            solver.grid.cells.solutionHeights(),
            [3, 2, 1, 5, 4, 6,
             5, 3, 4, 6, 1, 2,
             6, 4, 3, 2, 5, 1,
             2, 1, 6, 4, 3, 5,
             1, 6, 5, 3, 2, 4,
             4, 5, 2, 1, 6, 3]
        )
    }
    
    func testVeryComplexSolve() {
        // This one is a bit bonkers to solve. Takes the solver two guess moves
        // before properly solving the puzzle.
        
        var grid = Grid(size: 8)
        
        grid.visibilities.top = [0, 0, 3, 1, 5, 0, 0, 4]
        grid.visibilities.left = [3, 3, 2, 1, 0, 4, 0, 3]
        grid.visibilities.right = [0, 0, 0, 3, 3, 0, 4, 0]
        grid.visibilities.bottom = [0, 0, 1, 4, 0, 2, 0, 0]
        
        grid.markSolved(x: 5, y: 0, height: 3)
        grid.markSolved(x: 0, y: 2, height: 4)
        grid.markSolved(x: 6, y: 2, height: 3)
        grid.markSolved(x: 2, y: 3, height: 4)
        grid.markSolved(x: 1, y: 4, height: 1)
        grid.markSolved(x: 7, y: 4, height: 4)
        grid.markSolved(x: 2, y: 5, height: 6)
        grid.markSolved(x: 7, y: 6, height: 2)
        grid.markSolved(x: 1, y: 7, height: 5)
        grid.markSolved(x: 4, y: 7, height: 1)
        
        let solver = Solver(grid: grid)
        solver.solve()
        
        GridPrinter.printGrid(grid: solver.grid)
        
        XCTAssert(solver.grid.isSolved)
        XCTAssert(solver.isConsistent())
        XCTAssertFalse(solver.hasEmptySolutionCells())
        
        XCTAssertEqual(
            solver.grid.cells.solutionHeights(),
            [5, 6, 2, 8, 4, 3, 7, 1,
             6, 4, 7, 1, 3, 2, 8, 5,
             4, 8, 1, 6, 2, 5, 3, 7,
             8, 3, 4, 7, 5, 1, 2, 6,
             7, 1, 3, 2, 6, 8, 5, 4,
             3, 2, 6, 5, 7, 4, 1, 8,
             1, 7, 5, 3, 8, 6, 4, 2,
             2, 5, 8, 4, 1, 7, 6, 3]
        )
    }
}
