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
    private let scale: Int
    
    internal init(documentPath: String,
                  scale: Int) {
        
        self.documentPath = documentPath
        self.scale = scale
    }
    
    internal func execute() {
        
        // MARK: Setup
        
        let url = URL(filePath: documentPath)
        
        // MARK: Operations
        
        let loadDocument = LoadDocumentOperation(url: url)
        let setupCanvas = CanvasSetupOperation(scale: scale)
        let canvasToImage = CanvasToImageOperation()
        
        group.enter()
        
        loadDocument.passesResult(to: setupCanvas)
            .passesResult(to: canvasToImage)
            .enqueue(on: queue) { [weak self] result in
            
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
