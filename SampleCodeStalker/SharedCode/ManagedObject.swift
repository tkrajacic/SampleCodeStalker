//
//  ManagedObject.swift
//  Moody
//
//  Created by Florian on 29/05/15.
//  Copyright (c) 2015 objc.io. All rights reserved.
//

import CoreData


public class ManagedObject: NSManagedObject {
}


public protocol ManagedObjectType: class {
    static var entityName: String { get }
    static var defaultSortDescriptors: [NSSortDescriptor] { get }
    static var defaultPredicate: NSPredicate { get }
    var managedObjectContext: NSManagedObjectContext? { get }
}


public protocol DefaultManagedObjectType: ManagedObjectType {}

extension DefaultManagedObjectType {
    public static var defaultPredicate: NSPredicate { return NSPredicate(value: true) }
}


extension ManagedObjectType {
    
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return []
    }
    
    public static var entityName: String {
        return String(describing: Self.self)
    }
    
    public static var sortedFetchRequest: NSFetchRequest<NSFetchRequestResult> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.sortDescriptors = defaultSortDescriptors
        request.predicate = defaultPredicate
        return request
    }
    
    public static func sortedFetchRequestWithPredicate(_ predicate: NSPredicate) -> NSFetchRequest<NSFetchRequestResult> {
        let request = sortedFetchRequest
        guard let existingPredicate = request.predicate else { fatalError("must have predicate") }
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [existingPredicate, predicate])
        return request
    }
    
    public static func sortedFetchRequestWithPredicateFormat(_ format: String, args: CVarArg...) -> NSFetchRequest<NSFetchRequestResult> {
        let predicate = withVaList(args) { NSPredicate(format: format, arguments: $0) }
        return sortedFetchRequestWithPredicate(predicate)
    }
    
    public static func predicateWithFormat(_ format: String, args: CVarArg...) -> NSPredicate {
        let predicate = withVaList(args) { NSPredicate(format: format, arguments: $0) }
        return predicateWithPredicate(predicate)
    }
    
    public static func predicateWithPredicate(_ predicate: NSPredicate) -> NSPredicate {
        return NSCompoundPredicate(andPredicateWithSubpredicates: [defaultPredicate, predicate])
    }
    
}


extension ManagedObjectType where Self: ManagedObject {
    
    public static func findOrCreateInContext(_ moc: NSManagedObjectContext, matchingPredicate predicate: NSPredicate, configure: (Self) -> ()) -> Self {
        guard let obj = findOrFetchInContext(moc, matchingPredicate: predicate) else {
            let newObject: Self = moc.insertObject()
            configure(newObject)
            return newObject
        }
        return obj
    }
    
    
    public static func findOrFetchInContext(_ moc: NSManagedObjectContext, matchingPredicate predicate: NSPredicate) -> Self? {
        guard let obj = materializedObjectInContext(moc, matchingPredicate: predicate) else {
            return fetchInContext(moc) { request in
                request.predicate = predicate
                request.returnsObjectsAsFaults = false
                request.fetchLimit = 1
                }.first
        }
        return obj
    }
    
    public static func fetchInContext(_ context: NSManagedObjectContext, configurationBlock: (NSFetchRequest<NSFetchRequestResult>) -> () = { _ in }) -> [Self] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Self.entityName)
        configurationBlock(request)
        guard let result = try! context.fetch(request) as? [Self] else { fatalError("Fetched objects have wrong type") }
        return result
    }
    
    public static func countInContext(_ context: NSManagedObjectContext, configurationBlock: (NSFetchRequest<NSFetchRequestResult>) -> () = { _ in }) -> Int {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        configurationBlock(request)
        let result = try! context.count(for: request)
        guard result != NSNotFound else { fatalError("Failed to execute fetch request") }
        return result
    }
    
    public static func materializedObjectInContext(_ moc: NSManagedObjectContext, matchingPredicate predicate: NSPredicate) -> Self? {
        for obj in moc.registeredObjects where !obj.isFault {
            guard let res = obj as? Self , predicate.evaluate(with: res) else { continue }
            return res
        }
        return nil
    }
    
}


extension ManagedObjectType where Self: ManagedObject {
    public static func fetchSingleObjectInContext(_ moc: NSManagedObjectContext, cacheKey: String, configure: (NSFetchRequest<NSFetchRequestResult>) -> ()) -> Self? {
        guard let cached = moc.objectForSingleObjectCacheKey(cacheKey) as? Self else {
            let result = fetchSingleObjectInContext(moc, configure: configure)
            moc.setObject(result, forSingleObjectCacheKey: cacheKey)
            return result
        }
        return cached
    }
    
    private static func fetchSingleObjectInContext(_ moc: NSManagedObjectContext, configure: (NSFetchRequest<NSFetchRequestResult>) -> ()) -> Self? {
        let result = fetchInContext(moc) { request in
            configure(request)
            request.fetchLimit = 2
        }
        switch result.count {
        case 0: return nil
        case 1: return result[0]
        default: fatalError("Returned multiple objects, expected max 1")
        }
    }
}

