//
//  Region.swift
//  Mercator
//
//  Created by Zack Brown on 14/06/2026.
//

import Deltille

internal struct Region: Decodable {
    
    internal let vertex: Triangle.Vertex
    
    internal let terrain: TerrainStub
    internal let water: WaterStub?
}
