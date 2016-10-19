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
    
    func createTextAttributes(_ fontSize: CGFloat) -> [String : Any] {
        let textAttributes : [String : Any] = [
            NSFontAttributeName : Themes.Current.PrimaryFont.withSize(fontSize),
            NSForegroundColorAttributeName : Themes.Current.PrimaryFontColor,
        ]
        return textAttributes
    }
    
    func drawText(_ text: NSString, textAttributes: [String : Any]?, withinRect: CGRect, alignCenter: Bool) {
        let metrics = text.size(attributes: textAttributes)
        
        if alignCenter {
            let text_width = metrics.width
            let text_height = metrics.height
            let rect_width = withinRect.width
            
            let corner_x = (rect_width / 2.0) - (text_width / 2.0)
            let corner_y = withinRect.origin.y
            
            let adjusted_rect = CGRect(x: CGFloat(corner_x), y: CGFloat(corner_y), width: CGFloat(text_width), height: CGFloat(text_height))
            text.draw(in:adjusted_rect, withAttributes: textAttributes)
        } else {
            text.draw(in:withinRect, withAttributes: textAttributes)
        }
    }
    
    
    func drawCompassCheck(_ ctx: CGContext!, x: CGFloat, y: CGFloat, compassDegrees: Double, altitude: CGFloat, diameter: CGFloat, color: UIColor) {
        
        let radius = Double(diameter / 2.0)
        
        let compassRadians = CompassUtil.ToRadians(compassDegrees)
        
        let top_x = Double(x) + (radius * sin(compassRadians))
        let top_y = Double(y) + (radius * cos(compassRadians))
        
        let bottom_x = Double(x) + ((radius - Double(altitude)) * sin(compassRadians))
        let bottom_y = Double(y) + ((radius - Double(altitude)) * cos(compassRadians))
        
        ctx.saveGState()
        ctx.setLineWidth(1)
        ctx.setStrokeColor(color.cgColor)
        let path = CGMutablePath()
        
        path.move(to: CGPoint(x: top_x, y:  top_y))
        
        path.addLine(to: CGPoint(x: bottom_x, y: bottom_y))
        
        path.closeSubpath()
        ctx.addPath(path)
        ctx.strokePath()
    }
    
    
    func drawCompassLabel(_ ctx: CGContext!, x: CGFloat, y: CGFloat, label: NSString, textAttributes: [String: Any], compassDegrees: Double, diameter: CGFloat) {
        ctx.saveGState()
        
        let compassRadians = CompassUtil.DegreesToCompassRadians(compassDegrees)
        
        let radius = Double(diameter / 2.0)
        
        let textSize = label.size(attributes: textAttributes)
        
        let tw2 = Double(textSize.width / 2.0)
        
        let adjusted_compass_degrees = CompassUtil.AddDegrees(compassDegrees, addition: 180.0)
        
        let adjusted_compass_radians = CompassUtil.ToRadians(adjusted_compass_degrees)
        
        let tx =  Double(x) + (radius * sin(adjusted_compass_radians)) - tw2
        let ty =  Double(y) + (radius * cos(adjusted_compass_radians))
        
        let ct_x = Double(x) + (radius * sin(adjusted_compass_radians))
        let ct_y = Double(y) + (radius * cos(adjusted_compass_radians))
        
        var xform = CGAffineTransform(translationX: CGFloat(ct_x), y: CGFloat(ct_y))
        xform = xform.rotated(by: CGFloat(compassRadians))
        xform = xform.translatedBy(x: CGFloat(-1*ct_x), y: CGFloat(-1*ct_y))
        ctx.concatenate(xform)
        
        let textRect = CGRect(x: CGFloat(tx), y: CGFloat(ty), width: CGFloat(textSize.width), height: CGFloat(textSize.height))
        label.draw(in: textRect, withAttributes: textAttributes)
        
        ctx.restoreGState()
    }
    
    func drawCompassTriangle(_ ctx: CGContext!, x: CGFloat, y: CGFloat, compassDegrees: Double, altitude: CGFloat, width: CGFloat, fillColor: UIColor) {
        ctx.saveGState()
        
        ctx.setFillColor(fillColor.cgColor);
        
        let path = CGMutablePath()
        
        path.move(to: CGPoint(x: x, y: y))
        
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
        
        path.addLine(to: CGPoint(x: ll_x, y: ll_y))
        path.addLine(to: CGPoint(x: t_x, y: t_y))
        path.addLine(to: CGPoint(x: lr_x, y: lr_y))
        path.addLine(to: CGPoint(x: x, y: y))
        

        path.closeSubpath()
        ctx.addPath(path)
        (ctx).fillPath()
    }

}
