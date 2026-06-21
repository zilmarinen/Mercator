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

extension CanvasToImageOperation: @unchecked Sendable {}

internal class CanvasToImageOperation: ConcurrentOperation,
                                       ConsumesResult,
                                       ProducesResult {
    
    internal var input: Result<CanvasSetupOperation.OperationResult, any Error> = Result { throw ResultError.noResult }
    internal var output: Result<World, any Error> = Result { throw ResultError.noResult }
    
    override internal func execute() {
        
        do {
            
            let (canvas, world) = try input.get()
            
            let surface = world.regions.map {
                            
                Triangle($0.vertex)
            }
            
            canvas.context.setFillColor(red: 0.6901960784313725,
                                        green: 0.7294117647058823,
                                        blue: 0.6,
                                        alpha: 1.0)
            
            for triangle in surface {
                
                guard let start = triangle.vertices.last?.position(.region) else { continue }
                
                canvas.context.beginPath()
                canvas.context.move(to: .init(x: start.x * canvas.scale,
                                              y: start.z * canvas.scale))
                
                for vertex in triangle.vertices {

                    let position = vertex.position(.region)
                
                    canvas.context.addLine(to: .init(x: position.x * canvas.scale,
                                                     y: position.z * canvas.scale))
                }
                
                canvas.context.fillPath()
                
                canvas.context.closePath()
            }
            
            guard let cgImage = canvas.context.makeImage() else { fatalError("Error creating image") }
            
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
