//
//  MainWindow.swift
//  SampleCodeStalker
//
//  Created by Thomas Krajacic on 23.1.2016.
//  Copyright © 2016 Thomas Krajacic. All rights reserved.
//

import Cocoa

class MainWindow: NSWindow {

    override init(contentRect: NSRect, styleMask aStyle: Int, backing bufferingType: NSBackingStoreType, `defer` flag: Bool) {
        super.init(contentRect: contentRect, styleMask: aStyle, backing: bufferingType, defer: flag)
        
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.commonInit()
    }
    
    func commonInit() {
        self.titlebarAppearsTransparent = true
        self.titleVisibility = .Hidden
        self.movable = true
        self.movableByWindowBackground = true
        self.opaque = false
        self.backgroundColor = NSColor.whiteColor()
    }
    
    override var canBecomeKeyWindow : Bool {
        return true
    }
    
    override var canBecomeMainWindow : Bool {
        return true
    }
}
