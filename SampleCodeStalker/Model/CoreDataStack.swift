//
//  CoreDataStack.swift
//  SampleCodeStalker
//
//  Created by Thomas Krajacic on 23.1.2016.
//  Copyright © 2016 Thomas Krajacic. All rights reserved.
//

import Foundation
import CoreData

private let StoreURL = URL.documentsURL
    .appendingPathComponent("SampleCodeStalker", isDirectory: true)
    .appendingPathComponent("SampleCodeStalker.sqlite")


private func createStoreDirectoryIfNeeded() {
    let directoryURL = URL.documentsURL.appendingPathComponent("SampleCodeStalker", isDirectory: true)
    let manager = FileManager.default
    try! manager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
}

public func createMainContext(_ progress: Progress? = nil,
    migrationCompletion: @escaping (NSManagedObjectContext) -> () = { _ in })
    -> NSManagedObjectContext?
{
    createStoreDirectoryIfNeeded()
    let version = CoreDataModelVersion(storeURL: StoreURL)
    guard version == nil || version == CoreDataModelVersion.CurrentVersion else {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
            let context = NSManagedObjectContext(
                concurrencyType: .mainQueueConcurrencyType,
                                 modelVersion: CoreDataModelVersion.CurrentVersion, storeURL: StoreURL,
                                               progress: progress)
            DispatchQueue.main.async {
                migrationCompletion(context)
            }
        }
        return nil
    }
    
    let context = NSManagedObjectContext(
        concurrencyType: .mainQueueConcurrencyType,
                         modelVersion: CoreDataModelVersion.CurrentVersion, storeURL: StoreURL)
    
    context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyStoreTrumpMergePolicyType)
    return context
}

enum CoreDataModelVersion: String {
    case version1 = "SampleCodeModel"
}

extension CoreDataModelVersion: ModelVersionType {
static var AllVersions: [CoreDataModelVersion] { return [.version1] }
static var CurrentVersion: CoreDataModelVersion { return .version1 }
    
    var name: String { return rawValue }
    var modelBundle: Bundle { return Bundle(for: CDDocument.self) }
    var modelDirectoryName: String { return "SampleCodeModel.momd" }
}
