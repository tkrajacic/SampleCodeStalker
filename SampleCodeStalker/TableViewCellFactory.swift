//
//  DocumentCellFactory.swift
//  SampleCodeStalker
//
//  Created by Thomas Krajacic on 23.1.2016.
//  Copyright © 2016 Thomas Krajacic. All rights reserved.
//

import Cocoa


protocol TableViewCellFactoryType {
    associatedtype Item : ReuseIdentifierCreatable
    associatedtype Cell : NSView
    func cellForItem(item: Item, forColumn column: NSTableColumn, inTableView tableView: NSTableView) -> Cell
}

class TableViewCellFactory<Cell: NSTableCellView, Item: ReuseIdentifierCreatable where Item: ManagedObject> : TableViewCellFactoryType {
    private let cellConfigurator: (Cell, Item) -> ()
    
    /// You must register Cell.Type with your collection view for `reuseIdentifier`.
    init(cellConfigurator: (Cell, Item) -> ()) {
        self.cellConfigurator = cellConfigurator
    }
    
    func cellForItem(item: Item, forColumn column: NSTableColumn, inTableView tableView: NSTableView) -> Cell {
        let cell = tableView.makeViewWithIdentifier(item.cellReuseIdentifier, owner: self) as! Cell
        cellConfigurator(cell, item)
        return cell
    }
    
}

protocol ReuseIdentifierCreatable {
    var cellReuseIdentifier : String { get }
}
