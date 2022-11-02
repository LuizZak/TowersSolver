import PatternSolver

func statesFromBinaryRows(rowLength: Int, _ numbers: [UInt64]) -> [PatternTile.State] {
    var result: [PatternTile.State] = []

    for number in numbers {
        for index in 0..<rowLength {
            let bitIndex = (rowLength - index) - 1
            
            let bit = number >> bitIndex & 1 == 1

            if bit {
                result.append(.dark)
            } else {
                result.append(.light)
            }
        }
    }

    return result
}
