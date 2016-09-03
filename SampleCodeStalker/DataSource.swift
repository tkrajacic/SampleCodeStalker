//
//  DocumentDataSource.swift
//  SampleCodeStalker
//
//  Created by Thomas Krajacic on 23.1.2016.
//  Copyright © 2016 Thomas Krajacic. All rights reserved.
//

import Cocoa

protocol DataSourceDelegate {
    associatedtype Item
    func dataSourceWillChangeContent()
    func dataSourceDidChangeContent()
}

protocol DataSourceType {
    associatedtype DelegateType: DataSourceDelegate
    var delegate: DelegateType? { get set }
    var items: [DelegateType.Item] { get }
}


final class DataSource<Delegate: DataSourceDelegate>: DataSourceType where Delegate.Item: ManagedObject, Delegate.Item: ManagedObjectType, Delegate.Item: StringFilterable {
    
    fileprivate var contextSavedToken: NSObjectProtocol!
    var moc = createMainContext()!
    var itemCountHandler: ((_ count: Int, _ unfilteredCount: Int)->Void)?
    
    init() {
        contextSavedToken = moc.addContextDidSaveNotificationObserver { [weak self] note in
            self?.reloadDocuments()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(contextSavedToken)
    }
        
    // To keep the filter string when reloading the data
    var filterString: String = ""

    var delegate: Delegate?
    var items: [Delegate.Item] = [] {
        didSet {
            delegate?.dataSourceDidChangeContent()
        itemCountHandler?(items.count, unfilteredItems.count)
        }
    }
    
    var unfilteredItems: [Delegate.Item] = [] {
        didSet {
            filterWithString(filterString)
        }
    }

    func reloadDocuments() {
        unfilteredItems = Delegate.Item.fetchInContext(moc) { $0.sortDescriptors = Delegate.Item.defaultSortDescriptors }
    }
    
    func filterWithString(_ string: String) {
        filterString = string
        if string == "" {
            items = unfilteredItems
        } else {
            items = unfilteredItems.filter {
                $0.filterString.lowercased().contains(filterString)
            }
        }
    }
}


protocol StringFilterable {
    var filterString: String { get }
}

extension CDDocument: StringFilterable {
    var filterString: String { return name }
}
