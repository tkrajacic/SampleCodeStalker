//
//  Notifications.swift
//  Moody
//
//  Created by Daniel Eggert on 24/05/2015.
//  Copyright (c) 2015 objc.io. All rights reserved.
//

import Foundation
import CoreData


public struct ContextDidSaveNotification {
    
    public init(note: Notification) {
        guard note.name == NSNotification.Name.NSManagedObjectContextDidSave else { fatalError() }
        notification = note
    }
    
    public var insertedObjects: AnyIterator<ManagedObject> {
        return generatorForKey(NSInsertedObjectsKey)
    }
    
    public var updatedObjects: AnyIterator<ManagedObject> {
        return generatorForKey(NSUpdatedObjectsKey)
    }
    
    public var deletedObjects: AnyIterator<ManagedObject> {
        return generatorForKey(NSDeletedObjectsKey)
    }
    
    public var managedObjectContext: NSManagedObjectContext {
        guard let c = notification.object as? NSManagedObjectContext else { fatalError("Invalid notification object") }
        return c
    }
    
    
    // MARK: Private
    
    fileprivate let notification: Notification
    
    fileprivate func generatorForKey(_ key: String) -> AnyIterator<ManagedObject> {
        guard let set = (notification as NSNotification).userInfo?[key] as? NSSet else {
            return AnyIterator { nil }
        }
        let innerGenerator = set.makeIterator()
        return AnyIterator { return innerGenerator.next() as? ManagedObject }
    }
    
}


extension ContextDidSaveNotification: CustomDebugStringConvertible {
    public var debugDescription: String {
        var components = [notification.name]
        components.append(Notification.Name(rawValue: managedObjectContext.description))
        for (name, set) in [("inserted", insertedObjects), ("updated", updatedObjects), ("deleted", deletedObjects)] {
            let all = set.map { $0.objectID.description }.joined(separator: ", ")
            components.append(Notification.Name(rawValue: "\(name): {\(all)})"))
        }
        return components.map({ "\($0)" }).joined(separator: " ")
    }
}


public struct ContextWillSaveNotification {
    
    public init(note: Notification) {
        assert(note.name == NSNotification.Name.NSManagedObjectContextWillSave)
        notification = note
    }
    
    public var managedObjectContext: NSManagedObjectContext {
        guard let c = notification.object as? NSManagedObjectContext else { fatalError("Invalid notification object") }
        return c
    }
    
    
    // MARK: Private
    
    private let notification: Notification
    
}


public struct ObjectsDidChangeNotification {
    
    init(note: Notification) {
        assert(note.name == NSNotification.Name.NSManagedObjectContextObjectsDidChange)
        notification = note
    }
    
    public var insertedObjects: Set<ManagedObject> {
        return objectsForKey(NSInsertedObjectsKey)
    }
    
    public var updatedObjects: Set<ManagedObject> {
        return objectsForKey(NSUpdatedObjectsKey)
    }
    
    public var deletedObjects: Set<ManagedObject> {
        return objectsForKey(NSDeletedObjectsKey)
    }
    
    public var refreshedObjects: Set<ManagedObject> {
        return objectsForKey(NSRefreshedObjectsKey)
    }
    
    public var invalidatedObjects: Set<ManagedObject> {
        return objectsForKey(NSInvalidatedObjectsKey)
    }
    
    public var invalidatedAllObjects: Bool {
        return (notification as NSNotification).userInfo?[NSInvalidatedAllObjectsKey] != nil
    }
    
    public var managedObjectContext: NSManagedObjectContext {
        guard let c = notification.object as? NSManagedObjectContext else { fatalError("Invalid notification object") }
        return c
    }
    
    
    // MARK: Private
    
    private let notification: Notification
    
    private func objectsForKey(_ key: String) -> Set<ManagedObject> {
        return ((notification as NSNotification).userInfo?[key] as? Set<ManagedObject>) ?? Set()
    }
    
}


extension NSManagedObjectContext {
    
    /// Adds the given block to the default `NSNotificationCenter`'s dispatch table for the given context's did-save notifications.
    /// - returns: An opaque object to act as the observer. This must be sent to the default `NSNotificationCenter`'s `removeObserver()`.
    public func addContextDidSaveNotificationObserver(_ handler: @escaping (ContextDidSaveNotification) -> ()) -> NSObjectProtocol {
        let nc = NotificationCenter.default
        return nc.addObserver(forName: NSNotification.Name.NSManagedObjectContextDidSave, object: self, queue: nil) { note in
            let wrappedNote = ContextDidSaveNotification(note: note)
            handler(wrappedNote)
        }
    }
    
    /// Adds the given block to the default `NSNotificationCenter`'s dispatch table for the given context's will-save notifications.
    /// - returns: An opaque object to act as the observer. This must be sent to the default `NSNotificationCenter`'s `removeObserver()`.
    public func addContextWillSaveNotificationObserver(_ handler: @escaping (ContextWillSaveNotification) -> ()) -> NSObjectProtocol {
        let nc = NotificationCenter.default
        return nc.addObserver(forName: NSNotification.Name.NSManagedObjectContextWillSave, object: self, queue: nil) { note in
            let wrappedNote = ContextWillSaveNotification(note: note)
            handler(wrappedNote)
        }
    }
    
    /// Adds the given block to the default `NSNotificationCenter`'s dispatch table for the given context's objects-did-change notifications.
    /// - returns: An opaque object to act as the observer. This must be sent to the default `NSNotificationCenter`'s `removeObserver()`.
    public func addObjectsDidChangeNotificationObserver(_ handler: @escaping (ObjectsDidChangeNotification) -> ()) -> NSObjectProtocol {
        let nc = NotificationCenter.default
        return nc.addObserver(forName: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: self, queue: nil) { note in
            let wrappedNote = ObjectsDidChangeNotification(note: note)
            handler(wrappedNote)
        }
    }
    
    public func performMergeChangesFromContextDidSaveNotification(_ note: ContextDidSaveNotification) {
        perform {
            self.mergeChanges(fromContextDidSave: note.notification)
        }
    }
    
}

