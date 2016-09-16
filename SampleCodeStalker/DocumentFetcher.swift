//
//  DocumentFetcher.swift
//  SampleCodeStalker
//
//  Created by Thomas Krajacic on 23.1.2016.
//  Copyright © 2016 Thomas Krajacic. All rights reserved.
//

import Foundation


struct DocumentFetcher {
    
    let url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    func fetch(_ completionHandler: @escaping (_ json: [String:AnyObject])->Void) {
        
        let request = URLRequest(url: url, cachePolicy: .reloadRevalidatingCacheData, timeoutInterval: 10)
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        
        session.dataTask(with: request) { data, response, error in
            guard let data = data, let response = response as? HTTPURLResponse
                , error == nil && response.statusCode == 200 else { return }
            
            let jsonString = String(data: data, encoding: String.Encoding.utf8)!.replacingOccurrences(of: ",\n           }", with: "}")
            let newData = jsonString.data(using: String.Encoding.utf8)!
            
            if let jsonData = try? JSONSerialization.jsonObject(with: newData, options: JSONSerialization.ReadingOptions.allowFragments),
                let jsonDict = jsonData as? [String:AnyObject] {
                
                completionHandler(jsonDict)
                
            }
        }.resume()
    }
}

extension DocumentFetcher {
    init(endpoint: AppleDocumentsAPI) {
        self.url = endpoint.url
    }
}
