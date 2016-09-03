//
//  Topic.swift
//  SampleCodeStalker
//
//  Created by Thomas Krajacic on 23.1.2016.
//  Copyright © 2016 Thomas Krajacic. All rights reserved.
//

import Foundation
import CoreData

class CDTopic: ManagedObject {
    
    @NSManaged open fileprivate(set) var id: Int16
    @NSManaged open fileprivate(set) var name: String
    @NSManaged open fileprivate(set) var key: Int16
    
    // Relationships
    @NSManaged open fileprivate(set) var parent: CDTopic?
    @NSManaged open fileprivate(set) var children: Set<CDTopic>
    @NSManaged open fileprivate(set) var topicOfDocuments: Set<CDDocument>
    @NSManaged open fileprivate(set) var subTopicOfDocuments: Set<CDDocument>
}

// MARK: - ManagedObjectType
extension CDTopic: ManagedObjectType {
    
    public static var entityName: String {
        return "CDTopic"
    }
    
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: "name", ascending: true)]
    }
    
    public static var defaultPredicate: NSPredicate {
        return NSPredicate(value: true)
    }
    
}

// MARK: - Creation
extension CDTopic {
    @discardableResult public static func updateOrInsertIntoContext(
        _ moc: NSManagedObjectContext,
        identifier: Int16,
        name: String,
        key: Int16,
        parent: CDTopic? = nil
        ) -> CDTopic {
        
        let topic = CDTopic.findOrCreateInContext(moc, matchingPredicate: NSPredicate(format: "id == \(identifier)")) { _ in }
        topic.id = identifier
        topic.name = name
        topic.key = key
        topic.parent = parent
        return topic
    }
}
