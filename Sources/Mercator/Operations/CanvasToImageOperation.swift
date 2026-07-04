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

public class CanvasToImageOperation: ConcurrentOperation,
                                     ConsumesResult,
                                     ProducesResult {
    
    public var input: Result<CanvasSetupOperation.OperationResult, any Error> = Result { throw ResultError.noResult }
    public var output: Result<World, any Error> = Result { throw ResultError.noResult }
    
    private let fileManager = FileManager.default
    
    private let filename: String
    
    public init(filename: String) {
        
        self.filename = filename
        
        super.init()
    }
    
    override public func execute() {
        
        do {
            
            let (canvas, world) = try input.get()
            
            guard let cgImage = canvas.context.makeImage() else { fatalError("Error creating image") }
            
            let path = fileManager.currentDirectoryPath.appending("/\(filename)")
            
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
