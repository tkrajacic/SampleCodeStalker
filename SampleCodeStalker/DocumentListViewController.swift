//
//  ViewController.swift
//  SampleCodeStalker
//
//  Created by Thomas Krajacic on 23.1.2016.
//  Copyright © 2016 Thomas Krajacic. All rights reserved.
//

import Cocoa

class DocumentListViewController: NSViewController {

    let moc = createMainContext()!
    let fetcher = DocumentFetcher(url: NSURL(string: "https://developer.apple.com/library/mac/navigation/library.json")!)
    
    // To retain the filter string when reloading the data
    var filterString : String = ""
    
    var documents : [CDDocument] = [] {
        didSet { filteredDocuments = filterdDocumentsUsingString(filterString) }
    }
    
    var filteredDocuments : [CDDocument] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    @IBOutlet weak var tableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadDocuments()
    }
    
    private func reloadDocuments() {
        documents = CDDocument.fetchInContext(moc).sort({ $0.date > $1.date })
    }
    
    private func filterdDocumentsUsingString(string: String) -> [CDDocument] {
        if string == "" {
            return documents
        } else {
            return documents.filter {
                $0.name.lowercaseString.containsString(filterString)
            }
        }
    }

}

extension DocumentListViewController : NSSearchFieldDelegate {
    
    override func controlTextDidChange(obj: NSNotification) {
        guard let textField = obj.object as? NSTextField else { return }
        
        filterString = textField.stringValue.lowercaseString
        filteredDocuments = filterdDocumentsUsingString(filterString)
    }
}

extension DocumentListViewController : NSTableViewDataSource {
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return filteredDocuments.count
    }
}

extension DocumentListViewController : NSTableViewDelegate {
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let tableColumn = tableColumn else { return nil }
        guard filteredDocuments.indices.contains(row) else { return nil }
                
        let cell = tableView.makeViewWithIdentifier(tableColumn.identifier, owner: self) as! DocumentTableCellView
        
        cell.document = filteredDocuments[row]
        
        return cell
    }
}