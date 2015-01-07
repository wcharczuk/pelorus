//
//  GraphicsView.swift
//  Pelorus
//
//  Created by Will Charczuk on 1/6/15.
//  Copyright (c) 2015 Will Charczuk. All rights reserved.
//

import UIKit
import CoreGraphics

class GraphicsView : UIView {

    var interfaceOrientation : UIInterfaceOrientation!
    
    func createTextAttributes(fontSize: CGFloat) -> Dictionary<NSObject, AnyObject> {
        let textAttributes : Dictionary<NSObject, AnyObject> = [
            NSFontAttributeName : Themes.Current.PrimaryFont.fontWithSize(fontSize) as AnyObject,
            NSForegroundColorAttributeName : Themes.Current.PrimaryFontColor as AnyObject,
        ]
        return textAttributes
    }
    
    func drawText(text: NSString, textAttributes: Dictionary<NSObject, AnyObject>, withinRect: CGRect, alignCenter: Bool) {
        let metrics = text.sizeWithAttributes(textAttributes)
        
        if alignCenter {
            let text_width = metrics.width
            let text_height = metrics.height
            let rect_width = withinRect.width
            
            let corner_x = (rect_width / 2.0) - (text_width / 2.0)
            let corner_y = withinRect.origin.y
            
            let adjusted_rect = CGRectMake(CGFloat(corner_x), CGFloat(corner_y), CGFloat(text_width), CGFloat(text_height))
            text.drawInRect(adjusted_rect, withAttributes: textAttributes)
        } else {
            text.drawInRect(withinRect, withAttributes: textAttributes)
        }
    }
    
    
    func drawCompassCheck(ctx: CGContext!, x: CGFloat, y: CGFloat, compassDegrees: Double, altitude: CGFloat, diameter: CGFloat, color: UIColor) {
        
        let radius = Double(diameter / 2.0)
        
        let compassRadians = CompassUtil.ToRadians(compassDegrees)
        
        let top_x = Double(x) + (radius * sin(compassRadians))
        let top_y = Double(y) + (radius * cos(compassRadians))
        
        let bottom_x = Double(x) + ((radius - Double(altitude)) * sin(compassRadians))
        let bottom_y = Double(y) + ((radius - Double(altitude)) * cos(compassRadians))
        
        CGContextSaveGState(ctx)
        CGContextSetLineWidth(ctx, 1)
        CGContextSetStrokeColorWithColor(ctx, color.CGColor)
        var path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, CGFloat(top_x), CGFloat(top_y))
        
        CGPathAddLineToPoint(path, nil, CGFloat(bottom_x), CGFloat(bottom_y))
        
        CGPathCloseSubpath(path)
        CGContextAddPath(ctx, path)
        CGContextStrokePath(ctx)
    }
    
    
    func drawCompassLabel(ctx: CGContext!, x: CGFloat, y: CGFloat, label: NSString, textAttributes: Dictionary<NSObject, AnyObject>, compassDegrees: Double, diameter: CGFloat) {
        CGContextSaveGState(ctx)
        
        let compassRadians = CompassUtil.DegreesToCompassRadians(compassDegrees)
        
        let radius = Double(diameter / 2.0)
        
        let textSize = label.sizeWithAttributes(textAttributes)
        
        let tw2 = Double(textSize.width / 2.0)
        let th = Double(textSize.height)
        let th2 = th / 2.0
        
        let adjusted_compass_degrees = CompassUtil.AddDegrees(compassDegrees, addition: 180.0)
        
        let adjusted_compass_radians = CompassUtil.ToRadians(adjusted_compass_degrees)
        
        let tx =  Double(x) + (radius * sin(adjusted_compass_radians)) - tw2
        let ty =  Double(y) + (radius * cos(adjusted_compass_radians))
        
        let ct_x = Double(x) + (radius * sin(adjusted_compass_radians))
        let ct_y = Double(y) + (radius * cos(adjusted_compass_radians))
        
        var xform = CGAffineTransformMakeTranslation(CGFloat(ct_x), CGFloat(ct_y))
        xform = CGAffineTransformRotate(xform, CGFloat(compassRadians))
        xform = CGAffineTransformTranslate(xform, CGFloat(-1*ct_x), CGFloat(-1*ct_y))
        CGContextConcatCTM(ctx, xform)
        
        let textRect = CGRectMake(CGFloat(tx), CGFloat(ty), CGFloat(textSize.width), CGFloat(textSize.height))
        label.drawInRect(textRect, withAttributes: textAttributes)
        
        CGContextRestoreGState(ctx)
    }
    
    func drawCompassTriangle(ctx: CGContext!, x: CGFloat, y: CGFloat, compassDegrees: Double, altitude: CGFloat, width: CGFloat, fillColor: UIColor) {
        CGContextSaveGState(ctx)
        
        CGContextSetFillColorWithColor(ctx, fillColor.CGColor);
        var path = CGPathCreateMutable()
        
        CGPathMoveToPoint(path, nil, x, y)
        
        let compass_radians = CompassUtil.ToRadians(compassDegrees)
        
        let compass_left = CompassUtil.AddDegrees(compassDegrees, addition: 90.0)
        let compass_right = CompassUtil.AddRadians(compassDegrees, addition: -90.0)
        
        let compass_left_radians = CompassUtil.ToRadians(compass_left)
        let compass_right_radians = CompassUtil.ToRadians(compass_right)
        
        let ll_x = Double(x) + (Double(width / 2.0) * sin(compass_left_radians))
        let ll_y = Double(y) + (Double(width / 2.0) * cos(compass_left_radians))
        
        let lr_x = Double(x) + (Double(width / 2.0) * sin(compass_right_radians))
        let lr_y = Double(y) + (Double(width / 2.0) * cos(compass_right_radians))
        
        let t_x = Double(x) + (Double(altitude / 2.0) * sin(compass_radians))
        let t_y = Double(y) + (Double(altitude / 2.0) * cos(compass_radians))
        
        CGPathAddLineToPoint(path, nil, CGFloat(ll_x), CGFloat(ll_y))
        CGPathAddLineToPoint(path, nil, CGFloat(t_x), CGFloat(t_y))
        CGPathAddLineToPoint(path, nil, CGFloat(lr_x), CGFloat(lr_y))
        CGPathAddLineToPoint(path, nil, CGFloat(x), CGFloat(y))
        
        CGPathCloseSubpath(path)
        CGContextAddPath(ctx, path)
        CGContextFillPath(ctx)
    }

}