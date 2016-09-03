//
//  DocumentParser.swift
//  SampleCodeStalker
//
//  Created by Thomas Krajacic on 23.1.2016.
//  Copyright © 2016 Thomas Krajacic. All rights reserved.
//

import Cocoa

struct DocumentParser {
    
    let moc: NSManagedObjectContext
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.timeZone = TimeZone(identifier: "PST")
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()
    
    init(managedObjectContext: NSManagedObjectContext) {
        self.moc = managedObjectContext
    }
    
    func parse(_ json: [String:AnyObject], completionHandler: (() -> Void)? = nil) {
        
        // This should have: topics (Resource Types, Topics, Frameworks), updateSize, columns, documents
        guard let
            resourceTypes = json.resourceTypes,
            let frameworks = json.frameworks,
            let topics = json.topics,
            let documents = json.documents,
            let columns = json.columns
        else {
            return print("Unexpected data")
        }
        
        parseResourceTypes(resourceTypes)
        parseFrameworks(frameworks)
        parseTopics(topics)
        parseDocuments(documents, columns: columns)
        
        DispatchQueue.main.async { completionHandler?() }

    }
    
    fileprivate func parseResourceTypes(_ dict: [[String:AnyObject]]) {
        moc.performChanges {

            dict.forEach { resourceType in
                guard let
                    name        = resourceType["name"] as? String,
                    let idString    = resourceType["id"] as? String,
                    let key         = resourceType["key"] as? String,
                    let sortOrder   = resourceType["sortOrder"] as? String
                else { return }
                
                CDResourceType.updateOrInsertIntoContext(self.moc,
                    identifier: idString,
                    name: name.replacingOccurrences(of: "&amp;", with: "&"),
                    key: Int16(key) ?? -1,
                    sortOrder: Int16(sortOrder) ?? 0
                )
                
            }
            
        }
    }
    
    fileprivate func parseFrameworks(_ dict: [[String:AnyObject]]) {
        moc.performChanges {
            
            dict.forEach { framework in
                guard let
                    name        = framework["name"] as? String,
                    let id          = framework["id"] as? Int,
                    let key         = framework["key"] as? String
                else { return }

                CDFramework.updateOrInsertIntoContext(self.moc,
                    identifier: Int16(id),
                    name: name.replacingOccurrences(of: "&amp;", with: "&"),
                    key: Int16(key) ?? -1
                )
            }
            
        }
    }
    
    fileprivate func parseTopics(_ dict: [[String:AnyObject]]) {
        moc.performChanges {
        
        dict.forEach { topic in
            guard let
                name        = topic["name"] as? String,
                let id          = topic["id"] as? Int,
                let key         = topic["key"] as? String
            else { return }
            
            let parent = (topic["parent"] as? String).flatMap {
                CDTopic.findOrFetchInContext(self.moc, matchingPredicate: NSPredicate(format: "key == \($0)"))
            }
            
            CDTopic.updateOrInsertIntoContext(self.moc,
                identifier: Int16(id),
                name: name.replacingOccurrences(of: "&amp;", with: "&"),
                key: Int16(key) ?? -1,
                parent: parent
            )
        }
        
        }
    }
    
    fileprivate func parseDocuments(_ array: [[AnyObject]], columns: [String:Int]) {
        moc.performChanges {
        // for now let's ignore the columns and hardcode the order
        
            // filter out everything that's not sample code
            guard let sampleCodeType = CDResourceType.findOrFetchInContext(self.moc, matchingPredicate: NSPredicate(format: "name == 'Sample Code'"))?.key
                else { return }
            
            array.forEach { document in
                guard let
                    name        = document[0] as? String,
                    let idString    = document[1] as? String,
                    let type        = document[2] as? Int,
                    let dateString  = document[3] as? String,
                    let date        = self.dateFormatter.date(from: dateString),
                    let updateSize  = document[4] as? Int,
                    let topic       = document[5] as? Int,
                    let framework   = document[6] as? Int,
                    let release     = document[7] as? Int,
                    let subtopic    = document[8] as? Int,
                    let urlString   = document[9] as? String,
                    let sortOrder   = document[10] as? Int,
                    let displayDateString = document[11] as? String,
                    let displayDate = self.dateFormatter.date(from: displayDateString),
                    let platform    = document[11] as? String
                    , type == Int(sampleCodeType)
                    else { return }
                
                let cleanedURLString = urlString.hasPrefix("../") ? urlString.substring(from: urlString.characters.index(urlString.startIndex, offsetBy: 3)): urlString
                let url = URL(string: AppleDocumentsAPI.rootURLString + "prerelease/content/" + cleanedURLString)!
                
                CDDocument.updateOrInsertIntoContext(self.moc,
                    identifier: idString,
                    name: name.replacingOccurrences(of: "&amp;", with: "&"),
                    type: CDResourceType.findOrFetchInContext(self.moc, matchingPredicate: NSPredicate(format: "key == \(type)")),
                    url: url,
                    date: date,
                    displayDate: displayDate,
                    sortOrder: Int16(sortOrder),
                    updateSize: CDDocument.UpdateSize(rawValue: Int16(updateSize) ) ?? .unknown,
                    releaseVersion: Int16(release),
                    topic: CDTopic.findOrFetchInContext(self.moc, matchingPredicate: NSPredicate(format: "key == \(topic)")),
                    subTopic: CDTopic.findOrFetchInContext(self.moc, matchingPredicate: NSPredicate(format: "key == \(subtopic)")),
                    framework: CDFramework.findOrFetchInContext(self.moc, matchingPredicate: NSPredicate(format: "key == \(framework)")),
                    platform: platform
                )
            }
        }
    }
}

private extension Dictionary where Key: ExpressibleByStringLiteral, Value: AnyObject {
    
    var sections: [[String:AnyObject]]? {
        return self["topics"] as? [[String:AnyObject]]
    }
    
    var resourceTypes: [[String:AnyObject]]? {
        return self.sections?.filter({ ($0["name"] as? String) == "Resource Types" }).first?["contents"] as? [[String:AnyObject]]
    }
    
    var frameworks: [[String:AnyObject]]? {
        return self.sections?.filter({ ($0["name"] as? String) == "Technologies" }).first?["contents"] as? [[String:AnyObject]]
    }
    
    var topics: [[String:AnyObject]]? {
        return self.sections?.filter({ ($0["name"] as? String) == "Topics" }).first?["contents"] as? [[String:AnyObject]]
    }
    
    var documents: [[AnyObject]]? {
        return self["documents"] as? [[AnyObject]]
    }
    
    var columns: [String:Int]? {
        return self["columns"] as? [String:Int]
    }
    
    var updateSize: [String]? {
        return self["updateSize"] as? [String]
    }
}
