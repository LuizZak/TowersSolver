public class BaseLoopyGridGenerator: LoopyGridGenerator {
    var hints: [Int: Int] = [:]
    var facesCount: Int
    
    init(facesCount: Int) {
        self.facesCount = facesCount
    }
    
    public func setHint(faceIndex index: Int, hint: Int?) {
        hints[index] = hint
    }
    
    public func loadHints(from gameId: String) {
        hints = [:]
        
        var emptiesToMake = 0
        let chars = Array(gameId)
        var char = 0
        let faces = facesCount
        
        for f in 0..<faces {
            if emptiesToMake > 0 {
                emptiesToMake -= 1
                hints[f] = nil
                continue
            }
            
            let charInt = Int(chars[char].unicodeScalars.first!.value)
            
            let n = charInt - Int(("0" as UnicodeScalar).value)
            let n2 = charInt - Int(("A" as UnicodeScalar).value) + 10
            
            if n >= 0 && n < 10 {
                hints[f] = n
            } else if n2 >= 10 && n2 < 36 {
                hints[f] = n2
            } else {
                let n3 = charInt - Int(("a" as UnicodeScalar).value) + 1
                emptiesToMake = n3 - 1
            }
            char += 1
        }
    }
    
    public func generate() -> LoopyGrid {
        fatalError("Must be overriden by subclasses")
    }
}
