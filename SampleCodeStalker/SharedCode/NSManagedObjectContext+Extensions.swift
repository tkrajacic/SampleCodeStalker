//
//  Extensions.swift
//  Moody
//
//  Created by Florian on 07/05/15.
//  Copyright (c) 2015 objc.io. All rights reserved.
//

import CoreData


extension NSManagedObjectContext {

    fileprivate var store: NSPersistentStore {
        guard let psc = persistentStoreCoordinator else { fatalError("PSC missing") }
        guard let store = psc.persistentStores.first else { fatalError("No Store") }
        return store
    }

    public var metaData: [String: Any] {
        get {
            guard let psc = persistentStoreCoordinator else { fatalError("must have PSC") }
            return psc.metadata(for: store)
        }
        set {
            performChanges {
                guard let psc = self.persistentStoreCoordinator else { fatalError("PSC missing") }
                psc.setMetadata(newValue, for: self.store)
            }
        }
    }

    public func setMetaData(_ object: AnyObject?, forKey key: String) {
        var md = metaData
        md[key] = object
        metaData = md
    }

    public func insertObject<A: ManagedObject>() -> A where A: ManagedObjectType {
        guard let obj = NSEntityDescription.insertNewObject(forEntityName: A.entityName, into: self) as? A else { fatalError("Wrong object type") }
        return obj
    }

    public func entityForName(_ name: String) -> NSEntityDescription {
        guard let psc = persistentStoreCoordinator else { fatalError("PSC missing") }
        guard let entity = psc.managedObjectModel.entitiesByName[name] else { fatalError("Entity \(name) not found") }
        return entity
    }

    public func createBackgroundContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentStoreCoordinator
        return context
    }


    @discardableResult public func saveOrRollback() -> Bool {
        do {
            try save()
            return true
        } catch {
            rollback()
            return false
        }
    }

    public func performSaveOrRollback() {
        perform {
            self.saveOrRollback()
        }
    }

    public func performChanges(_ block: @escaping () -> ()) {
        perform {
            block()
            self.saveOrRollback()
        }
    }

    func materializedObjectPassingTest(_ test: (NSManagedObject) -> Bool) -> NSManagedObject? {
        for object in registeredObjects where !object.isFault && test(object) {
            return object
        }
        return nil
    }

}


private let SingleObjectCacheKey = "SingleObjectCache"
private typealias SingleObjectCache = [String:NSManagedObject]

extension NSManagedObjectContext {
    public func setObject(_ object: NSManagedObject?, forSingleObjectCacheKey key: String) {
        var cache = userInfo[SingleObjectCacheKey] as? SingleObjectCache ?? [:]
        cache[key] = object
        userInfo[SingleObjectCacheKey] = cache
    }

    public func objectForSingleObjectCacheKey(_ key: String) -> NSManagedObject? {
        guard let cache = userInfo[SingleObjectCacheKey] as? [String:NSManagedObject] else { return nil }
        return cache[key]
    }
}

