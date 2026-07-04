//
//  TriangularDataStore.swift
//  Mercator
//
//  Created by Zack Brown on 04/07/2026.
//

import Deltille
import Harvest
import Lattice

internal class TriangularDataStore<V: TriangularDataStoreTile>: Decodable {
    
    internal let stores: [TriangularDataStoreChunk<V>]
}

internal extension TriangularDataStore {
    
    func chunk(for triangle: Triangle,
               _ from: Triangle.Scale) -> TriangularDataStoreChunk<V>? {
        
        let region = triangle.transpose(from,
                                        .chunk)
        
        return stores.first {
            
            $0.triangle == region
        }
    }
    
    func value(for key: Triangle) -> V? {
        
        guard let chunk = chunk(for: key,
                                .tile) else { return nil }
        
        return chunk.value(for: key.vertex.position)
    }
    
    func wedge(for sieve: Triangle.Sieve) -> DataStoreWedge<V> {
        
        let data = sieve.triangles.reduce(into: [Triangle.Vertex : V]()) { result, triangle in
            
            result[triangle.vertex] = value(for: triangle)
        }
        
        return .init(data: data)
    }
}
