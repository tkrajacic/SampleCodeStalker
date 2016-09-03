//
//  ResourceType.swift
//  SampleCodeStalker
//
//  Created by Thomas Krajacic on 23.1.2016.
//  Copyright © 2016 Thomas Krajacic. All rights reserved.
//

import Foundation
import CoreData

class CDResourceType: ManagedObject {
    
    @NSManaged open fileprivate(set) var id: String
    @NSManaged open fileprivate(set) var name: String
    @NSManaged open fileprivate(set) var key: Int16
    @NSManaged open fileprivate(set) var sortOrder: Int16
    
    // Relationships
    @NSManaged open fileprivate(set) var documents: Set<CDDocument>
}

// MARK: - ManagedObjectType
extension CDResourceType: ManagedObjectType {
    
    public static var entityName: String {
        return "CDResourceType"
    }
    
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: "name", ascending: true)]
    }
    
    public static var defaultPredicate: NSPredicate {
        return NSPredicate(value: true)
    }
    
}

// MARK: - Creation
extension CDResourceType {
    @discardableResult public static func updateOrInsertIntoContext(
        _ moc: NSManagedObjectContext,
        identifier: String,
        name: String,
        key: Int16,
        sortOrder: Int16
        ) -> CDResourceType {
        
        let resourceType = CDResourceType.findOrCreateInContext(moc, matchingPredicate: NSPredicate(format: "id == '\(identifier)'")) { _ in }
        resourceType.id = identifier
        resourceType.name = name
        resourceType.key = key
        resourceType.sortOrder = sortOrder
        return resourceType
    }
}
