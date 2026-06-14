//
//  Terrain.swift
//  Mercator
//
//  Created by Zack Brown on 14/06/2026.
//

import Deltille
import Harvest

internal struct TerrainStub: Decodable {
    
    internal let stores: [TerrainChunkStub]
}

internal struct TerrainChunkStub: Decodable {
    
    internal let vertex: Coordinate
    internal let store: [TerrainVertexStub]
}

internal struct TerrainVertexStub: Decodable {
    
    internal let vertex: Triangle.Vertex
    internal let biome: Biome
    internal let elevation: Int
}
