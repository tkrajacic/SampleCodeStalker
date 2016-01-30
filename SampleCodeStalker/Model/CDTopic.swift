//
//  Topic.swift
//  SampleCodeStalker
//
//  Created by Thomas Krajacic on 23.1.2016.
//  Copyright © 2016 Thomas Krajacic. All rights reserved.
//

import Foundation
import CoreData

public class CDTopic : ManagedObject {
    
    @NSManaged public private(set) var id: Int16
    @NSManaged public private(set) var name: String
    @NSManaged public private(set) var key: Int16
    
    // Relationships
    @NSManaged public private(set) var parent: CDTopic?
    @NSManaged public private(set) var children: Set<CDTopic>
    @NSManaged public private(set) var topicOfDocuments: Set<CDDocument>
    @NSManaged public private(set) var subTopicOfDocuments: Set<CDDocument>
}

// MARK: - ManagedObjectType
extension CDTopic : ManagedObjectType {
    
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
    public static func updateOrInsertIntoContext(
        moc: NSManagedObjectContext,
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