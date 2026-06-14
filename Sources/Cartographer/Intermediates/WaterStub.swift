//
//  Water.swift
//  Mercator
//
//  Created by Zack Brown on 14/06/2026.
//

import Deltille
import Harvest

internal struct WaterStub: Decodable {
    
    internal let stores: [WaterChunkStub]
}

internal struct WaterChunkStub: Decodable {
    
    internal let vertex: Coordinate
    internal let store: [WaterTileStub]
}

internal struct WaterTileStub: Decodable {
    
    internal let vertex: Triangle.Vertex
    internal let elevation: Int
    internal let waterType: WaterType
}
