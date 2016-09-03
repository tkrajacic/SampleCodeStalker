//
//  Document.swift
//  SampleCodeStalker
//
//  Created by Thomas Krajacic on 23.1.2016.
//  Copyright © 2016 Thomas Krajacic. All rights reserved.
//

import Foundation
import CoreData

public class CDDocument: ManagedObject {
    
    public enum UpdateSize: Int16 {
        case firstVersion = 0, contentUpdate = 1, minorChange = 2, unknown = 3
    }
    
    @NSManaged public private(set) var id: String
    @NSManaged public private(set) var name: String
    @NSManaged public private(set) var url: NSURL
    @NSManaged public private(set) var date: NSDate
    @NSManaged public private(set) var displayDate: NSDate
    @NSManaged public private(set) var sortOrder: Int16
    @NSManaged public private(set) var releaseVersion: Int16
    @NSManaged public private(set) var platform: String
    
    public private(set) var updateSize: UpdateSize {
        get { return UpdateSize(rawValue: updateSizeRaw) ?? .unknown }
        set { updateSizeRaw = newValue.rawValue }
    }
    @NSManaged private var updateSizeRaw: Int16
    
    // Relationships
    @NSManaged public private(set) var framework: CDFramework?
    @NSManaged public private(set) var topic: CDTopic?
    @NSManaged public private(set) var subTopic: CDTopic?
    @NSManaged public private(set) var type: CDResourceType?
    
    
    
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
    public static func updateOrInsertIntoContext(
        moc: NSManagedObjectContext,
        identifier: String,
        name: String,
        type: CDResourceType?,
        url: NSURL,
        date: NSDate,
        displayDate: NSDate,
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
