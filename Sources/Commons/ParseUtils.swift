/// Utility functions for interfacing with encoded game IDs.
public enum ParseUtils {
    /// Decodes an ASCII unicode scalar into a number.
    /// Treats the first ascii index `startIndex` as `1`, counting up from it.
    public static func charToInt(_ character: UnicodeScalar, startIndex: UnicodeScalar = "a") -> Int {
        return Int(character.value - startIndex.value + 1)
    }
}
