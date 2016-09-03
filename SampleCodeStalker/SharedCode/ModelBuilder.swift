import CoreData


extension NSManagedObjectModel {
    
    public convenience init(builder: () -> [NSEntityDescription]) {
        self.init()
        entities = builder()
    }
    
}


extension NSManagedObjectContext {
    
    public convenience init(model: NSManagedObjectModel, databaseName: String = "myStore.db", deleteExistingStore: Bool = true) {
        self.init(concurrencyType: .mainQueueConcurrencyType)
        let storeURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent(databaseName)
        let psc = NSPersistentStoreCoordinator(managedObjectModel: model)
        if deleteExistingStore {
            psc.destroySQLiteStore(at: storeURL)
        }
        try! psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: [:])
        persistentStoreCoordinator = psc
    }
    
}


extension NSPersistentStoreCoordinator {
    
    func destroySQLiteStore(at storeURL: URL) {
        if #available(OSX 10.11, iOS 9.0, *) {
            try! destroyPersistentStore(at: storeURL, ofType: NSSQLiteStoreType, options: [:])
        } else {
            // Fallback on earlier versions
            fatalError()
        }
    }
    
}


extension NSEntityDescription {
    
    public convenience init<A: NSManagedObject>(cls: A.Type, name: String) {
        self.init()
        let a = NSStringFromClass(cls) as String
        self.managedObjectClassName = a
        self.name = name
    }
    
    public func addProperty(_ property: NSPropertyDescription) {
        var p = properties
        p.append(property)
        properties = p
    }
    
    public func createOneToOneRelationTo(_ to: NSEntityDescription, toName: String, fromName: String) {
        let relation = NSRelationshipDescription.toOne(toName, destinationEntity: to, deleteRule: .nullifyDeleteRule)
        let inverse = NSRelationshipDescription.toOne(fromName, destinationEntity: self, deleteRule: .nullifyDeleteRule)
        relation.inverseRelationship = inverse
        inverse.inverseRelationship = relation
        self.addProperty(relation)
        to.addProperty(inverse)
    }
    
    public func createOneToManyRelationTo(_ to: NSEntityDescription, toName: String, fromName: String) {
        let relation = NSRelationshipDescription.toMany(toName, minCount: 0, maxCount: Int.max, destinationEntity: to, deleteRule: .nullifyDeleteRule)
        let inverse = NSRelationshipDescription.toOne(fromName, destinationEntity: self, deleteRule: .nullifyDeleteRule)
        relation.inverseRelationship = inverse
        inverse.inverseRelationship = relation
        self.addProperty(relation)
        to.addProperty(inverse)
    }
    
    public func createOneToOrderedManyRelationTo(_ to: NSEntityDescription, toName: String, fromName: String) {
        let relation = NSRelationshipDescription.toMany(toName, minCount: 0, maxCount: Int.max, destinationEntity: to, deleteRule: .nullifyDeleteRule, ordered: true)
        let inverse = NSRelationshipDescription.toOne(fromName, destinationEntity: self, deleteRule: .nullifyDeleteRule)
        relation.inverseRelationship = inverse
        inverse.inverseRelationship = relation
        self.addProperty(relation)
        to.addProperty(inverse)
    }
    
    public func createManyToManyRelationTo(_ to: NSEntityDescription, toName: String, fromName: String) {
        let relation = NSRelationshipDescription.toMany(toName, minCount: 0, maxCount: Int.max, destinationEntity: to, deleteRule: .nullifyDeleteRule)
        let inverse = NSRelationshipDescription.toMany(fromName, minCount: 0, maxCount: Int.max, destinationEntity: self, deleteRule: .nullifyDeleteRule)
        relation.inverseRelationship = inverse
        inverse.inverseRelationship = relation
        self.addProperty(relation)
        to.addProperty(inverse)
    }
    
    public func createManyToOrderedManyRelationTo(_ to: NSEntityDescription, toName: String, fromName: String) {
        let relation = NSRelationshipDescription.toMany(toName, minCount: 0, maxCount: Int.max, destinationEntity: to, deleteRule: .nullifyDeleteRule, ordered: true)
        let inverse = NSRelationshipDescription.toMany(fromName, minCount: 0, maxCount: Int.max, destinationEntity: self, deleteRule: .nullifyDeleteRule)
        relation.inverseRelationship = inverse
        inverse.inverseRelationship = relation
        self.addProperty(relation)
        to.addProperty(inverse)
    }
    
}


public struct DataTransform<A> {
    public let name: String
    public let forward: (A) -> NSData?
    public let reverse: (NSData?) -> A
    public init(name: String, forward: @escaping (A) -> NSData?, reverse: @escaping (NSData?) -> A) {
        self.name = name
        self.forward = forward
        self.reverse = reverse
    }
}

extension NSRelationshipDescription {
    
    public static func toOne(_ name: String, destinationEntity: NSEntityDescription?, deleteRule: NSDeleteRule?, indexed: Bool? = nil, optional: Bool? = nil) -> NSRelationshipDescription {
        let relation = NSRelationshipDescription()
        relation.name = name
        relation.setIndexed(indexed, optional: optional, deleteRule: deleteRule)
        relation.destinationEntity = destinationEntity
        relation.minCount = 1
        relation.maxCount = 1
        return relation
    }
    
    public static func toMany(_ name: String, minCount: Int, maxCount: Int, destinationEntity: NSEntityDescription?, deleteRule: NSDeleteRule?, indexed: Bool? = nil, optional: Bool? = nil, ordered: Bool = false) -> NSRelationshipDescription {
        let relation = NSRelationshipDescription()
        relation.name = name
        relation.setIndexed(indexed, optional: optional, deleteRule: deleteRule)
        relation.destinationEntity = destinationEntity
        relation.minCount = minCount
        relation.maxCount = maxCount
        relation.isOrdered = ordered
        return relation
    }
    
    public static func orderedToMany(_ name: String, minCount: Int, maxCount: Int, destinationEntity: NSEntityDescription?, deleteRule: NSDeleteRule?, indexed: Bool? = nil, optional: Bool? = nil) -> NSRelationshipDescription {
        let relation = toMany(name, minCount: minCount, maxCount: maxCount, destinationEntity: destinationEntity, deleteRule: deleteRule, indexed: indexed, optional: optional)
        relation.isOrdered = true
        return relation
    }
    
    private func setIndexed(_ indexed: Bool?, optional: Bool?, deleteRule: NSDeleteRule? = nil) {
        if let dr = deleteRule {
            self.deleteRule = dr
        }
        setIndexed(indexed, optional: optional)
    }
    
}


extension NSAttributeDescription {
    public static func int16Type(_ name: String, defaultValue: Int16? = nil, indexed: Bool? = nil, optional: Bool? = nil) -> NSAttributeDescription {
        let attr = NSAttributeDescription.descriptionWithName(name, type: .integer16AttributeType)
        attr.setIndexed(indexed, optional: optional, defaultValue: defaultValue.map {NSNumber(value: Int($0))})
        return attr
    }
    
    public static func int32Type(_ name: String, defaultValue: Int32? = nil, indexed: Bool? = nil, optional: Bool? = nil) -> NSAttributeDescription {
        let attr = NSAttributeDescription.descriptionWithName(name, type: .integer32AttributeType)
        attr.setIndexed(indexed, optional: optional, defaultValue: defaultValue.map {NSNumber(value: Int($0))})
        return attr
    }
    
    public static func int64Type(_ name: String, defaultValue: Int64? = nil, indexed: Bool? = nil, optional: Bool? = nil) -> NSAttributeDescription {
        let attr = NSAttributeDescription.descriptionWithName(name, type: .integer64AttributeType)
        attr.setIndexed(indexed, optional: optional, defaultValue: defaultValue.map {NSNumber(value: Int64($0))})
        return attr
    }
    
    public static func doubleType(_ name: String, defaultValue: Double? = nil, indexed: Bool? = nil, optional: Bool? = nil) -> NSAttributeDescription {
        let attr = NSAttributeDescription.descriptionWithName(name, type: .doubleAttributeType)
        attr.setIndexed(indexed, optional: optional, defaultValue: defaultValue.map {NSNumber(value: $0)})
        return attr
    }
    
    public static func stringType(_ name: String, defaultValue: String? = nil, indexed: Bool? = nil, optional: Bool? = nil) -> NSAttributeDescription {
        let attr = NSAttributeDescription.descriptionWithName(name, type: .stringAttributeType)
        attr.setIndexed(indexed, optional: optional, defaultValue: defaultValue as AnyObject?)
        return attr
    }
    
    public static func boolType(_ name: String, defaultValue: Bool? = nil, indexed: Bool? = nil, optional: Bool? = nil) -> NSAttributeDescription {
        let attr = NSAttributeDescription.descriptionWithName(name, type: .booleanAttributeType)
        attr.setIndexed(indexed, optional: optional, defaultValue: defaultValue.map {NSNumber(value: $0)})
        return attr
    }
    
    public static func dateType(_ name: String, defaultValue: Date? = nil, indexed: Bool? = nil, optional: Bool? = nil) -> NSAttributeDescription {
        let attr = NSAttributeDescription.descriptionWithName(name, type: .dateAttributeType)
        attr.setIndexed(indexed, optional: optional, defaultValue: defaultValue as AnyObject?)
        return attr
    }
    
    public static func binaryDataType(_ name: String, defaultValue: Data? = nil, indexed: Bool? = nil, optional: Bool? = nil, allowsExternalBinaryDataStorage: Bool?) -> NSAttributeDescription {
        let attr = NSAttributeDescription.descriptionWithName(name, type: .binaryDataAttributeType)
        attr.setIndexed(indexed, optional: optional, defaultValue: defaultValue as AnyObject?)
        if let e = allowsExternalBinaryDataStorage {
            attr.allowsExternalBinaryDataStorage = e
        }
        return attr
    }
    
    /// transformerName needs to be unique
    public static func transformableType<A: NSObject>(_ name: String, transform: DataTransform<A>, indexed: Bool? = nil, optional: Bool? = nil) -> NSAttributeDescription {
        let attr = NSAttributeDescription.descriptionWithName(name, type: .transformableAttributeType)
        attr.setIndexed(indexed, optional: optional, defaultValue: nil)
        
        let t = { (a: A?) -> NSData? in
            a.flatMap { transform.forward($0) }
        }
        let r = { Optional<A>.some(transform.reverse($0)) }
        
        ValueTransformer.registerTransformerWith(name: transform.name, transform: t, reverseTransform: r)
        attr.valueTransformerName = transform.name
        
        return attr
    }
    
    private static func descriptionWithName(_ name: String, type: NSAttributeType) -> NSAttributeDescription {
        let attr = NSAttributeDescription()
        attr.name = name
        attr.attributeType = type
        return attr
    }
    
    private func setIndexed(_ indexed: Bool?, optional: Bool?, defaultValue: AnyObject? = nil) {
        if let d: AnyObject = defaultValue {
            self.defaultValue = d
        }
        setIndexed(indexed, optional: optional)
    }
}


extension NSPropertyDescription {
    
    private func setIndexed(_ indexed: Bool?, optional: Bool?) {
        if let o = optional {
            self.isOptional = o
        }
        if let i = indexed {
            self.isIndexed = i
        }
    }
    
}
