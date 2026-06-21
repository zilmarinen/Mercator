//
//  MappingOperation.swift
//  Mercator
//
//  Created by Zack Brown on 21/06/2026.
//

import CoreData
import PeakOperation

extension MappingOperation: @unchecked Sendable {}

internal class MappingOperation: ConcurrentOperation,
                                 ConsumesResult,
                                 ProducesResult {
    
    internal var input: Result<CanvasSetupOperation.OperationResult, any Error> = Result { throw ResultError.noResult }
    internal var output: Result<CanvasSetupOperation.OperationResult, any Error> = Result { throw ResultError.noResult }
    
    private let group = DispatchGroup()
    
    override internal init() {
        
        super.init()
        
        self.internalQueue.maxConcurrentOperationCount = 1
    }
    
    override internal func execute() {
        
        do {
            
            let (canvas, world) = try input.get()
            
            for region in world.regions {
                
                let operation = RegionMappingOperation(canvas,
                                                       region: region)
                
                group.enter()
                
                operation.addDidFinishBlock { [weak self] in
                    
                    guard let self else { return }
                    
                    self.group.leave()
                }
                
                operation.enqueue(on: internalQueue)
            }
            
            group.wait()
            
            output = .success((canvas, world))
        }
        catch {
            
            output = .failure(error)
        }
        
        finish()
    }
}
