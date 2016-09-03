//
//  DocumentCellFactory.swift
//  SampleCodeStalker
//
//  Created by Thomas Krajacic on 23.1.2016.
//  Copyright © 2016 Thomas Krajacic. All rights reserved.
//

import Cocoa


protocol TableViewCellFactoryType {
    associatedtype Item: ReuseIdentifierCreatable
    associatedtype Cell: NSView
    func cellForItem(_ item: Item, forColumn column: NSTableColumn, inTableView tableView: NSTableView) -> Cell
}

class TableViewCellFactory<Cell: NSTableCellView, Item: ReuseIdentifierCreatable>: TableViewCellFactoryType where Item: ManagedObject {
    fileprivate let cellConfigurator: (Cell, Item) -> ()
    
    /// You must register Cell.Type with your collection view for `reuseIdentifier`.
    init(cellConfigurator: @escaping (Cell, Item) -> ()) {
        self.cellConfigurator = cellConfigurator
    }
    
    func cellForItem(_ item: Item, forColumn column: NSTableColumn, inTableView tableView: NSTableView) -> Cell {
        let cell = tableView.make(withIdentifier: item.cellReuseIdentifier, owner: self) as! Cell
        cellConfigurator(cell, item)
        return cell
    }
    
}

protocol ReuseIdentifierCreatable {
    var cellReuseIdentifier: String { get }
}
