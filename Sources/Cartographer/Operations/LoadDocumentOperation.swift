//
//  LoadDocumentOperation.swift
//  Mercator
//
//  Created by Zack Brown on 14/06/2026.
//

import Foundation
import PeakOperation

extension LoadDocumentOperation: @unchecked Sendable {}

internal class LoadDocumentOperation: ConcurrentOperation,
                                      ProducesResult {
    
    internal var output: Result<World, any Error> = Result { throw ResultError.noResult }
    
    private let decoder = JSONDecoder()
    
    private let url: URL
     
    internal init(url: URL) {
     
        self.url = url
        
        super.init()
    }
    
    override internal func execute() {
        
        do {
            
            let document = try FileWrapper(url: url)
            
            guard let directory = document.fileWrappers else { fatalError("Invalid document") }
            
            let regionsDirectory = directory["regions"]?.fileWrappers ?? [:]
            
            let regions: [Region] = try regionsDirectory.reduce(into: [Region]()) { result, item in
                
                guard let data = item.value.regularFileContents else { return }
                
                result.append(try decoder.decode(Region.self,
                                                 from: data))
            }
            
            let world = World(regions: regions)
            
            output = .success(world)
        }
        catch {
         
            output = .failure(error)
        }
        
        finish()
    }
}
