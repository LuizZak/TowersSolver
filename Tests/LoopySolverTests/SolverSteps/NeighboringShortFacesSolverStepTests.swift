import XCTest
@testable import LoopySolver

class NeighboringShortFacesSolverStepTests: XCTestCase {
    var sut: NeighboringShortFacesSolverStep!
    var delegate: SolverStepDelegate!
    
    override func setUp() {
        super.setUp()
        
        sut = NeighboringShortFacesSolverStep()
        delegate = TestSolverStepDelegate()
    }
    
    func testIsEphemeral() {
        XCTAssertFalse(sut.isEphemeral)
    }
    
    func testOneFacesOnEdges() {
        // Test a scenario like the follow:
        // •───•───•───•───•
        // │   │ 1 │ 1 │   │
        // •───•───•───•───•
        // │   │   │   │   │
        // •───•───•───•───•
        // The result should be a disabled edge between the two `1` faces:
        // •───•───•───•───•
        // │   │ 1   1 │   │
        // •───•───•───•───•
        // │   │   │   │   │
        // •───•───•───•───•
        let gridGen = LoopySquareGridGen(width: 4, height: 2)
        gridGen.setHint(x: 1, y: 0, hint: 1)
        gridGen.setHint(x: 2, y: 0, hint: 1)
        
        let result = sut.apply(to: gridGen.generate(), delegate)
        
        let edgesForFace: (Int) -> [Edge.Id] = {
            result.edges(forFace: $0)
        }
        let edgeStatesForFace: (Int) -> [Edge.State] = {
            edgesForFace($0).map(result.edgeState(forEdge:))
        }
        // Top-left
        XCTAssertEqual(edgeStatesForFace(0), [.normal, .normal, .normal, .normal])
        // `1` top-center-left
        XCTAssertEqual(edgeStatesForFace(1), [.normal, .disabled, .normal, .normal])
        // `1` top-center-right
        XCTAssertEqual(edgeStatesForFace(2), [.normal, .normal, .normal, .disabled])
        // Top-right
        XCTAssertEqual(edgeStatesForFace(3), [.normal, .normal, .normal, .normal])
        // Bottom-left
        XCTAssertEqual(edgeStatesForFace(4), [.normal, .normal, .normal, .normal])
        // Bottom-center-left
        XCTAssertEqual(edgeStatesForFace(5), [.normal, .normal, .normal, .normal])
        // Bottom-center-right
        XCTAssertEqual(edgeStatesForFace(6), [.normal, .normal, .normal, .normal])
        // Bottom-right
        XCTAssertEqual(edgeStatesForFace(7), [.normal, .normal, .normal, .normal])
    }
    
    func testDisabledEdgesCountingTowardsRequirement() {
        // Test a scenario like the follow:
        // •───•───•───•   •
        // │   │ 1 │ 2 │
        // •───•───•───•───•
        // │   │   │   │   │
        // •───•───•───•───•
        // The result should be a disabled vertical edge between the two faces:
        // •───•───•───•   •
        // │   │ 1   2 │
        // •───•───•───•───•
        // │   │   │   │   │
        // •───•───•───•───•
        let gridGen = LoopySquareGridGen(width: 4, height: 2)
        gridGen.setHint(x: 1, y: 0, hint: 1)
        gridGen.setHint(x: 2, y: 0, hint: 2)
        let controller = LoopyGridController(grid: gridGen.generate())
        controller.setEdge(state: .disabled, forFace: 3, edgeIndex: 0)
        controller.setEdge(state: .disabled, forFace: 3, edgeIndex: 1)
        
        let result = sut.apply(to: controller.grid, delegate)
        
        let edgesForFace: (Int) -> [Edge.Id] = {
            result.edges(forFace: $0)
        }
        let edgeStatesForFace: (Int) -> [Edge.State] = {
            edgesForFace($0).map(result.edgeState(forEdge:))
        }
        // Top-left
        XCTAssertEqual(edgeStatesForFace(0), [.normal, .normal, .normal, .normal])
        // `1` top-center-left
        XCTAssertEqual(edgeStatesForFace(1), [.normal, .disabled, .normal, .normal])
        // `2` top-center-right
        XCTAssertEqual(edgeStatesForFace(2), [.normal, .normal, .normal, .disabled])
        // Top-right
        XCTAssertEqual(edgeStatesForFace(3), [.disabled, .disabled, .normal, .normal])
        // Bottom-left
        XCTAssertEqual(edgeStatesForFace(4), [.normal, .normal, .normal, .normal])
        // Bottom-center-left
        XCTAssertEqual(edgeStatesForFace(5), [.normal, .normal, .normal, .normal])
        // Bottom-center-right
        XCTAssertEqual(edgeStatesForFace(6), [.normal, .normal, .normal, .normal])
        // Bottom-right
        XCTAssertEqual(edgeStatesForFace(7), [.normal, .normal, .normal, .normal])
    }
    
    func testNegativeCase() {
        // Test a scenario like the follow:
        // •───•───•───•───•
        // │   │ 2 │ 2 │   │
        // •───•───•───•───•
        // │   │   │   │   │
        // •───•───•───•───•
        // Solver should not alter the grid, since it's already valid.
        let gridGen = LoopySquareGridGen(width: 4, height: 2)
        gridGen.setHint(x: 1, y: 0, hint: 2)
        gridGen.setHint(x: 2, y: 0, hint: 2)
        let before = gridGen.generate()
        
        let result = sut.apply(to: before, delegate)
        
        XCTAssertEqual(before, result)
    }
    
    func testNegativeCase2() {
        // Test a scenario like the follow:
        // •───•───•───•───•
        // ║   │           │
        // •───•   •═══•   •
        // │ 2 │ 3 ║   │   │
        // •───•═══•   •───•
        // Solver should not alter the grid, since it's already valid.
        let gridGen = LoopySquareGridGen(width: 4, height: 2)
        gridGen.setHint(x: 0, y: 1, hint: 2)
        gridGen.setHint(x: 1, y: 1, hint: 2)
        let controller = LoopyGridController(grid: gridGen.generate())
        controller.setEdge(state: .marked, forFace: 0, edgeIndex: 3)
        controller.setEdges(state: .disabled, forFace: 1, edgeIndices: [1, 2])
        controller.setEdge(state: .marked, forFace: 2, edgeIndex: 2)
        controller.setEdges(state: .disabled, forFace: 3, edgeIndices: [2, 3])
        controller.setEdges(state: .marked, forFace: 5, edgeIndices: [1, 2])
        controller.setEdge(state: .disabled, forFace: 6, edgeIndex: 2)
        let before = controller.grid
        
        let result = sut.apply(to: before, delegate)
        
        XCTAssertEqual(before, result)
    }
}
