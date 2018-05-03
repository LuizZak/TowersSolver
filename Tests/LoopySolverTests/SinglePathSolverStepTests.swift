import XCTest
@testable import LoopySolver

class SinglePathSolverStepTests: XCTestCase {
    var sut: SinglePathSolverStep!
    
    override func setUp() {
        super.setUp()
        
        sut = SinglePathSolverStep()
    }
    
    func testApplyOnTrivial() {
        // Test a trivial case where a face with the exact required number of edges
        // hanging as a unique path around the cell:
        //
        // •───•───•───•
        // │   │   │   │
        // •───•───•───•
        // |   │ 3 │   |
        // •   •───•   •
        // |           |
        // •───•───•───•
        let gridGen = LoopySquareGridGen(width: 3, height: 3)
        gridGen.setHint(x: 1, y: 1, hint: 3)
        let controller = LoopyFieldController(field: gridGen.generate())
        controller.setEdge(state: .disabled, forFace: 3, edgeIndex: 2)
        controller.setEdge(state: .disabled, forFace: 5, edgeIndex: 2)
        controller.setEdge(state: .disabled, forFace: 6, edgeIndex: 1)
        controller.setEdge(state: .disabled, forFace: 7, edgeIndex: 1)
        
        let result = sut.apply(to: controller.field)
        
        let edgeStatesForFace: (Int) -> [Edge.State] = {
            result.edges(forFace: $0).map(result.edgeState(forEdge:))
        }
        XCTAssertEqual(edgeStatesForFace(4)[0], .normal)
        XCTAssertEqual(edgeStatesForFace(4)[1], .marked)
        XCTAssertEqual(edgeStatesForFace(4)[2], .marked)
        XCTAssertEqual(edgeStatesForFace(4)[3], .marked)
    }
}
