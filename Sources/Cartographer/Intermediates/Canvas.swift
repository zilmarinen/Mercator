//
//  Canvas.swift
//  Mercator
//
//  Created by Zack Brown on 20/06/2026.
//

import CoreGraphics
import Deltille
import Euclid

internal struct Canvas {
    
    internal let context: CGContext
    internal let frame: CGRect
    
    internal let borderRect: CGRect
    
    internal let mapRect: CGRect
    internal let scale: Double
    
    internal init(bounds: Bounds,
                  scale: Double) {
        
        let marginBounds = [Triangle.zero].bounds(.chunk)
        let marginSize = CGSize(width: marginBounds.size.x * scale,
                                height: marginBounds.size.z * scale)
        
        let mapSize = CGSize(width: bounds.size.x * scale,
                             height: bounds.size.z * scale)
        
        let size = CGSize(width: mapSize.width + (marginSize.width * 2.0),
                          height: mapSize.height + (marginSize.height * 2.0))
        
        guard let context = CGContext(data: nil,
                                      width: Int(size.width),
                                      height: Int(size.height),
                                      bitsPerComponent: 8,
                                      bytesPerRow: 4 * Int(size.width),
                                      space: CGColorSpaceCreateDeviceRGB(),
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { fatalError("Invalid context") }
        
        self.context = context
        self.frame = .init(origin: .zero,
                           size: size)
        
        self.borderRect = .init(origin: .init(x: marginSize.width / 2.0,
                                              y: marginSize.height / 2.0),
                                size: .init(width: size.width - marginSize.width,
                                            height: size.height - marginSize.height))
        
        self.mapRect = .init(origin: .init(x: marginSize.width,
                                           y: marginSize.height),
                             size: mapSize)
        self.scale = scale
    }
}

internal extension Canvas {
    
    // MARK: Colors
    
    static let borderStroke = Color("303841")
    static let canvasBackground = Color("FDF6ED")
    
    func setFill(color: Color) {
        
        context.setFillColor(red: CGFloat(color.r),
                             green: CGFloat(color.g),
                             blue: CGFloat(color.b),
                             alpha: CGFloat(color.a))
    }
    
    func setStroke(color: Color) {
        
        context.setStrokeColor(red: CGFloat(color.r),
                               green: CGFloat(color.g),
                               blue: CGFloat(color.b),
                               alpha: CGFloat(color.a))
    }
}
