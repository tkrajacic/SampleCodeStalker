//
//  DocumentDataSource.swift
//  SampleCodeStalker
//
//  Created by Thomas Krajacic on 23.1.2016.
//  Copyright © 2016 Thomas Krajacic. All rights reserved.
//

import Cocoa

protocol DataSourceDelegate {
    typealias Item
    func dataSourceWillChangeContent()
    func dataSourceDidChangeContent()
}

protocol DataSourceType {
    typealias DelegateType: DataSourceDelegate
    var delegate: DelegateType? { get set }
    var items: [DelegateType.Item] { get }
}


final class DataSource<Delegate: DataSourceDelegate where Delegate.Item: ManagedObject, Delegate.Item: ManagedObjectType, Delegate.Item: StringFilterable> : DataSourceType {
    
    private var contextSavedToken : NSObjectProtocol!
    
    var moc = createMainContext()! {
        didSet {
            contextSavedToken = moc.addContextDidSaveNotificationObserver { [weak self] note in
                self?.delegate?.dataSourceDidChangeContent()
            }
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(contextSavedToken)
    }
        
    // To keep the filter string when reloading the data
    var filterString: String = ""

    var delegate: Delegate?
    var items: [Delegate.Item] = [] {
        didSet {
            delegate?.dataSourceDidChangeContent()
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
    
    func filterWithString(string: String) {
        filterString = string
        if string == "" {
            items = unfilteredItems
        } else {
            items = unfilteredItems.filter {
                $0.filterString.lowercaseString.containsString(filterString)
            }
        }
        
    }

}


protocol StringFilterable {
    var filterString : String { get }
}

extension CDDocument : StringFilterable {
    var filterString : String { return name }
}