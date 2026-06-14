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
            
            let scale = 1.0
            let bounds = surface.bounds(.region)
            let rect = CGRect(x: 0,
                              y: 0,
                              width: ceil(bounds.size.x) * scale,
                              height: ceil(bounds.size.z) * scale)
            
            guard let context = CGContext(data: nil,
                                          width: Int(rect.size.width),
                                          height: Int(rect.size.height),
                                          bitsPerComponent: 8,
                                          bytesPerRow: 4 * Int(rect.size.width),
                                          space: CGColorSpaceCreateDeviceRGB(),
                                          bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { fatalError("Invalid context") }
            
            context.setFillColor(red: 0.9686274509803922,
                                 green: 0.9450980392156862,
                                 blue: 0.8705882352941177,
                                 alpha: 1.0)
            context.fill(rect)
            
            context.setFillColor(red: 0.6901960784313725,
                                 green: 0.7294117647058823,
                                 blue: 0.6,
                                 alpha: 1.0)
            
            for triangle in surface {
                
                guard let start = triangle.vertices.last?.position(.region) else { continue }
                
                context.beginPath()
                context.move(to: .init(x: start.x * scale,
                                       y: start.z * scale))
                
                for vertex in triangle.vertices {
                    
                    let position = vertex.position(.region)
                
                    context.addLine(to: .init(x: position.x * scale,
                                              y: position.z * scale))
                }
                
                context.fillPath()
                
                context.closePath()
            }
            
            guard let cgImage = context.makeImage() else { fatalError("Error creating image") }
            
            let fileManager = FileManager.default
            
            let path = fileManager.currentDirectoryPath.appending("/mercator.png")
            
            let url = URL(fileURLWithPath: path) as? CFURL
            
            guard let destination = CGImageDestinationCreateWithURL(url!,
                                                                    kUTTypePNG,
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
