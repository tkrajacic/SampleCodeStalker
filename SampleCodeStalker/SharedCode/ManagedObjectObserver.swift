//
//  ManagedObjectChangeObserver.swift
//  Moody
//
//  Created by Daniel Eggert on 15/05/2015.
//  Copyright (c) 2015 objc.io. All rights reserved.
//

import Foundation
import CoreData


public final class ManagedObjectObserver {
    public enum ChangeType {
        case delete
        case update
    }

    public init?(object: ManagedObjectType, changeHandler: ChangeType -> ()) {
        guard let moc = object.managedObjectContext else { return nil }
        objectHasBeenDeleted = !object.dynamicType.defaultPredicate.evaluateWithObject(object)
        token = moc.addObjectsDidChangeNotificationObserver { [unowned self] note in
            guard let changeType = self.changeTypeOfObject(object, inNotification: note) else { return }
            self.objectHasBeenDeleted = changeType == .delete
            changeHandler(changeType)
        }
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(token)
    }


    // MARK: Private

    private var token: NSObjectProtocol!
    private var objectHasBeenDeleted: Bool = false

    private func changeTypeOfObject(object: ManagedObjectType, inNotification note: ObjectsDidChangeNotification) -> ChangeType? {
        let deleted = note.deletedObjects.union(note.invalidatedObjects)
        if note.invalidatedAllObjects || deleted.containsObjectIdenticalTo(object) {
            return .delete
        }
        let updated = note.updatedObjects.union(note.refreshedObjects)
        if updated.containsObjectIdenticalTo(object) {
            let predicate = object.dynamicType.defaultPredicate
            if predicate.evaluateWithObject(object) {
                return .update
            } else if !objectHasBeenDeleted {
                return .delete
            }
        }
        return nil
    }
}
