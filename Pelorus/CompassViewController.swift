//
//  CompassViewController.swift
//  Pelorus
//
//  Created by Will Charczuk on 11/11/14.
//  Copyright (c) 2014 Will Charczuk. All rights reserved.
//

import UIKit
import CoreGraphics

class CompassControlView : UIView {
    
    var DistanceMeters: Double!
    var CurrentHeading : Double!
    var CurrentHeadingError : Double!
    var CurrentDestinationHeading: Double!

    func viewWillAppear(animated: Bool) {
        self.backgroundColor = Themes.Current.BackgroundColor
    }
    
    override func drawRect(rect: CGRect) {
        
        self.backgroundColor = Themes.Current.BackgroundColor
        
        let ctx = UIGraphicsGetCurrentContext()
        
        if nil == ctx {
            return
        }
        
        let bounds = self.bounds
        
        let center_x : Double = Double(bounds.origin.x) + Double(bounds.size.width) / 2.0
        let center_y : Double = Double(bounds.origin.y) + Double(bounds.size.height) / 2.0
        let center = CGPoint(x: center_x, y: center_y)
        
        var diameter : CGFloat = 0.0
        if bounds.size.width < bounds.size.height {
            diameter = bounds.size.width - (bounds.size.width * 0.1)
        } else {
            diameter = bounds.size.height - (bounds.size.height * 0.1)
        }
        
        let outer_ratio = diameter / 800.0
        
        let _2_pi = 2 * M_PI
        
        //draw compass and compass rose
        //draw circle
        CGContextSetLineWidth(ctx, 2)
        CGContextSetStrokeColorWithColor(ctx, Themes.Current.BorderColor.CGColor)
        CGContextAddArc(ctx, center.x, center.y, CGFloat(diameter / 2.0), CGFloat(0.0), CGFloat(_2_pi), Int32(1))
        CGContextStrokePath(ctx)
        
        let outer_inner_diameter = 775 * outer_ratio
        
        CGContextSetLineWidth(ctx, 1)
        CGContextSetStrokeColorWithColor(ctx, Themes.Current.BorderColor.CGColor)
        CGContextAddArc(ctx, center.x, center.y, CGFloat(outer_inner_diameter / 2.0), CGFloat(0.0), CGFloat(_2_pi), Int32(1))
        CGContextStrokePath(ctx)
        
        let inner_outer_diameter = 675.0 * outer_ratio
        
        CGContextSetLineWidth(ctx, 1)
        CGContextSetStrokeColorWithColor(ctx, Themes.Current.BorderColor.CGColor)
        CGContextAddArc(ctx, center.x, center.y, CGFloat(inner_outer_diameter / 2.0), CGFloat(0.0), CGFloat(_2_pi), Int32(1))
        CGContextStrokePath(ctx)
        
        let inner_inner_diameter = 648.0 * outer_ratio
        
        CGContextSetLineWidth(ctx, 1)
        CGContextSetStrokeColorWithColor(ctx, Themes.Current.BorderColor.CGColor)
        CGContextAddArc(ctx, center.x, center.y, CGFloat(inner_inner_diameter / 2.0), CGFloat(0.0), CGFloat(_2_pi), Int32(1))
        CGContextStrokePath(ctx)
        
        let rose_diameter = 315 * outer_ratio
        
        CGContextSetLineWidth(ctx, 1)
        CGContextSetStrokeColorWithColor(ctx, Themes.Current.BorderColor.CGColor)
        CGContextAddArc(ctx, center.x, center.y, CGFloat(rose_diameter / 2.0), CGFloat(0.0), CGFloat(_2_pi), Int32(1))
        CGContextStrokePath(ctx)
    
        let heading_x = bounds.size.width / 2.0
        let heading_y = (bounds.size.height / 2.0) - ((diameter / 2.0) + 5.0)
        
        
        //this is the little 'heading' triangle on the top of the compass
        _draw_triangle(ctx, x: heading_x, y: heading_y, compassDegrees: 180.0, altitude: 10.0, width: 10.0, fillColor: Themes.Current.PrimaryColor)
        
        let textAttributes : Dictionary<NSObject, AnyObject> = [
            NSFontAttributeName : Themes.Current.PrimaryFont.fontWithSize(30.0) as AnyObject,
            NSForegroundColorAttributeName : Themes.Current.PrimaryFontColor as AnyObject,
        ]
        
        let small_textAttributes : Dictionary<NSObject, AnyObject> = [
            NSFontAttributeName : Themes.Current.PrimaryFont.fontWithSize(14.0) as AnyObject,
            NSForegroundColorAttributeName : Themes.Current.PrimaryFontColor as AnyObject,
        ]
        
        let north : NSString = "N"
        let east  : NSString = "E"
        let south : NSString = "S"
        let west  : NSString = "W"
        
        let major_size = west.sizeWithAttributes(textAttributes)
        
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
        
        let minor_rose_triangle_altitude = (110 * outer_ratio) * 2.0
        let major_rose_triangle_altitude = rose_diameter
        
        let minor_rose_width = 82 * outer_ratio
        let major_rose_width = 108 * outer_ratio
        
        //draw compass rose 
        _draw_triangle(ctx, x: center.x, y: center.y, compassDegrees: northeast_degrees, altitude: minor_rose_triangle_altitude, width: minor_rose_width, fillColor: Themes.Current.BorderColor)
        _draw_triangle(ctx, x: center.x, y: center.y, compassDegrees: northwest_degrees, altitude: minor_rose_triangle_altitude, width: minor_rose_width, fillColor: Themes.Current.BorderColor)
        _draw_triangle(ctx, x: center.x, y: center.y, compassDegrees: southeast_degrees, altitude: minor_rose_triangle_altitude, width: minor_rose_width, fillColor: Themes.Current.BorderColor)
        _draw_triangle(ctx, x: center.x, y: center.y, compassDegrees: southwest_degrees, altitude: minor_rose_triangle_altitude, width: minor_rose_width, fillColor: Themes.Current.BorderColor)
        
        _draw_triangle(ctx, x: center.x, y: center.y, compassDegrees: north_degrees, altitude: major_rose_triangle_altitude, width: major_rose_width, fillColor: Themes.Current.PrimaryColor)
        _draw_triangle(ctx, x: center.x, y: center.y, compassDegrees: east_degrees, altitude: major_rose_triangle_altitude, width: major_rose_width, fillColor: Themes.Current.PrimaryColor)
        _draw_triangle(ctx, x: center.x, y: center.y, compassDegrees: west_degrees, altitude: major_rose_triangle_altitude, width: major_rose_width, fillColor: Themes.Current.PrimaryColor)
        _draw_triangle(ctx, x: center.x, y: center.y, compassDegrees: south_degrees, altitude: major_rose_triangle_altitude, width: major_rose_width, fillColor: Themes.Current.PrimaryColor)
        
        //draw direction labels
        
        _draw_compass_check(ctx, x: center.x, y: center.y, compassDegrees: northeast_degrees, altitude: 18.0, diameter: inner_inner_diameter, color: Themes.Current.BorderColor)
        _draw_compass_check(ctx, x: center.x, y: center.y, compassDegrees: northwest_degrees, altitude: 18.0, diameter: inner_inner_diameter, color: Themes.Current.BorderColor)
        _draw_compass_check(ctx, x: center.x, y: center.y, compassDegrees: southeast_degrees, altitude: 18.0, diameter: inner_inner_diameter, color: Themes.Current.BorderColor)
        _draw_compass_check(ctx, x: center.x, y: center.y, compassDegrees: southwest_degrees, altitude: 18.0, diameter: inner_inner_diameter, color: Themes.Current.BorderColor)
        
        _draw_compass_check(ctx, x: center.x, y: center.y, compassDegrees: north_degrees, altitude: 20.0, diameter: inner_inner_diameter, color: Themes.Current.BorderColor)
        _draw_compass_check(ctx, x: center.x, y: center.y, compassDegrees: east_degrees, altitude: 20.0, diameter: inner_inner_diameter, color: Themes.Current.BorderColor)
        _draw_compass_check(ctx, x: center.x, y: center.y, compassDegrees: west_degrees, altitude: 20.0, diameter: inner_inner_diameter, color: Themes.Current.BorderColor)
        _draw_compass_check(ctx, x: center.x, y: center.y, compassDegrees: south_degrees, altitude: 20.0, diameter: inner_inner_diameter, color: Themes.Current.BorderColor)
        
        _draw_compass_label(ctx, x: center.x, y: center.y, label: northeast, textAttributes: textAttributes, compassDegrees: northeast_degrees, diameter: CGFloat(inner_inner_diameter - 30.0))
        _draw_compass_label(ctx, x: center.x, y: center.y, label: northwest, textAttributes: textAttributes, compassDegrees: northwest_degrees, diameter: CGFloat(inner_inner_diameter - 30.0))
        _draw_compass_label(ctx, x: center.x, y: center.y, label: southeast, textAttributes: textAttributes, compassDegrees: southeast_degrees, diameter: CGFloat(inner_inner_diameter - 30.0))
        _draw_compass_label(ctx, x: center.x, y: center.y, label: southwest, textAttributes: textAttributes, compassDegrees: southwest_degrees, diameter: CGFloat(inner_inner_diameter - 30.0))
        
        _draw_compass_label(ctx, x: center.x, y: center.y, label: north, textAttributes: textAttributes, compassDegrees: north_degrees, diameter: CGFloat(inner_inner_diameter - 30.0))
        _draw_compass_label(ctx, x: center.x, y: center.y, label: east, textAttributes: textAttributes, compassDegrees: east_degrees, diameter: CGFloat(inner_inner_diameter - 30.0))
        _draw_compass_label(ctx, x: center.x, y: center.y, label: west, textAttributes: textAttributes, compassDegrees: west_degrees, diameter: CGFloat(inner_inner_diameter - 30.0))
        _draw_compass_label(ctx, x: center.x, y: center.y, label: south, textAttributes: textAttributes, compassDegrees: south_degrees, diameter: CGFloat(inner_inner_diameter - 30.0))
       
        CGContextSaveGState(ctx)
        CGContextSetFillColorWithColor(ctx, Themes.Current.BorderColor.CGColor)
        CGContextAddArc(ctx, center.x, center.y, CGFloat(20.0 * outer_ratio), CGFloat(0.0), CGFloat(M_PI*2.0), Int32(1))
        CGContextFillPath(ctx)
        
        //draw distance text
        
        var distance_text : NSString = "Distance Unknown"
        if nil != self.DistanceMeters {
            distance_text = CompassUtil.FormatDistance(self.DistanceMeters) + " away" as NSString
        }
        let distance_text_size = distance_text.sizeWithAttributes(textAttributes)
        
        var dt_x = (bounds.size.width / 2.0) - (distance_text_size.width / 2.0)
        var dt_y = (bounds.size.height / 10.0)
        let orientation = UIDevice.currentDevice().orientation
        if orientation == UIDeviceOrientation.LandscapeLeft || orientation == UIDeviceOrientation.LandscapeRight {
           dt_x = 16
        }
        
        let distance_text_rect = CGRectMake(CGFloat(dt_x), CGFloat(dt_y), CGFloat(distance_text_size.width), CGFloat(distance_text_size.height))
        distance_text.drawInRect(distance_text_rect, withAttributes: textAttributes)
        
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
            
            _draw_triangle(ctx, x: CGFloat(needle_top_x), y: CGFloat(needle_top_y), compassDegrees: arrow_degrees, altitude: arrow_height, width: 20.0, fillColor: Themes.Current.BorderColor)
            
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
    
    func _draw_compass_check(ctx: CGContext!, x: CGFloat, y: CGFloat, compassDegrees: Double, altitude: CGFloat, diameter: CGFloat, color: UIColor) {
        
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
    
    func _draw_compass_label(ctx: CGContext!, x: CGFloat, y: CGFloat, label: NSString, textAttributes: Dictionary<NSObject, AnyObject>, compassDegrees: Double, diameter: CGFloat) {
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
    
    func _draw_triangle(ctx: CGContext!, x: CGFloat, y: CGFloat, compassDegrees: Double, altitude: CGFloat, width: CGFloat, fillColor: UIColor) {
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

class CompassViewController: UIThemedViewController, PelorusNavUpdateReceiverDelegate {
    
    var _nav: PelorusNav!
    
    @IBOutlet var compassView : CompassControlView!
    @IBOutlet var setDestinationButton : UIBarButtonItem!
    
    @IBOutlet var destinationText : UILabel!
    var destinationTextTapGesture : UITapGestureRecognizer!
    
    @IBAction func clearDestinationClicked(sender: AnyObject){
        _nav.ClearDestination()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        _nav = appDelegate.NavManager
        
        destinationTextTapGesture = UITapGestureRecognizer()
        destinationTextTapGesture.numberOfTapsRequired = 1
        destinationTextTapGesture.addTarget(self, action: "SetDestinationTransition")
        destinationText.addGestureRecognizer(destinationTextTapGesture)
        destinationText.userInteractionEnabled = true

        setDestinationButton.enabled = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        compassView.viewWillAppear(animated)
        
        _nav.Receiver = self

        destinationText.textColor = Themes.Current.PrimaryFontColor
        
        if nil == _nav.CurrentDestination {
            destinationText.text = "Hit \"Set\" to choose a destination."
        } else {
            if nil != _nav.CurrentDestination.Label {
                destinationText.text = _nav.CurrentDestination.Label
            } else {
                destinationText.text = "\(_nav.CurrentDestination.Latitude), \(_nav.CurrentDestination.Longitude)"
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func SetDestinationTransition() {
        self.performSegueWithIdentifier("selectDestinationSegue", sender: self.navigationController)
    }
    
    func HeadingUpdated(sender: PelorusNav) {
        compassView.CurrentHeading = sender.CurrentHeading
        compassView.CurrentDestinationHeading = sender.CurrentDestinationHeading
        compassView.CurrentHeadingError = sender.CurrentHeadingError
        self.compassView.setNeedsDisplay()
    }
    
    func LocationUpdated(sender: PelorusNav) {
        setDestinationButton.enabled = true
        
        
        if nil != sender.CurrentDistance {
            compassView.DistanceMeters = sender.CurrentDistance.DistanceMeters
        }
    }
}