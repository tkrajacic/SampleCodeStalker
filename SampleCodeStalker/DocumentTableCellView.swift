//
//  DocumentTableCellView.swift
//  SampleCodeStalker
//
//  Created by Thomas Krajacic on 23.1.2016.
//  Copyright © 2016 Thomas Krajacic. All rights reserved.
//

import Cocoa

class DocumentTableCellView: NSTableCellView {
    
    static let dateFormatter : NSDateFormatter = {
        let df = NSDateFormatter()
        df.dateStyle = .MediumStyle
        df.timeStyle = .NoStyle
        return df
    }()

    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var dateTextField: NSTextField!
    @IBOutlet weak var topicTextField: NSTextField!
    @IBOutlet weak var frameworkTextField: NSTextField!
    @IBOutlet weak var updateSizeTextField: NSTextField!
    
    var document : CDDocument? {
        didSet {
        guard let document = document else { return }
            nameTextField.stringValue = document.name
            dateTextField.stringValue = DocumentTableCellView.dateFormatter.stringFromDate(document.date)
            topicTextField.stringValue = "\(document.topic?.name ?? "")" + (document.subTopic.flatMap({" / \($0.name)"}) ?? "")
            frameworkTextField.stringValue = document.framework?.name ?? ""
            updateSizeTextField.stringValue = "\(document.updateSize.rawValue)"
        }
        
        
    }
    
}
