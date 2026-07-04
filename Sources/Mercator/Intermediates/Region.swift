//
//  Region.swift
//  Mercator
//
//  Created by Zack Brown on 13/06/2026.
//

import Deltille
import Harvest

internal struct Region: Decodable {
    
    internal let vertex: Triangle.Vertex
    
    internal let terrain: HexagonalDataStore<TerrainVertex>
    internal let water: TriangularDataStore<WaterTile>?
}
