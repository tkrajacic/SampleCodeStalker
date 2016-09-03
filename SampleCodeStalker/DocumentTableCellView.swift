//
//  DocumentTableCellView.swift
//  SampleCodeStalker
//
//  Created by Thomas Krajacic on 23.1.2016.
//  Copyright © 2016 Thomas Krajacic. All rights reserved.
//

import Cocoa

class DocumentTableCellView: NSTableCellView {
    
    static let TopicColor = NSColor(calibratedHue: 0.4, saturation: 0.6, brightness: 0.8, alpha: 0.5).cgColor
    static let FrameworkColor = NSColor(calibratedHue: 0.5, saturation: 0.8, brightness: 0.8, alpha: 0.5).cgColor
    
    static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        return df
    }()

    @IBOutlet weak var downloadButton: NSButton!
    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var dateTextField: NSTextField!
    @IBOutlet weak var tagStackView: NSStackView!
    @IBOutlet weak var topicTextField: NSTextField! {
        didSet {
            topicTextField.wantsLayer = true
            topicTextField.layer?.backgroundColor = DocumentTableCellView.TopicColor
            topicTextField.layer?.cornerRadius = 4
        }
    }
    @IBOutlet weak var subTopicTextField: NSTextField! {
        didSet {
            subTopicTextField.wantsLayer = true
            subTopicTextField.layer?.backgroundColor = DocumentTableCellView.TopicColor
            subTopicTextField.layer?.cornerRadius = 4
        }
    }
    @IBOutlet weak var frameworkTextField: NSTextField! {
        didSet {
            frameworkTextField.wantsLayer = true
            frameworkTextField.layer?.backgroundColor = DocumentTableCellView.FrameworkColor
            frameworkTextField.layer?.cornerRadius = 4
        }
    }
    @IBOutlet weak var updateSizeTextField: NSTextField!
    
    var document: CDDocument? {
        didSet {
            guard let document = document else { return }
            DispatchQueue.main.async { 
                self.configureWithDocument(document)
            }
            
        }
    }
    
    fileprivate func configureWithDocument(_ document: CDDocument) {
        nameTextField.stringValue = document.name
        dateTextField.stringValue = DocumentTableCellView.dateFormatter.string(from: document.date as Date)
        
        if let topicName = document.topic?.name , topicName != "" {
            tagStackView.setVisibilityPriority(NSStackViewVisibilityPriorityMustHold, for: topicTextField)
            topicTextField.stringValue = topicName
        } else {
            tagStackView.setVisibilityPriority(NSStackViewVisibilityPriorityNotVisible, for: topicTextField)
            topicTextField.stringValue = ""
        }
        
        if let subTopicName = document.subTopic?.name , subTopicName != "" {
            tagStackView.setVisibilityPriority(NSStackViewVisibilityPriorityMustHold, for: subTopicTextField)
            subTopicTextField.stringValue = subTopicName
        } else {
            tagStackView.setVisibilityPriority(NSStackViewVisibilityPriorityNotVisible, for: subTopicTextField)
            subTopicTextField.stringValue = ""
        }
        
        if let frameworkName = document.framework?.name , frameworkName != "" {
            tagStackView.setVisibilityPriority(NSStackViewVisibilityPriorityMustHold, for: frameworkTextField)
            frameworkTextField.stringValue = frameworkName
        } else {
            tagStackView.setVisibilityPriority(NSStackViewVisibilityPriorityNotVisible, for: frameworkTextField)
            frameworkTextField.stringValue = ""
        }
        
        updateSizeTextField.stringValue = document.updateSize.stringRepresentation
        
        downloadButton.toolTip = document.url.absoluteString
    }
    
    @IBAction func downloadButtonPressed(_ sender: DownloadButton) {
        guard let document = document else { return }
        NSWorkspace.shared().open(document.url as URL)
    }
}

private extension CDDocument.UpdateSize {
    var stringRepresentation: String {
        switch self {
        case .firstVersion: return "First Version"
        case .contentUpdate: return "Content Update"
        case .minorChange: return "Minor Change"
        case .unknown: return "unknown"
        }
    }
}
