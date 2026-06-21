//
//  RegionMappingOperation.swift
//  Mercator
//
//  Created by Zack Brown on 21/06/2026.
//

import Deltille
import PeakOperation

extension RegionMappingOperation: @unchecked Sendable {}

internal class RegionMappingOperation: ConcurrentOperation {
    
    private let canvas: Canvas
    private let region: Region
    
    internal init(_ canvas: Canvas,
                  region: Region) {
        
        self.canvas = canvas
        self.region = region
        
        super.init()
    }
    
    override internal func execute() {
        
        let triangle = Triangle(region.vertex)
        
        canvas.setFill(color: Canvas.borderStroke)
        
        canvas.draw(triangle: triangle,
                    scale: .region,
                    using:. stroke)
        
        if let water = region.water {
            
            render(water: water,
                   in: canvas)
        }
        
        render(terrain: region.terrain,
               in: canvas)
        
        finish()
    }
}

private extension RegionMappingOperation {
    
    // MARK: Terrain
    func render(terrain: TerrainStub,
                in canvas: Canvas) {
        
        terrain.stores.forEach { chunk in
        
            chunk.store.forEach { vertex in
                
                for tile in vertex.vertex.tiles {
                    
                    let index = (abs(tile.vertex.position.identifier) % 3)
                    
                    let pattern = tile.pattern
                    let kite = pattern.kites[index]
                    let rotation = Triangle.Rotation(turns: index)
                    
                    let vertices = kite.vertices.rotate(rotation)
                    
                    let stencil = tile.stencil(.tile)
                    
                    let color = vertex.biome.terrain.color(for: vertex.vertex.position.identifier,
                                                           [.primary,
                                                            .secondary,
                                                            .tertiary])
                    
                    canvas.setFill(color: color)
                    
                    canvas.draw(path: vertices,
                                stencil: stencil)
                }
            }
        }
    }
}

private extension RegionMappingOperation {
    
    // MARK: Water
    
    func render(water: WaterStub,
                in canvas: Canvas) {
        
        water.stores.forEach { chunk in
            
            chunk.store.forEach { tile in
                
                let triangle = Triangle(tile.vertex)
                
                let color = tile.waterType.colorPalette.color(for: tile.vertex.position.identifier,
                                                              [.primary,
                                                               .secondary,
                                                               .tertiary])
                
                canvas.setFill(color: color)
                
                canvas.draw(triangle: triangle,
                            scale: .tile)
            }
        }
    }
}
