//
//  ResourceType.swift
//  SampleCodeStalker
//
//  Created by Thomas Krajacic on 23.1.2016.
//  Copyright © 2016 Thomas Krajacic. All rights reserved.
//

import Foundation
import CoreData

public class CDResourceType : ManagedObject {
    
    @NSManaged public private(set) var id: String
    @NSManaged public private(set) var name: String
    @NSManaged public private(set) var key: Int16
    @NSManaged public private(set) var sortOrder: Int16
    
    // Relationships
    @NSManaged public private(set) var documents: Set<CDDocument>
}

// MARK: - ManagedObjectType
extension CDResourceType : ManagedObjectType {
    
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
    public static func insertIntoContext(moc: NSManagedObjectContext, identifier: String, name: String, key: Int16, sortOrder: Int16) -> CDResourceType {
        let resourceType: CDResourceType = moc.insertObject()
        resourceType.id = identifier
        resourceType.name = name
        resourceType.key = key
        resourceType.sortOrder = sortOrder
        return resourceType
    }
}