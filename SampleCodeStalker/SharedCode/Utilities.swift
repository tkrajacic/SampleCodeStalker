//
//  Utilities.swift
//  Moody
//
//  Created by Florian on 08/05/15.
//  Copyright (c) 2015 objc.io. All rights reserved.
//

import Foundation


extension Sequence {
    
    func findFirstOccurence( _ block: (Iterator.Element) -> Bool) -> Iterator.Element? {
        for x in self where block(x) {
            return x
        }
        return nil
    }
    
    func some( _ block: (Iterator.Element) -> Bool) -> Bool {
        return findFirstOccurence(block) != nil
    }
    
    func all( _ block: (Iterator.Element) -> Bool) -> Bool {
        return findFirstOccurence { !block($0) } == nil
    }
    
    /// Similar to
    /// ```
    /// func forEach(@noescape body: (Self.Generator.Element) -> ())
    /// ```
    /// but calls the completion block once all blocks have called their completion block. If some of the calls to the block do not call their completion blocks that will result in data leaking.
    func asyncForEachWithCompletion(_ completion: @escaping () -> (), block: (Iterator.Element, () -> ()) -> ()) {
        let group = DispatchGroup()
        let innerCompletion = { group.leave() }
        for x in self {
            group.enter()
            block(x, innerCompletion)
        }
        group.notify(queue: DispatchQueue.main, execute: completion)
    }
    
    func filterByType<T>() -> [T] {
        return filter { $0 is T }.map { $0 as! T }
    }
    
}


extension Sequence where Iterator.Element: AnyObject {
    
    public func containsObjectIdenticalTo(_ object: AnyObject) -> Bool {
        return contains { $0 === object }
    }
    
}


extension Array {
    
    func decompose() -> (Iterator.Element, [Iterator.Element])? {
        guard let x = first else { return nil }
        return (x, Array(self[1..<count]))
    }
    
    func slices(_ size: Int) -> [[Iterator.Element]] {
        var result: [[Iterator.Element]] = []
        for idx in stride(from: startIndex, to: endIndex, by: size) {
            let end = Swift.min(idx + size, endIndex)
            result.append(Array(self[idx..<end]))
        }
        return result
    }
    
}


extension URL {
    
    static func temporaryURL() -> URL {
        return try! FileManager.default.url(for: FileManager.SearchPathDirectory.cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(UUID().uuidString)
    }
    
    static var documentsURL: URL {
        return try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    }
    
}

