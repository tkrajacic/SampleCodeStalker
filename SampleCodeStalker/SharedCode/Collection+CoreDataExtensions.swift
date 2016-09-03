//
//  Collection+CoreDataExtensions.swift
//  psctest
//
//  Created by Florian on 18/08/15.
//  Copyright © 2015 objc.io. All rights reserved.
//

import CoreData

extension Collection where Iterator.Element: NSManagedObject {
    public func fetchObjectsThatAreFaults() {
        guard !self.isEmpty else { return }
        guard let context = self.first?.managedObjectContext else { fatalError("Managed object must have context") }
        let faults = self.filter { $0.isFault }
        guard let mo = faults.first else { return }
        let request = NSFetchRequest<Iterator.Element>()
        request.entity = mo.entity
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "self in %@", faults)
        _ = try! context.fetch(request)
    }
}
