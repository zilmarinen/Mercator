//
//  Mercator.swift
//  Mercator
//
//  Created by Zack Brown on 13/06/2026.
//

import ArgumentParser
import Foundation

@main
internal struct Mercator: ParsableCommand {
    
    @Option(help: "Orchard Document Path")
    internal var documentPath: String
    
    @Option(help: "Scale")
    internal var scale: Int = 10
    
    internal mutating func run() throws {
        
        print("\n\u{001B}[94m-------")
        print("[Mercator]")
        print("-------\u{001B}[0m\n")
        
        let cartographer = Cartographer(documentPath: documentPath,
                                        scale: scale)
        
        cartographer.execute()
    }
}
