import XCTest
import Geometry
@testable import LoopySolver

class LoopyFieldPrinterTests: XCTestCase {
    
    func testPrintSample() {
        var field = LoopyField()
        
        field.addVertex(Vertex(x: 0, y: 0))
        field.addVertex(Vertex(x: 50, y: 19))
        field.addVertex(Vertex(x: 88, y: 47))
        field.addVertex(Vertex(x: 31, y: 112))
        field.addVertex(Vertex(x: 423, y: 221))
        field.addVertex(Vertex(x: 197, y: 249))
        
        field.createFace(withVertexIndices: [0, 1, 3], hint: nil)
        field.createFace(withVertexIndices: [1, 2, 3], hint: 3)
        field.createFace(withVertexIndices: [2, 4, 3], hint: 1)
        field.createFace(withVertexIndices: [3, 5, 4], hint: nil)
        
        let printer = LoopyFieldPrinter(bufferWidth: 120, bufferHeight: 60)
        printer.printField(field: field)
    }
    
    func testPrintSquareGrid() {
        let generator = LoopySquareGridGen(width: 6, height: 6)
        
        generator.setHint(x: 1, y: 1, hint: 1)
        generator.setHint(x: 2, y: 3, hint: 3)
        
        generator.setHint(x: 0, y: 4, hint: 0)
        
        let field = generator.generate()
        
        let controller = LoopyFieldController(field: field)
        controller.setEdges(state: .disabled, forFace: .init(0))
        
        let printer = LoopyFieldPrinter(bufferWidth: 120, bufferHeight: 60)
        printer.printField(field: controller.field, width: 60, height: 30)
    }
}
