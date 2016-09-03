//
//  KeyCodable.swift
//  Moody
//
//  Created by Florian on 17/11/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import CoreData


public protocol KeyCodable {
    associatedtype Keys: RawRepresentable
}

extension KeyCodable where Self: ManagedObject, Keys.RawValue == String {
    public func willAccessValueForKey(_ key: Keys) {
        willAccessValue(forKey: key.rawValue)
    }

    public func didAccessValueForKey(_ key: Keys) {
        didAccessValue(forKey: key.rawValue)
    }

    public func willChangeValueForKey(_ key: Keys) {
        (self as ManagedObject).willChangeValue(forKey: key.rawValue)
    }

    public func didChangeValueForKey(_ key: Keys) {
        (self as ManagedObject).didChangeValue(forKey: key.rawValue)
    }

    public func valueForKey(_ key: Keys) -> Any? {
        return (self as ManagedObject).value(forKey: key.rawValue)
    }

    public func mutableSetValueForKey(_ key: Keys) -> NSMutableSet {
        return mutableSetValue(forKey: key.rawValue)
    }

    public func changedValueForKey(_ key: Keys) -> Any? {
        return changedValues()[key.rawValue]
    }

    public func committedValueForKey(_ key: Keys) -> Any? {
        return committedValues(forKeys: [key.rawValue])[key.rawValue]
    }
}

