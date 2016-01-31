//
//  Document.swift
//  SampleCodeStalker
//
//  Created by Thomas Krajacic on 23.1.2016.
//  Copyright © 2016 Thomas Krajacic. All rights reserved.
//

import Foundation

struct Document {
    let id: String
    let name: String
    let url: NSURL
    let date: NSDate
    let displayDate: NSDate
    let sortOrder: Int16
    let releaseVersion: Int16
}

extension Document {
    init(coreDataDocument: CDDocument) {
        self.id = coreDataDocument.id
        self.name = coreDataDocument.name
        self.url = coreDataDocument.url
        self.date = coreDataDocument.date
        self.displayDate = coreDataDocument.displayDate
        self.sortOrder = coreDataDocument.sortOrder
        self.releaseVersion = coreDataDocument.releaseVersion
    }
}