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
    
    var CurrentHeading : Double!
    var CurrentHeadingError : Double!
    var CurrentDestinationHeading: Double!

    func viewWillAppear(animated: Bool) {
        self.backgroundColor = Themes.Current.BackgroundColor
    }
    
    override func drawRect(rect: CGRect) {
        
        self.backgroundColor = Themes.Current.BackgroundColor
        
        let ctx = UIGraphicsGetCurrentContext();
        let bounds = self.bounds
        
        let center_x : Double = Double(bounds.origin.x) + Double(bounds.size.width) / 2.0
        let center_y : Double = Double(bounds.origin.y) + Double(bounds.size.height) / 2.0
        let center = CGPoint(x: center_x, y: center_y)
        
        var diameter : CGFloat = 0.0
        if bounds.size.width < bounds.size.height {
            diameter = (bounds.size.width / 3.0) * 2.0
        } else {
            diameter = (bounds.size.height / 3.0) * 2.0
        }
        
        //draw circle
        CGContextSetLineWidth(ctx, 5)
        CGContextSetStrokeColorWithColor(ctx, Themes.Current.SecondaryColor.CGColor)
        CGContextAddArc(ctx, center.x, center.y, CGFloat(diameter / 2.0), CGFloat(0.0), CGFloat(M_PI*2.0), Int32(1))
        CGContextStrokePath(ctx)
        
        //draw 'Camera View Angle' wide direction to destination
        if nil != self.CurrentDestinationHeading {
            
            //assume "0.0" is north.
            //assume 'Destination Bearing' is correct in relation to 'north'
            //assume 'Current Heading' is what the new top should be, adjust 'Destination Bearing' by current bearing
            
            var dest = CurrentHeadingError
            if dest < 360.0 {
                dest = dest + 360.0
            }
            
            let dest_start = _c2r( dest + (PelorusNav.CameraViewAngle / 2.0) )
            let dest_end = _c2r( dest - (PelorusNav.CameraViewAngle / 2.0) )
            
            CGContextSaveGState(ctx);
            CGContextSetFillColorWithColor(ctx, Themes.Current.HighlightColor.CGColor);
            var path = CGPathCreateMutable()
            
            CGPathMoveToPoint(path, nil, center.x, center.y)
            
            let arc_d = Double(diameter) * 10.0
            CGPathAddArc(path, nil, center.x, center.y, CGFloat(arc_d / 2.0), CGFloat(dest_start), CGFloat(dest_end), true)
            CGPathCloseSubpath(path)
            
            CGContextAddPath(ctx, path)
            CGContextFillPath(ctx)
            
            //draw arc section
            CGContextSaveGState(ctx)
            
            CGContextSetLineWidth(ctx, 10)
            CGContextSetStrokeColorWithColor(ctx, Themes.Current.PrimaryColor.CGColor)
            
            CGContextAddArc(ctx, center.x, center.y, CGFloat(diameter / 2.0), CGFloat(dest_start), CGFloat(dest_end), Int32(1))
            CGContextStrokePath(ctx)
        }
        
        let textAttributes : Dictionary<NSObject, AnyObject> = [
            NSFontAttributeName : Themes.Current.PrimaryFont as AnyObject,
            NSForegroundColorAttributeName : Themes.Current.PrimaryFontColor as AnyObject,
        ]

        let text_width : Double = 23.0
        let text_height : Double = Double(Themes.Current.PrimaryFont.lineHeight)
        
        let north : NSString = "N"
        let east : NSString = "E"
        let south : NSString = "S"
        let west : NSString = "W"
        
        //draw 'N', 'E', 'S', 'W' etc.
        if nil != self.CurrentHeading {
            
            CGContextSaveGState(ctx)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = NSLineBreakMode.ByClipping
            
            var north_theta = DistanceVector.CalculateBearingDifference(0.0, to: CurrentHeading)
            north_theta = north_theta - 90.0 //because radians, ~pi/2.0.
            if north_theta < 0.0 {
                north_theta = (360.0 + north_theta)
            }
            
            let north_x : Double = Double(center.x) + (Double(diameter) / 2.0) * sin(_c2r(north_theta)) - (text_width / 2.0)
            let north_y : Double = Double(center.y) + (Double(diameter) / 2.0) * cos(_c2r(north_theta)) - (text_height / 2.0)
            let north_rect = CGRectMake(CGFloat(north_x), CGFloat(north_y), CGFloat(text_width), CGFloat(text_height))
            north.drawInRect(north_rect, withAttributes: textAttributes)
            
            var south_theta = north_theta + 180.0
            if south_theta > 360.0 {
                south_theta = south_theta - 360.0
            }
            
            let south_x : Double = Double(center.x) + (Double(diameter) / 2.0) * sin(_c2r(south_theta)) - (text_width / 2.0)
            let south_y : Double = Double(center.y) + (Double(diameter) / 2.0) * cos(_c2r(south_theta)) - (text_height / 2.0)
            let south_rect = CGRectMake(CGFloat(south_x), CGFloat(south_y), CGFloat(text_width), CGFloat(text_height))
            south.drawInRect(south_rect, withAttributes: textAttributes)
            
            var east_theta = north_theta - 90.0
            if east_theta > 360 {
                east_theta = east_theta - 360.0
            } else if east_theta < 0.0 {
                east_theta = east_theta + 360.0
            }
            
            let east_x : Double = Double(center.x) + (Double(diameter) / 2.0) * sin(_c2r(east_theta)) - (text_width / 2.0)
            let east_y : Double = Double(center.y) + (Double(diameter) / 2.0) * cos(_c2r(east_theta)) - (text_height / 2.0)
            let east_rect = CGRectMake(CGFloat(east_x), CGFloat(east_y), CGFloat(text_width), CGFloat(text_height))
            east.drawInRect(east_rect, withAttributes: textAttributes)
            
            var west_theta = north_theta + 90.0
            if west_theta > 360.0 {
                west_theta = west_theta - 360.0
            } else if west_theta < 0.0 {
                west_theta = west_theta + 360.0
            }
            
            let west_x : Double = Double(center.x) + (Double(diameter) / 2.0) * sin(_c2r(west_theta)) - ((text_width + 3.0) / 2.0)
            let west_y : Double = Double(center.y) + (Double(diameter) / 2.0) * cos(_c2r(west_theta)) - (text_height / 2.0)
            let west_rect = CGRectMake(CGFloat(west_x), CGFloat(west_y), CGFloat(text_width + 3.0), CGFloat(text_height))
            west.drawInRect(west_rect, withAttributes: textAttributes)
        }
        
        CGContextSaveGState(ctx)
    }
    
    func _c2r(compass_heading: Double) -> Double {
        let radians : Double = DistanceVector.Radians(compass_heading)
        let half_pi : Double = M_PI / 2.0
        return radians - half_pi
    }
}

class CompassViewController: UIThemedViewController, PelorusNavUpdateReceiverDelegate {
    
    var _nav: PelorusNav!
    
    @IBOutlet var compassView : CompassControlView!
    @IBOutlet var setDestinationButton : UIBarButtonItem!
    
    @IBOutlet var distanceText : UILabel!
    @IBOutlet var destinationText : UILabel!
    
    @IBAction func clearDestinationClicked(sender: AnyObject){
        _nav.ClearDestination()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        _nav = appDelegate.NavManager
        
        setDestinationButton.enabled = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        compassView.viewWillAppear(animated)
        
        _nav.Receiver = self

        distanceText.textColor = Themes.Current.PrimaryFontColor
        destinationText.textColor = Themes.Current.PrimaryFontColor
        
        if(nil == _nav.CurrentDestination) {    
            destinationText.text = "Hit \"Set\" to choose a destination."
        } else {
            setDestinationButton.enabled = true
            
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
    
    func HeadingUpdated(sender: PelorusNav) {
        compassView.CurrentHeading = sender.CurrentHeading
        compassView.CurrentDestinationHeading = sender.CurrentDestinationHeading
        compassView.CurrentHeadingError = sender.CurrentHeadingError
        self.compassView.setNeedsDisplay()
        
        if nil != sender.CurrentDistance {
            self.distanceText.text = DistanceVector.FormatDistance(sender.CurrentDistance.DistanceMeters)
        } else {
            self.distanceText.text = "N/A"
        }
    }
    
    func LocationUpdated(sender: PelorusNav) {
        setDestinationButton.enabled = true
        
        if nil != sender.CurrentDistance {
            self.distanceText.text = DistanceVector.FormatDistance(sender.CurrentDistance.DistanceMeters)
        } else {
            self.distanceText.text = "N/A"
        }
    }
}