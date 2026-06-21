//
//  CanvasToImageOperation.swift
//  Mercator
//
//  Created by Zack Brown on 14/06/2026.
//

import CoreGraphics
import CoreServices
import Deltille
import Euclid
import Foundation
import ImageIO
import PeakOperation
import UniformTypeIdentifiers

extension CanvasToImageOperation: @unchecked Sendable {}

internal class CanvasToImageOperation: ConcurrentOperation,
                                       ConsumesResult,
                                       ProducesResult {
    
    internal var input: Result<CanvasSetupOperation.OperationResult, any Error> = Result { throw ResultError.noResult }
    internal var output: Result<World, any Error> = Result { throw ResultError.noResult }
    
    private let fileManager = FileManager.default
    
    override internal func execute() {
        
        do {
            
            let (canvas, world) = try input.get()
            
            guard let cgImage = canvas.context.makeImage() else { fatalError("Error creating image") }
            
            let path = fileManager.currentDirectoryPath.appending("/mercator.png")
            
            let url = URL(fileURLWithPath: path) as CFURL
            let type = UTType.png.identifier as CFString
            
            guard let destination = CGImageDestinationCreateWithURL(url,
                                                                    type,
                                                                    1,
                                                                    nil) else { fatalError("Invalid destination") }
            
            CGImageDestinationAddImage(destination, cgImage, nil)
            
            CGImageDestinationFinalize(destination)
            
            output = .success(world)
        }
        catch {
            
            output = .failure(error)
        }
        
        finish()
    }
}
