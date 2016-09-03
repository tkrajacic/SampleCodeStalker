//
//  Framework.swift
//  SampleCodeStalker
//
//  Created by Thomas Krajacic on 23.1.2016.
//  Copyright © 2016 Thomas Krajacic. All rights reserved.
//

import Foundation
import CoreData

class CDFramework: ManagedObject {
    
    @NSManaged open fileprivate(set) var id: Int16
    @NSManaged open fileprivate(set) var name: String
    @NSManaged open fileprivate(set) var key: Int16
    
    // Relationships
    @NSManaged open fileprivate(set) var parent: CDFramework?
    @NSManaged open fileprivate(set) var children: Set<CDFramework>
    @NSManaged open fileprivate(set) var documents: Set<CDDocument>
}

// MARK: - ManagedObjectType
extension CDFramework: ManagedObjectType {
    
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
    @discardableResult public static func updateOrInsertIntoContext(
        _ moc: NSManagedObjectContext,
        identifier: Int16,
        name: String,
        key: Int16,
        parent: CDFramework? = nil
        ) -> CDFramework {
        
        let framework = CDFramework.findOrCreateInContext(moc, matchingPredicate: NSPredicate(format: "id == \(identifier)")) { _ in }
        framework.id = identifier
        framework.name = name
        framework.key = key
        framework.parent = parent
        return framework
    }
}
