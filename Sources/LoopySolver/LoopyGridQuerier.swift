import Geometry

/// A class that aids in faster querying of topological information about a loopy
/// field, like faces sharing an edge, edge closest to a point, face containing a
/// point and etc.
public class LoopyGridQuerier {
    
    private var grid: LoopyGrid
    private var faces: [GridFace]
    
    public init(grid: LoopyGrid) {
        self.grid = grid
        faces = grid.faces.map {
            GridFace(grid: grid, faceId: $0)
        }
    }
    
    public func faceUnder(point: Vertex) -> Face.Id? {
        return faces.first(where: { $0.polygon.contains(point) })?.faceId
    }
    
    /// Encapsulates a loopy grid face queried from a grid to construct its
    /// vertices
    private class GridFace: QuadTreeValue {
        let grid: LoopyGrid
        let faceId: Int
        
        let polygon: Polygon<Float>
        
        var bounds: FloatRectangle {
            return polygon.bounds
        }
        
        init(grid: LoopyGrid, faceId: Int) {
            self.grid = grid
            self.faceId = faceId
            
            let points = grid.polygonFor(faceId: faceId)
            polygon = Polygon(vertices: points)
        }
        
        public static func ==(lhs: GridFace, rhs: GridFace) -> Bool {
            return lhs.faceId == rhs.faceId
        }
    }
}
