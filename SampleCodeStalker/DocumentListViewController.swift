//
//  ViewController.swift
//  SampleCodeStalker
//
//  Created by Thomas Krajacic on 23.1.2016.
//  Copyright © 2016 Thomas Krajacic. All rights reserved.
//

import Cocoa

class DocumentListViewController: NSViewController {
    
    fileprivate typealias DocumentsCellFactory = TableViewCellFactory<DocumentTableCellView, CDDocument>
    
    fileprivate let dataSource = DataSource<TableViewAdapter<DocumentsCellFactory>>()
    fileprivate var tableViewAdapter: TableViewAdapter<DocumentsCellFactory>!
    fileprivate var cellFactory: DocumentsCellFactory!
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var documentCountTextField: NSTextField!
    @IBOutlet weak var activityIndicator: NSProgressIndicator!
    @IBOutlet weak var activityLabel: NSTextField! {
        didSet { setActivityTitle("") }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        
        cellFactory = DocumentsCellFactory() { (cell, document) -> () in
//            cell.delegate = self.tableViewAdapter
            cell.document = document
        }
        
        tableViewAdapter = TableViewAdapter(dataManager: dataSource, cellFactory: cellFactory, tableView: tableView)
        
        tableView.dataSource = tableViewAdapter.bridgedDataSource
        tableView.delegate = self
        
        dataSource.delegate = tableViewAdapter
        dataSource.itemCountHandler = { count, unfilteredCount in
            self.documentCountTextField.updateWithCount(count, unfilteredCount: unfilteredCount)
        }
        dataSource.reloadDocuments()
        
        activityIndicator.startAnimation(self)
        
        self.setActivityTitle("Fetching Documents")
        DocumentFetcher(endpoint: .index).fetch { json in
            self.setActivityTitle("Parsing Documents")
            DocumentParser(managedObjectContext: self.dataSource.moc).parse(json) {
                
                self.setActivityTitle("")
                self.activityIndicator.stopAnimation(self)
            }
        }
    }
    
    fileprivate func setActivityTitle(_ text: String?) {
        DispatchQueue.main.async {
            if let text = text , text != "" {
                self.activityLabel.stringValue = text
                self.activityLabel.isHidden = false
            } else {
                self.activityLabel.stringValue = ""
                self.activityLabel.isHidden = true
            }
        }
    }
}

// MARK: - NSTableViewDelegate
extension DocumentListViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let tableColumn = tableColumn , row < dataSource.items.count else { return nil }
        return tableViewAdapter.bridgedDelegate.tableView?(tableView, viewFor: tableColumn, row: row)
    }
}

// MARK: - NSSearchFieldDelegate
extension DocumentListViewController: NSSearchFieldDelegate {
    
    override func controlTextDidChange(_ obj: Notification) {
        guard let textField = obj.object as? NSTextField else { return }
        dataSource.filterWithString(textField.stringValue.lowercased())
    }
}

private extension NSTextField {
    
    func updateWithCount(_ count: Int, unfilteredCount: Int) {
        guard unfilteredCount >= count else { return }
        self.stringValue = count == unfilteredCount ? "\(count) documents": "\(count) of \(unfilteredCount) documents"
    }
}

extension CDDocument: ReuseIdentifierCreatable {
    var cellReuseIdentifier: String { return "DocumentCell" }
}
