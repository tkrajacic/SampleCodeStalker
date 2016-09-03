//
//  MainWindow.swift
//  SampleCodeStalker
//
//  Created by Thomas Krajacic on 23.1.2016.
//  Copyright © 2016 Thomas Krajacic. All rights reserved.
//

import Cocoa

class MainWindow: NSWindow {

    override init(contentRect: NSRect, styleMask aStyle: NSWindowStyleMask, backing bufferingType: NSBackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: aStyle, backing: bufferingType, defer: flag)
        
        self.commonInit()
    }
    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        
//        self.commonInit()
//    }
    
    func commonInit() {
        self.titlebarAppearsTransparent = true
        self.titleVisibility = .hidden
        self.isMovable = true
        self.isMovableByWindowBackground = true
        self.isOpaque = false
        self.backgroundColor = NSColor.white
    }
    
    override var canBecomeKey: Bool {
        return true
    }
    
    override var canBecomeMain: Bool {
        return true
    }
}
