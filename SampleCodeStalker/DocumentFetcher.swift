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
        
        let request = NSMutableURLRequest(URL: url, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10)
        let configuration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        let session = NSURLSession(configuration: configuration)
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            guard let data = data, response = response as? NSHTTPURLResponse
                where error == nil && response.statusCode == 200 else { return }
            
            if let jsonData = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments),
                let jsonDict = jsonData as? [String:AnyObject] {
                
                completionHandler(json: jsonDict)
                
            }
        }
        
        task.resume()
        
    }
    
}