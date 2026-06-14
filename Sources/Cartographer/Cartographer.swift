//
//  Cartographer.swift
//  Mercator
//
//  Created by Zack Brown on 14/06/2026.
//

import Foundation

internal class Cartographer {
    
    internal let group = DispatchGroup()
    internal let queue = OperationQueue()
    
    private let documentPath: String
    
    internal init(documentPath: String) {
        
        self.documentPath = documentPath
    }
    
    internal func execute() {
        
        // MARK: Setup
        
        let url = URL(filePath: documentPath)
        
        // MARK: Operations
        
        let loadDocument = LoadDocumentOperation(url: url)
        let mapWorld = MappingOperation()
        
        group.enter()
        
        loadDocument.passesResult(to: mapWorld).enqueue(on: queue) { [weak self] result in
            
            guard let self else { return }
            
            switch result {
                
            case .success: break
                
            case .failure(let error):
                
                print("Error: [\(error.localizedDescription)]")
            }
        
            self.group.leave()
        }
        
        group.wait()
    }
}
