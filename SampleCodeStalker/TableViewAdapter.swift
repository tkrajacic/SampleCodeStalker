//
//  TableViewAdapter.swift
//  SampleCodeStalker
//
//  Created by Thomas Krajacic on 23.1.2016.
//  Copyright © 2016 Thomas Krajacic. All rights reserved.
//

import Cocoa


final class TableViewAdapter<Factory: TableViewCellFactoryType> where Factory.Item: ManagedObject, Factory.Item: ManagedObjectType, Factory.Item: StringFilterable {
    typealias Item = Factory.Item
    
    let tableView: NSTableView!
    var cellFactory: Factory
    let dataSource: DataSource<TableViewAdapter<Factory>>
    
    var bridgedDataSource: NSTableViewDataSource { return bridgedTableViewDataSource }
    var bridgedDelegate: NSTableViewDelegate { return bridgedTableViewDataSource }
    
    fileprivate lazy var bridgedTableViewDataSource: BridgableTableViewAdapter = BridgableTableViewAdapter(
        cellForItemAtColumnRowHandler: { self.viewForTableColumn($1, row: $2) } ,
                                       numberOfRowsHandler: { self.numberOfRowsInTableView($0) }
    )
    
    init(dataManager: DataSource<TableViewAdapter<Factory>>, cellFactory: Factory, tableView: NSTableView) {
        self.tableView = tableView
        self.dataSource = dataManager
        self.cellFactory = cellFactory
    }
    
    // MARK: - NSTableViewDataSource
    
    fileprivate func numberOfRowsInTableView(_ tableView: NSTableView) -> Int {
        return dataSource.items.count
    }
    
    // MARK: For NSTableViewDelegate
    
    fileprivate func viewForTableColumn(_ tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let tableColumn = tableColumn else {
            fatalError("No table column")
        }
        let item = dataSource.items[row]
        return cellFactory.cellForItem(item, forColumn: tableColumn, inTableView: tableView)
    }
}

// MARK: - DataManagerDelegate
extension TableViewAdapter: DataSourceDelegate {
    
    func dataSourceDidChangeContent() {
        //
        mainThread { 
            self.tableView.reloadData()
        }
    }
    
    func dataSourceWillChangeContent() {
        //
    }
}


// Bridged

@objc private final class BridgableTableViewAdapter: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    
    fileprivate let cellForItemAtColumnRowHandler: (NSTableView, NSTableColumn?, Int) -> NSView?
    fileprivate let numberOfRowsHandler: (NSTableView) -> Int
    
    init(cellForItemAtColumnRowHandler: @escaping (NSTableView, NSTableColumn?, Int) -> NSView?, numberOfRowsHandler: @escaping (NSTableView) -> Int) {
        self.cellForItemAtColumnRowHandler = cellForItemAtColumnRowHandler
        self.numberOfRowsHandler = numberOfRowsHandler
    }
    
    // MARK: - NSTableViewDataSource
    
    @objc func numberOfRows(in tableView: NSTableView) -> Int {
        return numberOfRowsHandler(tableView)
    }
    
    // MARK: For NSTableViewDelegate
    
    // Unfortunately this method is in the Delegate on Mac OS X and not in the DataSource as on iOS
    // That's why this class implements `NSTableViewDelegate` as well so it can be passed transparently for this method.
    @objc func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        return cellForItemAtColumnRowHandler(tableView, tableColumn, row)
    }
    
}
