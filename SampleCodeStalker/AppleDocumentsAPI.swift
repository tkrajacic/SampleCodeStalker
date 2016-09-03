//
//  AppleDocumentsAPI.swift
//  SampleCodeStalker
//
//  Created by Thomas Krajacic on 6.2.2016.
//  Copyright © 2016 Thomas Krajacic. All rights reserved.
//

import Foundation

enum AppleDocumentsAPI {
    static let rootURLString: String = "https://developer.apple.com/library/"
    
    enum Platform: String {
        case mac = "mac", iOS = "ios", tvOS = "tvos", watchOS = "watchos"
    }
    
    case index
    case sampleCode(document: CDDocument)
    
    var url: URL {
        switch self {
        case .index: return URL(string: AppleDocumentsAPI.rootURLString + "prerelease/content/navigation/library.json")!
        case .sampleCode(let document): return document.url as URL
        }
    }
}
