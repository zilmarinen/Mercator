//
//  MappingOperation.swift
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

extension MappingOperation: @unchecked Sendable {}

internal class MappingOperation: ConcurrentOperation,
                                 ConsumesResult,
                                 ProducesResult {
    
    internal var input: Result<World, any Error> = Result { throw ResultError.noResult }
    internal var output: Result<World, any Error> = Result { throw ResultError.noResult }
    
    override internal func execute() {
        
        do {
            
            let world = try input.get()
            
            let surface = world.regions.map {
                
                Triangle($0.vertex)
            }
            
            let bounds = surface.bounds(.region)
            
            guard let context = CGContext(data: nil,
                                          width: 100,
                                          height: 100,
                                          bitsPerComponent: 8,
                                          bytesPerRow: 4 * 100,
                                          space: CGColorSpaceCreateDeviceRGB(),
                                          bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { fatalError("Invalid context") }
            
            context.setFillColor(red: 1.0, green: 0.4, blue: 0.2, alpha: 1.0)
            context.fill(.init(x: 0, y: 0, width: 50, height: 50))
            
            guard let cgImage = context.makeImage() else { fatalError("Error creating image") }
            
            let fileManager = FileManager.default
            
            let path = fileManager.currentDirectoryPath.appending("mercator.png")
            
            let url = URL(fileURLWithPath: path) as? CFURL
            
            guard let destination = CGImageDestinationCreateWithURL(url!, kUTTypePNG, 1, nil) else { fatalError("Invalid destination") }
            
            CGImageDestinationAddImage(destination, cgImage, nil)
            
            output = .success(world)
        }
        catch {
            
            output = .failure(error)
        }
        
        finish()
    }
}
