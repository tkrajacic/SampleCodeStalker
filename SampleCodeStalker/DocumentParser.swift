//
//  DocumentParser.swift
//  SampleCodeStalker
//
//  Created by Thomas Krajacic on 23.1.2016.
//  Copyright © 2016 Thomas Krajacic. All rights reserved.
//

import Cocoa

struct DocumentParser {
    
    let moc : NSManagedObjectContext
    let dateFormatter : NSDateFormatter = {
        let df = NSDateFormatter()
        df.dateFormat = "YYYY-mm-dd"
        return df
    }()
    
    init(managedObjectContext: NSManagedObjectContext) {
        self.moc = managedObjectContext
    }
    
    func parse(json: [String:AnyObject], completionHandler: (()->Void)? = nil) {
        
        // This should have: topics (Resource Types, Topics, Frameworks), updateSize, columns, documents
        guard let
            resourceTypes = json.resourceTypes,
            frameworks = json.frameworks,
            topics = json.topics,
            documents = json.documents,
            columns = json.columns
        else {
            print("Unexpected data")
            return
        }
        
        parseResourceTypes(resourceTypes)
        parseFrameworks(frameworks)
        parseTopics(topics)
        parseDocuments(documents, columns: columns)
        
        mainThread { completionHandler?() }

    }
    
    private func parseResourceTypes(dict: [[String:AnyObject]]) {
        moc.performChanges {

            dict.forEach { resourceType in
                guard let
                    name        = resourceType["name"] as? String,
                    idString    = resourceType["id"] as? String,
                    key         = resourceType["key"] as? String,
                    sortOrder   = resourceType["sortOrder"] as? String
                else { return }
                
                CDResourceType.updateOrInsertIntoContext(self.moc,
                    identifier: idString,
                    name: name.stringByReplacingOccurrencesOfString("&amp;", withString: "&"),
                    key: Int16(key) ?? -1,
                    sortOrder: Int16(sortOrder) ?? 0
                )
                
            }
            
        }
    }
    
    private func parseFrameworks(dict: [[String:AnyObject]]) {
        moc.performChanges {
            
            dict.forEach { framework in
                guard let
                    name        = framework["name"] as? String,
                    id          = framework["id"] as? Int,
                    key         = framework["key"] as? String
                else { return }

                CDFramework.updateOrInsertIntoContext(self.moc,
                    identifier: Int16(id),
                    name: name.stringByReplacingOccurrencesOfString("&amp;", withString: "&"),
                    key: Int16(key) ?? -1
                )
            }
            
        }
    }
    
    private func parseTopics(dict: [[String:AnyObject]]) {
        moc.performChanges {
        
        dict.forEach { topic in
            guard let
                name        = topic["name"] as? String,
                id          = topic["id"] as? Int,
                key         = topic["key"] as? String
            else { return }
            
            let parent = (topic["parent"] as? String).flatMap {
                CDTopic.findOrFetchInContext(self.moc, matchingPredicate: NSPredicate(format: "key == \($0)"))
            }
            
            CDTopic.updateOrInsertIntoContext(self.moc,
                identifier: Int16(id),
                name: name.stringByReplacingOccurrencesOfString("&amp;", withString: "&"),
                key: Int16(key) ?? -1,
                parent: parent
            )
        }
        
        }
    }
    
    private func parseDocuments(array: [[AnyObject]], columns: [String:Int]) {
        moc.performChanges {
        // for now let's ignore the columns and hardcode the order
        
        // filter out everything that's not sample code
        guard let sampleCodeType = CDResourceType.findOrFetchInContext(self.moc, matchingPredicate: NSPredicate(format: "name == 'Sample Code'"))?.key
        else { return }
        
            array.forEach { document in
                guard let
                    name        = document[0] as? String,
                    idString    = document[1] as? String,
                    type        = document[2] as? Int,
                    dateString  = document[3] as? String,
                    date        = self.dateFormatter.dateFromString(dateString),
                    updateSize  = document[4] as? Int,
                    topic       = document[5] as? Int,
                    framework   = document[6] as? Int,
                    release     = document[7] as? Int,
                    subtopic    = document[8] as? Int,
                    url         = document[9] as? String,
                    sortOrder   = document[10] as? Int,
                    displayDateString = document[11] as? String,
                    displayDate = self.dateFormatter.dateFromString(displayDateString)
                    where type == Int(sampleCodeType)
                    else { return }
                
                
                CDDocument.updateOrInsertIntoContext(self.moc,
                    identifier: idString,
                    name: name.stringByReplacingOccurrencesOfString("&amp;", withString: "&"),
                    type: CDResourceType.findOrFetchInContext(self.moc, matchingPredicate: NSPredicate(format: "key == \(type)")),
                    url: NSURL(string: url)!,
                    date: date,
                    displayDate: displayDate,
                    sortOrder: Int16(sortOrder) ?? 0,
                    updateSize: CDDocument.UpdateSize(rawValue: Int16(updateSize) ?? 0) ?? .Unknown,
                    releaseVersion: Int16(release),
                    topic: CDTopic.findOrFetchInContext(self.moc, matchingPredicate: NSPredicate(format: "key == \(topic)")),
                    subTopic: CDTopic.findOrFetchInContext(self.moc, matchingPredicate: NSPredicate(format: "key == \(subtopic)")),
                    framework: CDFramework.findOrFetchInContext(self.moc, matchingPredicate: NSPredicate(format: "key == \(framework)"))
                )
            }
            
        }
    }
}

private extension Dictionary where Key: StringLiteralConvertible, Value: AnyObject {
    
    var sections : [[String:AnyObject]]? {
        return self["topics"] as? [[String:AnyObject]]
    }
    
    var resourceTypes : [[String:AnyObject]]? {
        return self.sections?.filter({ ($0["name"] as? String) == "Resource Types" }).first?["contents"] as? [[String:AnyObject]]
    }
    
    var frameworks : [[String:AnyObject]]? {
        return self.sections?.filter({ ($0["name"] as? String) == "Frameworks" }).first?["contents"] as? [[String:AnyObject]]
    }
    
    var topics : [[String:AnyObject]]? {
        return self.sections?.filter({ ($0["name"] as? String) == "Topics" }).first?["contents"] as? [[String:AnyObject]]
    }
    
    var documents : [[AnyObject]]? {
        return self["documents"] as? [[AnyObject]]
    }
    
    var columns : [String:Int]? {
        return self["columns"] as? [String:Int]
    }
    
    var updateSize : [String]? {
        return self["updateSize"] as? [String]
    }
}