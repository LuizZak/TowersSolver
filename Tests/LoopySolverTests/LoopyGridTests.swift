//
//  LoopyGridTests.swift
//  TowersSolver
//
//  Created by Luiz Fernando Silva on 26/12/17.
//

import XCTest
@testable import LoopySolver

// TODO: Rewrite these tests since they had to be discarded after a major refactoring
// to the LoopyGrid struct
class LoopyGridTests: XCTestCase {
    
    static var allTests: [(String, () -> Void)] = [
        
    ]
    
    var grid: LoopyGrid!
    var width: Int = 5
    var height: Int = 6
    
    override func setUp() {
        super.setUp()
        
        grid = LoopyGrid()
    }
}

extension Sequence {
    func any(where compute: (Iterator.Element) -> Bool) -> Bool {
        for item in self {
            if compute(item) {
                return true
            }
        }
        
        return false
    }
    
    func all(_ compute: (Iterator.Element) -> Bool) -> Bool {
        for item in self {
            if !compute(item) {
                return false
            }
        }
        
        return true
    }
}
