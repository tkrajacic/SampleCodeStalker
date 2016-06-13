//
//  DocumentFetcher.swift
//  SampleCodeStalker
//
//  Created by Thomas Krajacic on 23.1.2016.
//  Copyright © 2016 Thomas Krajacic. All rights reserved.
//

import Foundation


struct DocumentFetcher {
    
    let url: NSURL
    
    init(url: NSURL) {
        self.url = url
    }
    
    func fetch(completionHandler: (json: [String:AnyObject])->Void) {
        
        let request = NSMutableURLRequest(URL: url, cachePolicy: .ReloadRevalidatingCacheData, timeoutInterval: 10)
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: configuration)
        
        session.dataTaskWithRequest(request) { data, response, error in
            guard let data = data, response = response as? NSHTTPURLResponse
                where error == nil && response.statusCode == 200 else { return }
            
            let jsonString = NSString(data: data, encoding: NSUTF8StringEncoding)!.stringByReplacingOccurrencesOfString(",\n           }", withString: "}")
            let newData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)!
            
            if let jsonData = try? NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments),
                let jsonDict = jsonData as? [String:AnyObject] {
                
                completionHandler(json: jsonDict)
                
            }
        }.resume()
    }
}

extension DocumentFetcher {
    init(endpoint: AppleDocumentsAPI) {
        self.url = endpoint.url
    }
}