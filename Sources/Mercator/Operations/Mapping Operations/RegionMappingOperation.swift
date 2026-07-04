//
//  RegionMappingOperation.swift
//  Mercator
//
//  Created by Zack Brown on 21/06/2026.
//

import Deltille
import Foundation
import Harvest
import PeakOperation

extension RegionMappingOperation: @unchecked Sendable {}

internal class RegionMappingOperation: ConcurrentOperation {
    
    private let group = DispatchGroup()
    
    private let canvas: Canvas
    private let region: Region
    private let triangle: Triangle
    private let sieve: Triangle.Sieve
    
    internal init(_ canvas: Canvas,
                  region: Region) {
        
        let triangle = Triangle(region.vertex)
        
        self.canvas = canvas
        self.region = region
        self.triangle = triangle
        self.sieve = triangle.sieve(for: .region)
        
        super.init()
        
        internalQueue.maxConcurrentOperationCount = 1
    }
    
    override internal func execute() {
        
        var operations: [ConcurrentOperation] = []
        
        if let water = region.water {
            
            operations.append(WaterRenderOperation(canvas,
                                                   triangle: triangle,
                                                   sieve: sieve,
                                                   store: water))
        }
        
        operations.append(TerrainRenderOperation(canvas,
                                                 triangle: triangle,
                                                 sieve: sieve,
                                                 store: region.terrain,
                                                 water: region.water))
        
        for operation in operations {
            
            operation.addDidFinishBlock { [weak self] in
                
                guard let self else { return }
                
                self.group.leave()
            }
            
            group.enter()
            
            operation.enqueue(on: internalQueue)
        }
        
        group.wait()
        
        finish()
    }
}
