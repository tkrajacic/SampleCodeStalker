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
    private struct Colors {
        static let Tint     = NSColor(calibratedRed:0.863, green:0.862, blue:0.814, alpha: 1.0).CGColor
        static let DarkTint = NSColor(calibratedRed:0.7, green:0.7, blue:0.699, alpha: 1.0).CGColor
        static let Active   = NSColor(calibratedRed: 0.43, green: 0.76, blue: 0.93, alpha: 1.0).CGColor
    }
    
    let kAnimationDuration          = 0.1
    let kEnabledOpacity: CFloat     = 1
    let kDisabledOpacity: CFloat    = 0.5
    
    // these are set via mouse events from inside
    private var isActive        = false { didSet { self.refreshLayer() } }
    private var isMousedOver    = false { didSet { self.refreshLayer() } }
    private var isSelected      = false { didSet { self.refreshLayer() } }
    
    private var rootLayer       = CALayer()
    private var shapeLayer: CAShapeLayer! {
        // FIXME: This is hardcoded for now but the path should be recalculated on layer resizes
        // Because it is hardcoded it needs to be set after bounds are valid so CAShapeLayer can't be instantiated here.
        didSet {
            let bezierPath = NSBezierPath()
            bezierPath.moveToPoint(NSMakePoint(bounds.minX + 0.60105 * bounds.width, bounds.minY + 0.19737 * bounds.height))
            bezierPath.lineToPoint(NSMakePoint(bounds.minX + 0.39892 * bounds.width, bounds.minY + 0.19737 * bounds.height))
            bezierPath.lineToPoint(NSMakePoint(bounds.minX + 0.39892 * bounds.width, bounds.minY + 0.45842 * bounds.height))
            bezierPath.lineToPoint(NSMakePoint(bounds.minX + 0.13158 * bounds.width, bounds.minY + 0.45842 * bounds.height))
            bezierPath.lineToPoint(NSMakePoint(bounds.minX + 0.50000 * bounds.width, bounds.minY + 0.84211 * bounds.height))
            bezierPath.lineToPoint(NSMakePoint(bounds.minX + 0.86842 * bounds.width, bounds.minY + 0.45842 * bounds.height))
            bezierPath.lineToPoint(NSMakePoint(bounds.minX + 0.60105 * bounds.width, bounds.minY + 0.45842 * bounds.height))
            bezierPath.lineToPoint(NSMakePoint(bounds.minX + 0.60105 * bounds.width, bounds.minY + 0.19737 * bounds.height))
            bezierPath.closePath()
            bezierPath.moveToPoint(NSMakePoint(bounds.minX + 0.97368 * bounds.width, bounds.minY + 0.50000 * bounds.height))
            bezierPath.curveToPoint(NSMakePoint(bounds.minX + 0.50000 * bounds.width, bounds.minY + 0.97368 * bounds.height),
                controlPoint1: NSMakePoint(bounds.minX + 0.97368 * bounds.width, bounds.minY + 0.76161 * bounds.height),
                controlPoint2: NSMakePoint(bounds.minX + 0.76161 * bounds.width, bounds.minY + 0.97368 * bounds.height))
            bezierPath.curveToPoint(NSMakePoint(bounds.minX + 0.02632 * bounds.width, bounds.minY + 0.50000 * bounds.height),
                controlPoint1: NSMakePoint(bounds.minX + 0.23839 * bounds.width, bounds.minY + 0.97368 * bounds.height),
                controlPoint2: NSMakePoint(bounds.minX + 0.02632 * bounds.width, bounds.minY + 0.76161 * bounds.height))
            bezierPath.curveToPoint(NSMakePoint(bounds.minX + 0.21382 * bounds.width, bounds.minY + 0.12250 * bounds.height),
                controlPoint1: NSMakePoint(bounds.minX + 0.02632 * bounds.width, bounds.minY + 0.34591 * bounds.height),
                controlPoint2: NSMakePoint(bounds.minX + 0.09989 * bounds.width, bounds.minY + 0.20901 * bounds.height))
            bezierPath.curveToPoint(NSMakePoint(bounds.minX + 0.50000 * bounds.width, bounds.minY + 0.02632 * bounds.height),
                controlPoint1: NSMakePoint(bounds.minX + 0.29333 * bounds.width, bounds.minY + 0.06214 * bounds.height),
                controlPoint2: NSMakePoint(bounds.minX + 0.39248 * bounds.width, bounds.minY + 0.02632 * bounds.height))
            bezierPath.curveToPoint(NSMakePoint(bounds.minX + 0.97368 * bounds.width, bounds.minY + 0.50000 * bounds.height),
                controlPoint1: NSMakePoint(bounds.minX + 0.76161 * bounds.width, bounds.minY + 0.02632 * bounds.height),
                controlPoint2: NSMakePoint(bounds.minX + 0.97368 * bounds.width, bounds.minY + 0.23839 * bounds.height))
            bezierPath.closePath()
            shapeLayer.path = bezierPath.cgPath()
        }
    }
    
    private var trackingTag: NSTrackingRectTag?
    
    override var frame: NSRect {
        get { return super.frame }
        set {
            super.frame = newValue
            self.refreshLayerSize()
        }
    }
    
    override var enabled: Bool {
        get { return super.enabled }
        set{
            super.enabled = newValue
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
    private func commonSetup() {
        self.setupLayers()
        title = ""
    }
    
    private func setupLayers() {
        // This is a layer-hosting view
        layer = rootLayer
        wantsLayer = true
        
        // symbol
        shapeLayer = CAShapeLayer()
        rootLayer.addSublayer(shapeLayer)
        
        refreshLayerSize()
        refreshLayer()
    }
    
    private func frameForSymbol(size: CGSize) -> CGRect {
        let origin = CGPoint(x: (frame.width - size.width)/2, y: (frame.height - size.height)/2)
        return CGRect(origin: origin, size: size)
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        refreshLayerSize()
    }
    
    private func refreshLayerSize() {
        shapeLayer.frame = frameForSymbol(bounds.size)
        
        if trackingTag != nil { self.removeTrackingRect(trackingTag!) }
        let trackingFrame = shapeLayer.frame
        trackingTag = self.addTrackingRect(trackingFrame, owner: self, userData: nil, assumeInside: false)
    }
    
    private func refreshLayer () {
        CATransaction.begin()
        CATransaction.setAnimationDuration(kAnimationDuration)
        
        switch (isMousedOver, isActive) {
            case (true, true): shapeLayer.fillColor = Colors.Active
            case (true, false): shapeLayer.fillColor = Colors.Tint
            default : shapeLayer.fillColor = Colors.DarkTint
        }
        
        rootLayer.opacity = enabled ? kEnabledOpacity : kDisabledOpacity
        
        CATransaction.commit()
    }
    
    // MARK: - NSView
    override func acceptsFirstMouse(theEvent: NSEvent?) -> Bool {
        return true
    }
    
    // MARK: - NSResponder
    override var acceptsFirstResponder: Bool {
        get { return false }
    }
    
    override func mouseDown(theEvent: NSEvent) {
        if enabled {
            isActive = true
        }
    }
    
    override func mouseUp(theEvent: NSEvent)  {
        if enabled {
            isActive = false
            
            cell?.performClick(self)
        }
    }
    
    override func mouseEntered(theEvent: NSEvent) {
        if enabled {
            isMousedOver = true
        }
    }
    
    override func mouseExited(theEvent: NSEvent) {
        if enabled {
            isMousedOver = false
        }
    }
}

// MARK: - extension NSBezierPath
extension NSBezierPath {

    func cgPath() -> CGPath {
        
        let path = CGPathCreateMutable()
        let points = NSPointArray.alloc(3)
        
        for index in 0..<self.elementCount {
            let pathType = self.elementAtIndex(index, associatedPoints: points)
            switch pathType {
                case .MoveToBezierPathElement: CGPathMoveToPoint(path, nil, points[0].x, points[0].y)
                case .LineToBezierPathElement: CGPathAddLineToPoint(path, nil, points[0].x, points[0].y)
                case .CurveToBezierPathElement: CGPathAddCurveToPoint(path, nil, points[0].x, points[0].y, points[1].x, points[1].y, points[2].x, points[2].y)
                case .ClosePathBezierPathElement: CGPathCloseSubpath(path)
            }
        }

        points.dealloc(3)
        return path
    }
}