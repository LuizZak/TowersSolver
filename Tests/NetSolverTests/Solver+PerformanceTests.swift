import XCTest
import NetSolver

class Solver_PerformanceTests: XCTestCase {
    func testSolve_4x4_performance() {
        // Game available at:
        // https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/net.html#4x4:48225b3556d73a64
        let gridGen = NetGridGenerator(rows: 4, columns: 4)
        gridGen.loadFromGameID("48225b3556d73a64")
        
        doMeasure {
            let sut = Solver(grid: gridGen.grid)
            
            _ = sut.solve()
        }
    }
    
    func testSolve_5x5_performance() {
        // Game available at:
        // https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/net.html#5x5:85b2225e8bc17be6be5546284
        let gridGen = NetGridGenerator(rows: 5, columns: 5)
        gridGen.loadFromGameID("85b2225e8bc17be6be5546284")
        
        doMeasure {
            let sut = Solver(grid: gridGen.grid)
            
            _ = sut.solve()
        }
    }
    
    func testSolve_7x7_performance() {
        // Game available at:
        // https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/net.html#7x7:84387c8c5e8b859ade369c88dab9c5bb18b86be4878647b41
        let gridGen = NetGridGenerator(rows: 7, columns: 7)
        gridGen.loadFromGameID("84387c8c5e8b859ade369c88dab9c5bb18b86be4878647b41")
        
        doMeasure {
            let sut = Solver(grid: gridGen.grid)
            sut.maxGuesses = 0
            
            _ = sut.solve()
        }
    }
    
    func testSolve_13x11_performance() {
        // Game available at:
        // https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/net.html#13x11:2e213351914861b57bb82e2a1587aca9dde5b7d268471a111e141151deb5c7e547b77dc7bd7752593d987344b31515124b613ee258daed7d8a3752de217171e2d92c978187881e1
        let gridGen = NetGridGenerator(rows: 11, columns: 13)
        gridGen.loadFromGameID("""
            2e213351914861b57bb82e2a1587aca9dde5\
            b7d268471a111e141151deb5c7e547b77dc7\
            bd7752593d987344b31515124b613ee258da\
            ed7d8a3752de217171e2d92c978187881e1
            """)
        
        doMeasure {
            let sut = Solver(grid: gridGen.grid)
            sut.maxGuesses = 0
            
            _ = sut.solve()
        }
    }
}
