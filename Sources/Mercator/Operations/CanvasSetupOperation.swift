//
//  CanvasSetupOperation.swift
//  Mercator
//
//  Created by Zack Brown on 20/06/2026.
//

import Deltille
import PeakOperation

extension CanvasSetupOperation: @unchecked Sendable {}

public class CanvasSetupOperation: ConcurrentOperation,
                                   ConsumesResult,
                                   ProducesResult {
    
    public typealias OperationResult = (canvas: Canvas,
                                        world: World)
    
    public var input: Result<World, any Error> = Result { throw ResultError.noResult }
    public var output: Result<OperationResult, any Error> = Result { throw ResultError.noResult }
    
    private let scale: Int
     
    public init(scale: Int) {
     
        self.scale = scale
        
        super.init()
    }
    
    override public func execute() {
        
        do {
            
            let world = try input.get()
            
            let surface = world.regions.map {
                
                Triangle($0.vertex)
            }
            
            let canvas = Canvas(bounds: surface.bounds(.region),
                                scale: Double(scale))
            
            canvas.setFill(color: Canvas.canvasBackground)
            canvas.context.fill(canvas.frame)
            
            canvas.setStroke(color: Canvas.borderStroke)
            canvas.context.stroke(canvas.borderRect)
            
            canvas.setStroke(color: Canvas.borderStroke)
            canvas.context.stroke(canvas.mapRect)
            
            output = .success((canvas,
                              world))
        }
        catch {
            
            output = .failure(error)
        }
        
        finish()
    }
}
