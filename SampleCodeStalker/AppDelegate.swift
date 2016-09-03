//
//  AppDelegate.swift
//  SampleCodeStalker
//
//  Created by Thomas Krajacic on 23.1.2016.
//  Copyright © 2016 Thomas Krajacic. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

func mainThread(_ block: @escaping ()->Void) {
    DispatchQueue.main.async(execute: block)
}

//extension NSDate: Comparable {}
//public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
//    if lhs.compare(rhs) == .OrderedSame {
//        return true
//    }
//    return false
//}
//
//public func <(lhs: NSDate, rhs: NSDate) -> Bool {
//    if lhs.compare(rhs) == .OrderedAscending {
//        return true
//    }
//    return false
//}
