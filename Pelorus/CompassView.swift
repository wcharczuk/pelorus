//
//  CompassView.swift
//  Pelorus
//
//  Created by Will Charczuk on 1/6/15.
//  Copyright (c) 2015 Will Charczuk. All rights reserved.
//

import UIKit
import CoreGraphics

class CompassView : GraphicsView {
    
    var DistanceMeters: Double!
    var CurrentHeading : Double!
    var CurrentHeadingError : Double!
    var CurrentDestinationHeading: Double!
    
    func viewWillAppear(animated: Bool) {
        self.backgroundColor = Themes.Current.BackgroundColor
    }
    
    func _drawCompass(rect: CGRect, center: CGPoint, largeFontSize: CGFloat, smallFontSize: CGFloat, scale: CGFloat) {
        let ctx = UIGraphicsGetCurrentContext()
        
        let diameter = _calculateDiameter()
        
        let _2_pi = 2 * M_PI
        
        //draw compass and compass rose
        //draw circle
        CGContextSetLineWidth(ctx, 2)
        CGContextSetStrokeColorWithColor(ctx, Themes.Current.BorderColor.CGColor)
        CGContextAddArc(ctx, center.x, center.y, CGFloat(diameter / 2.0), CGFloat(0.0), CGFloat(_2_pi), Int32(1))
        CGContextStrokePath(ctx)
        
        let outer_inner_diameter = 775 * scale
        
        CGContextSetLineWidth(ctx, 1)
        CGContextSetStrokeColorWithColor(ctx, Themes.Current.BorderColor.CGColor)
        CGContextAddArc(ctx, center.x, center.y, CGFloat(outer_inner_diameter / 2.0), CGFloat(0.0), CGFloat(_2_pi), Int32(1))
        CGContextStrokePath(ctx)
        
        let inner_outer_diameter = 675.0 * scale
        
        CGContextSetLineWidth(ctx, 1)
        CGContextSetStrokeColorWithColor(ctx, Themes.Current.BorderColor.CGColor)
        CGContextAddArc(ctx, center.x, center.y, CGFloat(inner_outer_diameter / 2.0), CGFloat(0.0), CGFloat(_2_pi), Int32(1))
        CGContextStrokePath(ctx)
        
        let inner_inner_diameter = 648.0 * scale
        
        CGContextSetLineWidth(ctx, 1)
        CGContextSetStrokeColorWithColor(ctx, Themes.Current.BorderColor.CGColor)
        CGContextAddArc(ctx, center.x, center.y, CGFloat(inner_inner_diameter / 2.0), CGFloat(0.0), CGFloat(_2_pi), Int32(1))
        CGContextStrokePath(ctx)
        
        let rose_diameter = 315 * scale
        
        CGContextSetLineWidth(ctx, 1)
        CGContextSetStrokeColorWithColor(ctx, Themes.Current.BorderColor.CGColor)
        CGContextAddArc(ctx, center.x, center.y, CGFloat(rose_diameter / 2.0), CGFloat(0.0), CGFloat(_2_pi), Int32(1))
        CGContextStrokePath(ctx)
        
        let heading_x = bounds.size.width / 2.0
        let heading_y = (bounds.size.height / 2.0) - ((diameter / 2.0) + 5.0)
        
        //this is the little 'heading' triangle on the top of the compass
        drawCompassTriangle(ctx, x: heading_x, y: heading_y, compassDegrees: 180.0, altitude: 10.0, width: 10.0, fillColor: Themes.Current.PrimaryColor)
        
        let north : NSString = "N"
        let east  : NSString = "E"
        let south : NSString = "S"
        let west  : NSString = "W"
        
        let large_text = createTextAttributes(largeFontSize)
        let small_text = createTextAttributes(smallFontSize)
        
        let major_size = west.sizeWithAttributes(large_text)
        
        let northwest : NSString = "NW"
        let northeast : NSString = "NE"
        let southwest : NSString = "SW"
        let southeast : NSString = "SE"
        
        var north_degrees = 0.0
        
        if nil != self.CurrentHeading {
            //adjust north by current heading
            
            var north_theta = CompassUtil.CalculateBearingDifference(0.0, to: self.CurrentHeading)
            if north_theta < 0.0 {
                north_theta = north_theta + 360
            }
            
            north_degrees = north_theta
        }
        
        var northeast_degrees = CompassUtil.AddDegrees(north_degrees, addition: -45.0)
        var northwest_degrees = CompassUtil.AddDegrees(north_degrees, addition: 45.0)
        var west_degrees = CompassUtil.AddDegrees(north_degrees, addition: 90.0)
        var east_degrees = CompassUtil.AddDegrees(north_degrees, addition: -90.0)
        var south_degrees = CompassUtil.AddDegrees(north_degrees, addition: 180.0)
        var southeast_degrees = CompassUtil.AddDegrees(south_degrees, addition: 45.0)
        var southwest_degrees = CompassUtil.AddDegrees(south_degrees, addition: -45.0)
        
        let minor_rose_triangle_altitude = (110 * scale) * 2.0
        let major_rose_triangle_altitude = rose_diameter
        
        let minor_rose_width = 82 * scale
        let major_rose_width = 108 * scale
        
        //draw compass rose
        drawCompassTriangle(ctx, x: center.x, y: center.y, compassDegrees: northeast_degrees, altitude: minor_rose_triangle_altitude, width: minor_rose_width, fillColor: Themes.Current.BorderColor)
        drawCompassTriangle(ctx, x: center.x, y: center.y, compassDegrees: northwest_degrees, altitude: minor_rose_triangle_altitude, width: minor_rose_width, fillColor: Themes.Current.BorderColor)
        drawCompassTriangle(ctx, x: center.x, y: center.y, compassDegrees: southeast_degrees, altitude: minor_rose_triangle_altitude, width: minor_rose_width, fillColor: Themes.Current.BorderColor)
        drawCompassTriangle(ctx, x: center.x, y: center.y, compassDegrees: southwest_degrees, altitude: minor_rose_triangle_altitude, width: minor_rose_width, fillColor: Themes.Current.BorderColor)
        
        drawCompassTriangle(ctx, x: center.x, y: center.y, compassDegrees: north_degrees, altitude: major_rose_triangle_altitude, width: major_rose_width, fillColor: Themes.Current.PrimaryColor)
        drawCompassTriangle(ctx, x: center.x, y: center.y, compassDegrees: east_degrees, altitude: major_rose_triangle_altitude, width: major_rose_width, fillColor: Themes.Current.PrimaryColor)
        drawCompassTriangle(ctx, x: center.x, y: center.y, compassDegrees: west_degrees, altitude: major_rose_triangle_altitude, width: major_rose_width, fillColor: Themes.Current.PrimaryColor)
        drawCompassTriangle(ctx, x: center.x, y: center.y, compassDegrees: south_degrees, altitude: major_rose_triangle_altitude, width: major_rose_width, fillColor: Themes.Current.PrimaryColor)
        
        //draw direction labels
        
        drawCompassCheck(ctx, x: center.x, y: center.y, compassDegrees: northeast_degrees, altitude: 18.0, diameter: inner_inner_diameter, color: Themes.Current.BorderColor)
        drawCompassCheck(ctx, x: center.x, y: center.y, compassDegrees: northwest_degrees, altitude: 18.0, diameter: inner_inner_diameter, color: Themes.Current.BorderColor)
        drawCompassCheck(ctx, x: center.x, y: center.y, compassDegrees: southeast_degrees, altitude: 18.0, diameter: inner_inner_diameter, color: Themes.Current.BorderColor)
        drawCompassCheck(ctx, x: center.x, y: center.y, compassDegrees: southwest_degrees, altitude: 18.0, diameter: inner_inner_diameter, color: Themes.Current.BorderColor)
        
        drawCompassCheck(ctx, x: center.x, y: center.y, compassDegrees: north_degrees, altitude: 20.0, diameter: inner_inner_diameter, color: Themes.Current.BorderColor)
        drawCompassCheck(ctx, x: center.x, y: center.y, compassDegrees: east_degrees, altitude: 20.0, diameter: inner_inner_diameter, color: Themes.Current.BorderColor)
        drawCompassCheck(ctx, x: center.x, y: center.y, compassDegrees: west_degrees, altitude: 20.0, diameter: inner_inner_diameter, color: Themes.Current.BorderColor)
        drawCompassCheck(ctx, x: center.x, y: center.y, compassDegrees: south_degrees, altitude: 20.0, diameter: inner_inner_diameter, color: Themes.Current.BorderColor)
        
        drawCompassLabel(ctx, x: center.x, y: center.y, label: northeast, textAttributes: large_text, compassDegrees: northeast_degrees, diameter: CGFloat(inner_inner_diameter - 30.0))
        drawCompassLabel(ctx, x: center.x, y: center.y, label: northwest, textAttributes: large_text, compassDegrees: northwest_degrees, diameter: CGFloat(inner_inner_diameter - 30.0))
        drawCompassLabel(ctx, x: center.x, y: center.y, label: southeast, textAttributes: large_text, compassDegrees: southeast_degrees, diameter: CGFloat(inner_inner_diameter - 30.0))
        drawCompassLabel(ctx, x: center.x, y: center.y, label: southwest, textAttributes: large_text, compassDegrees: southwest_degrees, diameter: CGFloat(inner_inner_diameter - 30.0))
        
        drawCompassLabel(ctx, x: center.x, y: center.y, label: north, textAttributes: large_text, compassDegrees: north_degrees, diameter: CGFloat(inner_inner_diameter - 30.0))
        drawCompassLabel(ctx, x: center.x, y: center.y, label: east, textAttributes: large_text, compassDegrees: east_degrees, diameter: CGFloat(inner_inner_diameter - 30.0))
        drawCompassLabel(ctx, x: center.x, y: center.y, label: west, textAttributes: large_text, compassDegrees: west_degrees, diameter: CGFloat(inner_inner_diameter - 30.0))
        drawCompassLabel(ctx, x: center.x, y: center.y, label: south, textAttributes: large_text, compassDegrees: south_degrees, diameter: CGFloat(inner_inner_diameter - 30.0))
        
        CGContextSaveGState(ctx)
        CGContextSetFillColorWithColor(ctx, Themes.Current.BorderColor.CGColor)
        CGContextAddArc(ctx, center.x, center.y, CGFloat(20.0 * scale), CGFloat(0.0), CGFloat(M_PI*2.0), Int32(1))
        CGContextFillPath(ctx)
        
        //draw the destination compass needle
        
        if nil != self.CurrentHeadingError {
            
            var destination_bearing = self.CurrentHeadingError
            if destination_bearing < 0.0 {
                destination_bearing = destination_bearing + 360.0
            }
            
            let destination_radians = CompassUtil.DegreesToCompassRadians(destination_bearing)
            
            let needle_radius = Double(inner_inner_diameter / 2.0) - 20.0
            
            let needle_top_x = Double(center.x) - (needle_radius * sin(destination_radians))
            let needle_top_y = Double(center.y) - (needle_radius * cos(destination_radians))
            
            let needle_bottom_x = Double(center.x) + (needle_radius * sin(destination_radians))
            let needle_bottom_y = Double(center.y) + (needle_radius * cos(destination_radians))
            
            CGContextSaveGState(ctx)
            CGContextSetStrokeColorWithColor(ctx, Themes.Current.BorderColor.CGColor)
            CGContextSetLineWidth(ctx, 3)
            
            var needle_main_path = CGPathCreateMutable()
            CGPathMoveToPoint(needle_main_path, nil, CGFloat(needle_top_x), CGFloat(needle_top_y))
            CGPathAddLineToPoint(needle_main_path, nil, CGFloat(needle_bottom_x), CGFloat(needle_bottom_y))
            CGPathCloseSubpath(needle_main_path)
            CGContextAddPath(ctx, needle_main_path)
            CGContextStrokePath(ctx)
            
            let arrow_height = CGFloat(outer_inner_diameter - inner_outer_diameter)
            
            let arrow_degrees = -1.0 * CompassUtil.AddDegrees(destination_bearing, addition: 180.0)
            
            drawCompassTriangle(ctx, x: CGFloat(needle_top_x), y: CGFloat(needle_top_y), compassDegrees: arrow_degrees, altitude: arrow_height, width: 20.0, fillColor: Themes.Current.BorderColor)
            
            let circlet_diameter = Double(arrow_height / 2.0)
            
            let circle_center_x = Double(center.x) + ((needle_radius + (circlet_diameter / 2.0)) * sin(destination_radians))
            let circle_center_y = Double(center.y) + ((needle_radius + (circlet_diameter / 2.0)) * cos(destination_radians))
            
            //compute the normals for the angle.
            let arrow_dest = CompassUtil.AddDegrees(destination_bearing, addition: -90.0)
            let circle_normal_left_degrees = CompassUtil.AddDegrees(arrow_dest, addition: 90.0)
            let circle_normal_right_degrees = CompassUtil.AddDegrees(arrow_dest, addition: -1*90.0)
            
            let circle_normal_left_radians = CompassUtil.ToRadians(circle_normal_left_degrees)
            let circle_normal_right_radians = CompassUtil.ToRadians(circle_normal_right_degrees)
            
            CGContextSaveGState(ctx)
            
            CGContextSetLineWidth(ctx, 3)
            CGContextSetStrokeColorWithColor(ctx, Themes.Current.BorderColor.CGColor)
            CGContextAddArc(ctx, CGFloat(circle_center_x), CGFloat(circle_center_y), CGFloat(circlet_diameter / 2.0), CGFloat(circle_normal_left_radians), CGFloat(circle_normal_right_radians), Int32(1))
            CGContextStrokePath(ctx)
        }
    }
    
    func _drawDistanceText(rect: CGRect, fontSize: CGFloat, center: CGPoint) {
        let text_attributes = createTextAttributes(fontSize)
        var distance_text : NSString = "Distance Unknown"
        if nil != self.DistanceMeters {
            distance_text = CompassUtil.FormatDistance(self.DistanceMeters) + " away" as NSString
        }
        
        let distance_text_size = distance_text.sizeWithAttributes(text_attributes)
        
        var dt_x = (bounds.size.width / 2.0) - (distance_text_size.width / 2.0)
        var dt_y = (bounds.size.height / 10.0)
        
        let distance_text_rect = CGRectMake(CGFloat(dt_x), CGFloat(dt_y), CGFloat(distance_text_size.width), CGFloat(distance_text_size.height))
        distance_text.drawInRect(distance_text_rect, withAttributes: text_attributes)
    }
    
    func _calculateDiameter() -> CGFloat {
        var diameter : CGFloat = 0.0
        
        var margin_ratio = 0.1
        if UIScreen.mainScreen().bounds.height < 568 {
            margin_ratio = 0.3
        }
        
        if bounds.size.width < bounds.size.height {
            diameter = bounds.size.width - (bounds.size.width * CGFloat(margin_ratio))
        } else {
            diameter = bounds.size.height - (bounds.size.height * CGFloat(margin_ratio))
        }
        
        return diameter
    }
    
    override func drawRect(rect: CGRect) {
        
        self.backgroundColor = Themes.Current.BackgroundColor
        
        if nil == UIGraphicsGetCurrentContext() {
            return
        }
        
        let center_x : Double = Double(bounds.origin.x) + Double(bounds.size.width) / 2.0
        let center_y : Double = Double(bounds.origin.y) + Double(bounds.size.height) / 2.0
        let center = CGPoint(x: center_x, y: center_y)
        
        let diameter = _calculateDiameter()
        let outer_ratio = diameter / 800.0
        
        let large_font_size = 60.0 * outer_ratio
        let small_font_size = 30.8 * outer_ratio
        
        _drawCompass(rect, center: center, largeFontSize: large_font_size, smallFontSize: small_font_size, scale: outer_ratio)
        
        if nil != self.interfaceOrientation && (self.interfaceOrientation! == UIInterfaceOrientation.Portrait || self.interfaceOrientation! == UIInterfaceOrientation.PortraitUpsideDown) {
            _drawDistanceText(rect, fontSize: large_font_size, center: center)
        }
    }
}