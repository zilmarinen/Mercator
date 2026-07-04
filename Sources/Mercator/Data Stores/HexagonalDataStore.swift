//
//  HexagonalDataStore.swift
//  Mercator
//
//  Created by Zack Brown on 04/07/2026.
//

import Deltille
import Harvest
import Lattice

internal class HexagonalDataStore<V: DataStoreValue>: Decodable {
    
    internal let stores: [HexagonalDataStoreChunk<V>]
}

internal extension HexagonalDataStore {
    
    func chunk(for hexagon: Hexagon,
               _ from: Hexagon.Scale) -> HexagonalDataStoreChunk<V>? {
        
        let region = hexagon.transpose(from,
                                       .chunk)
        
        return stores.first {
            
            $0.hexagon == region
        }
    }
    
    func value(for key: Triangle.Vertex) -> V? {
        
        let hexagon = Hexagon(key.position(.tile),
                              .chunk)
        
        guard let chunk = chunk(for: hexagon,
                                .chunk) else { return nil }
        
        return chunk.value(for: key.position)
    }
    
    func wedge(for sieve: Triangle.Sieve) -> DataStoreWedge<V> {
        
        let data = sieve.vertices.reduce(into: [Triangle.Vertex : V]()) { result, vertex in
            
            result[vertex] = value(for: vertex)
        }
        
        return .init(data: data)
    }
}
