//
//  DownloadButton.swift
//  SampleCodeStalker
//
//  Created by Thomas Krajacic on 31.1.2016.
//  Copyright © 2016 Thomas Krajacic. All rights reserved.
//

import Cocoa

class DownloadButton: NSButton {
    
    // Colors
    fileprivate struct Colors {
        static let Tint     = NSColor(calibratedRed:0.863, green:0.862, blue:0.814, alpha: 1.0).cgColor
        static let DarkTint = NSColor(calibratedRed:0.7, green:0.7, blue:0.699, alpha: 1.0).cgColor
        static let Active   = NSColor(calibratedRed: 0.43, green: 0.76, blue: 0.93, alpha: 1.0).cgColor
    }
    
    let kAnimationDuration          = 0.1
    let kEnabledOpacity: CFloat     = 1
    let kDisabledOpacity: CFloat    = 0.5
    
    // these are set via mouse events from inside
    fileprivate var isActive        = false { didSet { self.refreshLayer() } }
    fileprivate var isMousedOver    = false { didSet { self.refreshLayer() } }
    fileprivate var isSelected      = false { didSet { self.refreshLayer() } }
    
    fileprivate var rootLayer       = CALayer()
    fileprivate var shapeLayer: CAShapeLayer! {
        // FIXME: This is hardcoded for now but the path should be recalculated on layer resizes
        // Because it is hardcoded it needs to be set after bounds are valid so CAShapeLayer can't be instantiated here.
        didSet {
            let bezierPath = NSBezierPath()
            bezierPath.move(to: NSPoint(x: bounds.minX + 0.60105 * bounds.width, y: bounds.minY + 0.19737 * bounds.height))
            bezierPath.line(to: NSPoint(x: bounds.minX + 0.39892 * bounds.width, y: bounds.minY + 0.19737 * bounds.height))
            bezierPath.line(to: NSPoint(x: bounds.minX + 0.39892 * bounds.width, y: bounds.minY + 0.45842 * bounds.height))
            bezierPath.line(to: NSPoint(x: bounds.minX + 0.13158 * bounds.width, y: bounds.minY + 0.45842 * bounds.height))
            bezierPath.line(to: NSPoint(x: bounds.minX + 0.50000 * bounds.width, y: bounds.minY + 0.84211 * bounds.height))
            bezierPath.line(to: NSPoint(x: bounds.minX + 0.86842 * bounds.width, y: bounds.minY + 0.45842 * bounds.height))
            bezierPath.line(to: NSPoint(x: bounds.minX + 0.60105 * bounds.width, y: bounds.minY + 0.45842 * bounds.height))
            bezierPath.line(to: NSPoint(x: bounds.minX + 0.60105 * bounds.width, y: bounds.minY + 0.19737 * bounds.height))
            bezierPath.close()
            bezierPath.move(to: NSPoint(x: bounds.minX + 0.97368 * bounds.width, y: bounds.minY + 0.50000 * bounds.height))
            bezierPath.curve(to: NSPoint(x: bounds.minX + 0.50000 * bounds.width, y: bounds.minY + 0.97368 * bounds.height),
                controlPoint1: NSPoint(x: bounds.minX + 0.97368 * bounds.width, y: bounds.minY + 0.76161 * bounds.height),
                controlPoint2: NSPoint(x: bounds.minX + 0.76161 * bounds.width, y: bounds.minY + 0.97368 * bounds.height))
            bezierPath.curve(to: NSPoint(x: bounds.minX + 0.02632 * bounds.width, y: bounds.minY + 0.50000 * bounds.height),
                controlPoint1: NSPoint(x: bounds.minX + 0.23839 * bounds.width, y: bounds.minY + 0.97368 * bounds.height),
                controlPoint2: NSPoint(x: bounds.minX + 0.02632 * bounds.width, y: bounds.minY + 0.76161 * bounds.height))
            bezierPath.curve(to: NSPoint(x: bounds.minX + 0.21382 * bounds.width, y: bounds.minY + 0.12250 * bounds.height),
                controlPoint1: NSPoint(x: bounds.minX + 0.02632 * bounds.width, y: bounds.minY + 0.34591 * bounds.height),
                controlPoint2: NSPoint(x: bounds.minX + 0.09989 * bounds.width, y: bounds.minY + 0.20901 * bounds.height))
            bezierPath.curve(to: NSPoint(x: bounds.minX + 0.50000 * bounds.width, y: bounds.minY + 0.02632 * bounds.height),
                controlPoint1: NSPoint(x: bounds.minX + 0.29333 * bounds.width, y: bounds.minY + 0.06214 * bounds.height),
                controlPoint2: NSPoint(x: bounds.minX + 0.39248 * bounds.width, y: bounds.minY + 0.02632 * bounds.height))
            bezierPath.curve(to: NSPoint(x: bounds.minX + 0.97368 * bounds.width, y: bounds.minY + 0.50000 * bounds.height),
                controlPoint1: NSPoint(x: bounds.minX + 0.76161 * bounds.width, y: bounds.minY + 0.02632 * bounds.height),
                controlPoint2: NSPoint(x: bounds.minX + 0.97368 * bounds.width, y: bounds.minY + 0.23839 * bounds.height))
            bezierPath.close()
            shapeLayer.path = bezierPath.cgPath()
        }
    }
    
    fileprivate var trackingTag: NSTrackingRectTag?
    
    override var frame: NSRect {
        get { return super.frame }
        set {
            super.frame = newValue
            self.refreshLayerSize()
        }
    }
    
    override var isEnabled: Bool {
        get { return super.isEnabled }
        set{
            super.isEnabled = newValue
            self.refreshLayer()
        }
    }
    
    // MARK: - Initializers
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonSetup()
    }
    
    deinit {
        if trackingTag != nil { self.removeTrackingRect(trackingTag!) }
    }
    
    // MARK: -  Setup
    fileprivate func commonSetup() {
        self.setupLayers()
        title = ""
    }
    
    fileprivate func setupLayers() {
        // This is a layer-hosting view
        layer = rootLayer
        wantsLayer = true
        
        // symbol
        shapeLayer = CAShapeLayer()
        rootLayer.addSublayer(shapeLayer)
        
        refreshLayerSize()
        refreshLayer()
    }
    
    fileprivate func frameForSymbol(_ size: CGSize) -> CGRect {
        let origin = CGPoint(x: (frame.width - size.width)/2, y: (frame.height - size.height)/2)
        return CGRect(origin: origin, size: size)
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        refreshLayerSize()
    }
    
    fileprivate func refreshLayerSize() {
        shapeLayer.frame = frameForSymbol(bounds.size)
        
        if trackingTag != nil { self.removeTrackingRect(trackingTag!) }
        let trackingFrame = shapeLayer.frame
        trackingTag = self.addTrackingRect(trackingFrame, owner: self, userData: nil, assumeInside: false)
    }
    
    fileprivate func refreshLayer () {
        CATransaction.begin()
        CATransaction.setAnimationDuration(kAnimationDuration)
        
        switch (isMousedOver, isActive) {
            case (true, true): shapeLayer.fillColor = Colors.Active
            case (true, false): shapeLayer.fillColor = Colors.Tint
            default: shapeLayer.fillColor = Colors.DarkTint
        }
        
        rootLayer.opacity = isEnabled ? kEnabledOpacity: kDisabledOpacity
        
        CATransaction.commit()
    }
    
    // MARK: - NSView
    override func acceptsFirstMouse(for theEvent: NSEvent?) -> Bool {
        return true
    }
    
    // MARK: - NSResponder
    override var acceptsFirstResponder: Bool {
        get { return false }
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        if isEnabled {
            isActive = true
        }
    }
    
    override func mouseUp(with theEvent: NSEvent)  {
        if isEnabled {
            isActive = false
            
            cell?.performClick(self)
        }
    }
    
    override func mouseEntered(with theEvent: NSEvent) {
        if isEnabled {
            isMousedOver = true
        }
    }
    
    override func mouseExited(with theEvent: NSEvent) {
        if isEnabled {
            isMousedOver = false
        }
    }
}

// MARK: - extension NSBezierPath
extension NSBezierPath {

    func cgPath() -> CGPath {
        
        let path = CGMutablePath()
        let points =  UnsafeMutablePointer<NSPoint>.allocate(capacity: 3)//NSPointArray(allocatingCapacity: 3)
        
        for index in 0..<self.elementCount {
            let pathType = self.element(at: index, associatedPoints: points)
            switch pathType {
                case .moveToBezierPathElement: path.move(to: points[0])
                case .lineToBezierPathElement: path.addLine(to: points[0])
                case .curveToBezierPathElement: path.addCurve(to: points[2], control1: points[0], control2: points[1])
                case .closePathBezierPathElement: path.closeSubpath()
            }
        }

        points.deallocate(capacity: 3)
        return path
    }
}
