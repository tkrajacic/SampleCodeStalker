//
//  Document.swift
//  SampleCodeStalker
//
//  Created by Thomas Krajacic on 23.1.2016.
//  Copyright © 2016 Thomas Krajacic. All rights reserved.
//

import Foundation
import CoreData

class CDDocument: ManagedObject {
    
    public enum UpdateSize: Int16 {
        case firstVersion = 0, contentUpdate = 1, minorChange = 2, unknown = 3
    }
    
    @NSManaged open fileprivate(set) var id: String
    @NSManaged open fileprivate(set) var name: String
    @NSManaged open fileprivate(set) var url: URL
    @NSManaged open fileprivate(set) var date: Date
    @NSManaged open fileprivate(set) var displayDate: Date
    @NSManaged open fileprivate(set) var sortOrder: Int16
    @NSManaged open fileprivate(set) var releaseVersion: Int16
    @NSManaged open fileprivate(set) var platform: String
    
    open fileprivate(set) var updateSize: UpdateSize {
        get { return UpdateSize(rawValue: updateSizeRaw) ?? .unknown }
        set { updateSizeRaw = newValue.rawValue }
    }
    @NSManaged fileprivate var updateSizeRaw: Int16
    
    // Relationships
    @NSManaged open fileprivate(set) var framework: CDFramework?
    @NSManaged open fileprivate(set) var topic: CDTopic?
    @NSManaged open fileprivate(set) var subTopic: CDTopic?
    @NSManaged open fileprivate(set) var type: CDResourceType?
    
    
    
}

// MARK: - ManagedObjectType
extension CDDocument: ManagedObjectType {
    
    public static var entityName: String {
        return "CDDocument"
    }
    
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: "date", ascending: false)]
    }
    
    public static var defaultPredicate: NSPredicate {
        return NSPredicate(value: true)
    }
    
}

// MARK: - Creation
extension CDDocument {
    @discardableResult public static func updateOrInsertIntoContext(
        _ moc: NSManagedObjectContext,
        identifier: String,
        name: String,
        type: CDResourceType?,
        url: URL,
        date: Date,
        displayDate: Date,
        sortOrder: Int16,
        updateSize: UpdateSize,
        releaseVersion: Int16,
        topic: CDTopic?,
        subTopic: CDTopic?,
        framework: CDFramework?,
        platform: String
        ) -> CDDocument {
        
        let document = CDDocument.findOrCreateInContext(moc, matchingPredicate: NSPredicate(format: "id == '\(identifier)'")) {_ in}
        document.id = identifier
        document.name = name
        document.type = type
        document.url = url
        document.date = date
        document.displayDate = displayDate
        document.sortOrder = sortOrder
        document.updateSize = updateSize
        document.releaseVersion = releaseVersion
        document.topic = topic
        document.subTopic = subTopic
        document.framework = framework
        return document
    }
}
