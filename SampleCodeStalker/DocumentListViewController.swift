//
//  ViewController.swift
//  SampleCodeStalker
//
//  Created by Thomas Krajacic on 23.1.2016.
//  Copyright © 2016 Thomas Krajacic. All rights reserved.
//

import Cocoa

class DocumentListViewController: NSViewController {
    
    private typealias DocumentsCellFactory = TableViewCellFactory<DocumentTableCellView, CDDocument>
    
    private let dataSource = DataSource<TableViewAdapter<DocumentsCellFactory>>()
    private var tableViewAdapter : TableViewAdapter<DocumentsCellFactory>!
    private var cellFactory : DocumentsCellFactory!

    let fetcher = DocumentFetcher(endpoint: .Index(.Mac))
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var documentCountTextField: NSTextField!
    @IBOutlet weak var activityIndicator: NSProgressIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        
        cellFactory = DocumentsCellFactory() { (cell, document) -> () in
//            cell.delegate = self.tableViewAdapter
            cell.document = document
        }
        
        tableViewAdapter = TableViewAdapter(dataManager: dataSource, cellFactory: cellFactory, tableView: tableView)
        
        tableView.setDataSource(tableViewAdapter.bridgedDataSource)
        tableView.setDelegate(self)
        
        dataSource.delegate = tableViewAdapter
        dataSource.itemCountHandler = { count, unfilteredCount in
            self.documentCountTextField.updateWithCount(count, unfilteredCount: unfilteredCount)
        }
        dataSource.reloadDocuments()
        
        activityIndicator.startAnimation(self)
        fetcher.fetch { json in
            DocumentParser(managedObjectContext: self.dataSource.moc).parse(json) {
                self.activityIndicator.stopAnimation(self)
            }
        }
    }
}

// MARK: - NSTableViewDelegate
extension DocumentListViewController : NSTableViewDelegate {
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let tableColumn = tableColumn where row < dataSource.items.count else { return nil }
        return tableViewAdapter.bridgedDelegate.tableView?(tableView, viewForTableColumn: tableColumn, row: row)
    }
}

// MARK: - NSSearchFieldDelegate
extension DocumentListViewController : NSSearchFieldDelegate {
    
    override func controlTextDidChange(obj: NSNotification) {
        guard let textField = obj.object as? NSTextField else { return }
        dataSource.filterWithString(textField.stringValue.lowercaseString)
    }
}

private extension NSTextField {
    
    func updateWithCount(count: Int, unfilteredCount: Int) {
        guard unfilteredCount >= count else { return }
        self.stringValue = count == unfilteredCount ? "\(count) documents" : "\(count) of \(unfilteredCount) documents"
    }
}

extension CDDocument : ReuseIdentifierCreatable {
    var cellReuseIdentifier : String { return "DocumentCell" }
}