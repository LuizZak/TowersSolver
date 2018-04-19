//
//  LoopyGridPrinterTests.swift
//  LoopySolverTests
//
//  Created by Luiz Silva on 27/12/2017.
//

import XCTest
@testable import Geometry
@testable import LoopySolver

class LoopyGridPrinterTests: XCTestCase {
    
    func testPrintSample() {
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
        printer.printGrid(grid: grid)
    }
    
    func testPrintSquareGrid() {
        let generator = LoopySquareGrid(width: 6, height: 6)
        
        generator.setHint(x: 1, y: 1, hint: 1)
        generator.setHint(x: 2, y: 3, hint: 3)
        
        generator.setHint(x: 0, y: 4, hint: 0)
        
        let grid = generator.generate()
        
        let printer = LoopyGridPrinter(bufferWidth: 120, bufferHeight: 60)
        printer.printGrid(grid: grid, width: 60, height: 30)
    }
}
