//
//  AppleDocumentsAPI.swift
//  SampleCodeStalker
//
//  Created by Thomas Krajacic on 6.2.2016.
//  Copyright © 2016 Thomas Krajacic. All rights reserved.
//

import Foundation

enum AppleDocumentsAPI {
    private static let rootURLString: String = "https://developer.apple.com/library/"
    
    enum Platform : String {
        case Mac = "mac", iOS = "ios"
    }
    
    case Index(Platform)
//    case SampleCode(Platform)
    
    var url: NSURL {
        switch self {
        case .Index(let platform): return NSURL(string: AppleDocumentsAPI.rootURLString + platform.rawValue + "/navigation/library.json")!
//        case .SampleCode(let platform): return AppleDocumentsAPI.rootURLString + platform.rawValue + "/..."
        }
    }
}