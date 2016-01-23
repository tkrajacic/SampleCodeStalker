//
//  Framework.swift
//  SampleCodeStalker
//
//  Created by Thomas Krajacic on 23.1.2016.
//  Copyright © 2016 Thomas Krajacic. All rights reserved.
//

import Foundation
import CoreData

public class CDFramework : ManagedObject {
    
    @NSManaged public private(set) var id: Int16
    @NSManaged public private(set) var name: String
    @NSManaged public private(set) var key: Int16
    
    // Relationships
    @NSManaged public private(set) var parent: CDFramework?
    @NSManaged public private(set) var children: Set<CDFramework>
    @NSManaged public private(set) var documents: Set<CDDocument>
}

// MARK: - ManagedObjectType
extension CDFramework : ManagedObjectType {
    
    public static var entityName: String {
        return "CDFramework"
    }
    
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: "name", ascending: true)]
    }
    
    public static var defaultPredicate: NSPredicate {
        return NSPredicate(value: true)
    }
    
}

// MARK: - Creation
extension CDFramework {
    public static func insertIntoContext(moc: NSManagedObjectContext, identifier: Int16, name: String, key: Int16, parent: CDFramework? = nil) -> CDFramework {
        let framework: CDFramework = moc.insertObject()
        framework.id = identifier
        framework.name = name
        framework.key = key
        framework.parent = parent
        return framework
    }
}