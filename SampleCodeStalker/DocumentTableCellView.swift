//
//  DocumentTableCellView.swift
//  SampleCodeStalker
//
//  Created by Thomas Krajacic on 23.1.2016.
//  Copyright © 2016 Thomas Krajacic. All rights reserved.
//

import Cocoa

class DocumentTableCellView: NSTableCellView {
    
    static let TopicColor = NSColor(calibratedHue: 0.4, saturation: 0.6, brightness: 0.8, alpha: 0.5).CGColor
    static let FrameworkColor = NSColor(calibratedHue: 0.5, saturation: 0.8, brightness: 0.8, alpha: 0.5).CGColor
    
    static let dateFormatter: NSDateFormatter = {
        let df = NSDateFormatter()
        df.dateStyle = .MediumStyle
        df.timeStyle = .NoStyle
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
            mainThread { 
                self.configureWithDocument(document)
            }
            
        }
    }
    
    private func configureWithDocument(document: CDDocument) {
        nameTextField.stringValue = document.name
        dateTextField.stringValue = DocumentTableCellView.dateFormatter.stringFromDate(document.date)
        
        if let topicName = document.topic?.name where topicName != "" {
            tagStackView.setVisibilityPriority(NSStackViewVisibilityPriorityMustHold, forView: topicTextField)
            topicTextField.stringValue = topicName
        } else {
            tagStackView.setVisibilityPriority(NSStackViewVisibilityPriorityNotVisible, forView: topicTextField)
            topicTextField.stringValue = ""
        }
        
        if let subTopicName = document.subTopic?.name where subTopicName != "" {
            tagStackView.setVisibilityPriority(NSStackViewVisibilityPriorityMustHold, forView: subTopicTextField)
            subTopicTextField.stringValue = subTopicName
        } else {
            tagStackView.setVisibilityPriority(NSStackViewVisibilityPriorityNotVisible, forView: subTopicTextField)
            subTopicTextField.stringValue = ""
        }
        
        if let frameworkName = document.framework?.name where frameworkName != "" {
            tagStackView.setVisibilityPriority(NSStackViewVisibilityPriorityMustHold, forView: frameworkTextField)
            frameworkTextField.stringValue = frameworkName
        } else {
            tagStackView.setVisibilityPriority(NSStackViewVisibilityPriorityNotVisible, forView: frameworkTextField)
            frameworkTextField.stringValue = ""
        }
        
        updateSizeTextField.stringValue = document.updateSize.stringRepresentation
        
        downloadButton.toolTip = document.url.absoluteString
    }
    
    @IBAction func downloadButtonPressed(sender: DownloadButton) {
        guard let document = document else { return }
        NSWorkspace.sharedWorkspace().openURL(document.url)
    }
}

private extension CDDocument.UpdateSize {
    var stringRepresentation: String {
        switch self {
        case .FirstVersion: return "First Version"
        case .ContentUpdate: return "Content Update"
        case .MinorChange: return "Minor Change"
        case .Unknown: return "unknown"
        }
    }
}
