//
//  LoopyGridPrinterTests.swift
//  LoopySolverTests
//
//  Created by Luiz Silva on 27/12/2017.
//

import XCTest
@testable import LoopySolver

class LoopyGridPrinterTests: XCTestCase {
    
    func testPrintSample() {
        var grid = Grid(width: 7, height: 7)
        
        let e: Int? = nil
        let hints = [
            e, e, 3, e, 3, e, 3,
            3, e, e, 2, e, 3, e,
            2, 0, e, e, e, e, e,
            e, 0, e, e, e, e, 3,
            e, e, e, 1, 2, 2, 1,
            3, e, e, 3, e, e, e,
            e, e, 3, e, 1, 1, 3
        ]
        
        grid.setHints(hints)
        
        grid.setEdgeValue(.marked, onEdgeCardinal: .top, forCellAtX: 0, y: 0)
        grid.setEdgeValue(.marked, onEdgeCardinal: .left, forCellAtX: 0, y: 0)
        grid.setEdgeValue(.marked, onEdgeCardinal: .left, forCellAtX: 0, y: 1)
        grid.setEdgeValue(.marked, onEdgeCardinal: .bottom, forCellAtX: 0, y: 1)
        grid.setEdgeValue(.marked, onEdgeCardinal: .right, forCellAtX: 0, y: 1)
        grid.setEdgeValue(.marked, onEdgeCardinal: .top, forCellAtX: 1, y: 1)
        
        grid.setEdgeValue(.disabled, onEdgeCardinal: .top, forCellAtX: 1, y: 0)
        grid.setEdgeValue(.disabled, onEdgeCardinal: .top, forCellAtX: 2, y: 0)
        grid.setEdgeValue(.disabled, onEdgeCardinal: .left, forCellAtX: 2, y: 0)
        
        LoopyGridPrinter.printGrid(grid: grid)
    }
}
