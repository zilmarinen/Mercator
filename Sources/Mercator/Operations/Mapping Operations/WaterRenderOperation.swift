//
//  WaterRenderOperation.swift
//  Mercator
//
//  Created by Zack Brown on 04/07/2026.
//

import Deltille
import Foundation
import Harvest
import PeakOperation

extension WaterRenderOperation: @unchecked Sendable {}

internal class WaterRenderOperation: ConcurrentOperation {
    
    private let canvas: Canvas
    private let triangle: Triangle
    private let sieve: Triangle.Sieve
    private let store: TriangularDataStore<WaterTile>
    
    internal init(_ canvas: Canvas,
                  triangle: Triangle,
                  sieve: Triangle.Sieve,
                  store: TriangularDataStore<WaterTile>) {
        
        self.canvas = canvas
        self.triangle = triangle
        self.sieve = sieve
        self.store = store
        
        super.init()
    }
    
    override internal func execute() {
     
        let wedge = store.wedge(for: sieve)
        
        wedge.data.forEach { (key, tile) in
            
            let color = tile.waterType.colorPalette.color(for: key.position.identifier,
                                                          [.primary,
                                                           .secondary,
                                                           .tertiary])
            
            canvas.setFill(color: color)
            
            canvas.draw(triangle: .init(key),
                        scale: .tile)
        }
     
        finish()
    }
}
