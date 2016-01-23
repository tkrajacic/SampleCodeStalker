//
//  CoreDataStack.swift
//  SampleCodeStalker
//
//  Created by Thomas Krajacic on 23.1.2016.
//  Copyright © 2016 Thomas Krajacic. All rights reserved.
//

import Foundation
import CoreData

private let StoreURL = NSURL.documentsURL
    .URLByAppendingPathComponent("SampleCodeStalker", isDirectory: true)
    .URLByAppendingPathComponent("SampleCodeStalker.sqlite")


private func createStoreDirectoryIfNeeded() {
    let directoryURL = NSURL.documentsURL.URLByAppendingPathComponent("SampleCodeStalker", isDirectory: true)
    let manager = NSFileManager.defaultManager()
    try! manager.createDirectoryAtURL(directoryURL, withIntermediateDirectories: true, attributes: nil)
}

public func createMainContext(progress: NSProgress? = nil,
    migrationCompletion: NSManagedObjectContext -> () = { _ in })
    -> NSManagedObjectContext?
{
    createStoreDirectoryIfNeeded()
    let version = CoreDataModelVersion(storeURL: StoreURL)
    guard version == nil || version == CoreDataModelVersion.CurrentVersion else {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            let context = NSManagedObjectContext(
                concurrencyType: .MainQueueConcurrencyType,
                                 modelVersion: CoreDataModelVersion.CurrentVersion, storeURL: StoreURL,
                                               progress: progress)
            dispatch_async(dispatch_get_main_queue()) {
                migrationCompletion(context)
            }
        }
        return nil
    }
    
    let context = NSManagedObjectContext(
        concurrencyType: .MainQueueConcurrencyType,
                         modelVersion: CoreDataModelVersion.CurrentVersion, storeURL: StoreURL)
    
    context.mergePolicy = NSMergePolicy(mergeType: .MergeByPropertyStoreTrumpMergePolicyType)
    return context
}

enum CoreDataModelVersion: String {
    case Version1 = "SampleCodeModel"
}

extension CoreDataModelVersion: ModelVersionType {
static var AllVersions: [CoreDataModelVersion] { return [.Version1] }
static var CurrentVersion: CoreDataModelVersion { return .Version1 }
    
    var name: String { return rawValue }
    var modelBundle: NSBundle { return NSBundle(forClass: CDDocument.self) }
    var modelDirectoryName: String { return "SampleCodeModel.momd" }
}