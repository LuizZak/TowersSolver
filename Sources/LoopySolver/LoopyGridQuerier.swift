import Geometry

/// A class that aids in faster querying of topological information about a loopy
/// field, like faces sharing an edge, edge closest to a point, face containing a
/// point and etc.
public class LoopyGridQuerier {
    
    private var grid: LoopyGrid
    private var faces: [GridFace]
    
    public init(grid: LoopyGrid) {
        self.grid = grid
        faces = grid.faces.enumerated().map {
            GridFace(grid: grid, faceId: .init($0.offset))
        }
    }
    
    public func faceUnder(point: Vertex) -> Face.Id? {
        return faces.first(where: { $0.polygon.contains(point) })?.faceId
    }
    
    /// Encapsulates a loopy grid face queried from a grid to construct its
    /// vertices
    private class GridFace: QuadTreeValue {
        let grid: LoopyGrid
        let faceId: Face.Id
        
        let polygon: Polygon<Float>
        
        var bounds: FloatRectangle {
            return polygon.bounds
        }
        
        init(grid: LoopyGrid, faceId: Face.Id) {
            self.grid = grid
            self.faceId = faceId
            
            let points = grid.polygonFor(face: faceId)
            polygon = Polygon(vertices: points)
        }
        
        public static func ==(lhs: GridFace, rhs: GridFace) -> Bool {
            return lhs.faceId == rhs.faceId
        }
    }
}
