//
//  TerrainRenderOperation.swift
//  Mercator
//
//  Created by Zack Brown on 04/07/2026.
//

import Deltille
import Foundation
import Harvest
import Lattice
import PeakOperation

extension TerrainRenderOperation: @unchecked Sendable {}

internal class TerrainRenderOperation: ConcurrentOperation {
    
    private let canvas: Canvas
    private let triangle: Triangle
    private let sieve: Triangle.Sieve
    private let store: HexagonalDataStore<TerrainVertex>
    private let water: TriangularDataStore<WaterTile>?
    
    internal init(_ canvas: Canvas,
                  triangle: Triangle,
                  sieve: Triangle.Sieve,
                  store: HexagonalDataStore<TerrainVertex>,
                  water: TriangularDataStore<WaterTile>?) {
        
        self.canvas = canvas
        self.triangle = triangle
        self.sieve = sieve
        self.store = store
        self.water = water
        
        super.init()
    }
    
    override internal func execute() {
        
        let wedge = store.wedge(for: sieve)
        let weave = wedge.weave(sieve)
        
        let waterWedge = water?.wedge(for: sieve)
        
        weave.data.forEach { (_, tile) in
            
            let waterElevation = waterWedge?.value(for: tile.triangle.vertex)?.elevation ?? 0
            
            render(tile: tile,
                   waterElevation: waterElevation)
        }
     
        finish()
    }
}

private extension TerrainRenderOperation {
    
    func render(tile: DataStoreStitch<TerrainVertex>,
                waterElevation: Int) {
        
        let triangle = tile.triangle
        let pattern = triangle.pattern
        let stencil = triangle.stencil(.tile)
        
        let i = (abs(triangle.vertex.position.identifier) % 3)
        let j = (i + 1) % 3
        let k = (i + 2) % 3
        
        let c0 = triangle.corners[i]
        let c1 = triangle.corners[j]
        let c2 = triangle.corners[k]
        
        let tv0 = triangle.vertex(c0)
        let tv1 = triangle.vertex(c1)
        let tv2 = triangle.vertex(c2)
        
        let v0 = tile.vertices[tv0]
        let v1 = tile.vertices[tv1]
        let v2 = tile.vertices[tv2]
        
        let r0 = Triangle.Rotation(turns: i)
        let r1 = Triangle.Rotation(turns: j)
        let r2 = Triangle.Rotation(turns: k)
        
        let k0 = pattern.kites[i]
        let k1 = pattern.kites[j]
        let k2 = pattern.kites[k]
        
        let o0 = k0.vertices.rotate(r0)
        let o1 = k1.vertices.rotate(r1)
        let o2 = k2.vertices.rotate(r2)
        
        let pairs = [(v0, o0),
                     (v1, o1),
                     (v2, o2)]
        
        for s in pairs.indices {
            
            let t = (s + 1) % pairs.count
            let u = (s + 2) % pairs.count
            
            let (vertex, outline) = pairs[s]
            let (lv, lo) = pairs[t]
            let (rv, ro) = pairs[u]
            
            guard let vertex,
                  vertex.elevation >= waterElevation else { continue }
         
            render(vertex: vertex,
                   outline: outline,
                   stencil: stencil,
                   leftElevation: lv?.elevation ?? 0,
                   leftOutline: lo,
                   rightElevation: rv?.elevation ?? 0,
                   rightOutline: ro)
        }
    }
    
    private func render(vertex: TerrainVertex,
                        outline: [Triangle.Stencil.Vertex],
                        stencil: Triangle.Stencil,
                        leftElevation: Int,
                        leftOutline: [Triangle.Stencil.Vertex],
                        rightElevation: Int,
                        rightOutline: [Triangle.Stencil.Vertex]) {
        
        let color = vertex.biome.terrain.color(for: vertex.vertex.position.identifier,
                                               [.primary,
                                                .secondary,
                                                .tertiary])
        
        canvas.setFill(color: color)
        
        canvas.draw(path: outline,
                    stencil: stencil,
                    using: .fill)
        
        guard vertex.elevation > leftElevation ||
                vertex.elevation > rightElevation else { return }
        
        let outline = outline.dropFirst()
        
        for i in outline.indices.dropLast() {
            
            let j = (i + 1)
            
            let sv0 = outline[i]
            let sv1 = outline[j]
            
            let lor = leftOutline.contains(sv0) && leftOutline.contains(sv1)
            
            let adjacentElevation = lor ? leftElevation : rightElevation
            
            guard vertex.elevation > adjacentElevation else { continue }
            
            canvas.setStroke(color: .black)
            
            canvas.draw(line: [sv0, sv1],
                        stencil: stencil)
        }
    }
}
