//
//  RealityViewController.swift
//  Pelorus
//
//  Created by Will Charczuk on 11/20/14.
//  Copyright (c) 2014 Will Charczuk. All rights reserved.
//

import UIKit
import CoreGraphics
import AVFoundation
import CoreMotion

class CameraFeedView : UIView {
    
    var _session : AVCaptureSession!
    var _captureDevice : AVCaptureDevice!
    var _previewLayer : AVCaptureVideoPreviewLayer!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func BeginFeed() {
        
        UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "HandleOrientationChange", name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        _session = AVCaptureSession()
        _session.sessionPreset = AVCaptureSessionPresetPhoto
        
        let devices = AVCaptureDevice.devices()
        for device in devices {
            // Make sure this particular device supports video
            if (device.hasMediaType(AVMediaTypeVideo)) {
                if(device.position == AVCaptureDevicePosition.Back) {
                    _captureDevice = device as? AVCaptureDevice
                }
            }
        }
        
        if _captureDevice != nil {
            
            var err : NSError? = nil
            _session.addInput(AVCaptureDeviceInput(device: _captureDevice, error: &err))
            
            if err != nil {
                NSLog("Camera Error: \(err?.localizedDescription)")
            }
            
            _previewLayer = AVCaptureVideoPreviewLayer(session: _session)
            self.layer.addSublayer(_previewLayer)
            
            if let device = _captureDevice {
                device.lockForConfiguration(nil)
                device.focusMode = .ContinuousAutoFocus
                device.unlockForConfiguration()
            }
            
            if !_session.running {
                _session.startRunning()
            }
            
            HandleOrientationChange()
        }
    }
    
    func HandleOrientationChange() {
        
        let frame_bounds = self.bounds
        _previewLayer.frame = frame_bounds
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        _previewLayer.contentsGravity = kCAGravityResizeAspectFill
        _previewLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))
        
        let orientation = UIDevice.currentDevice().orientation
        
        switch(orientation) {
            case UIDeviceOrientation.LandscapeLeft:
                _previewLayer.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeRight
                break
            case UIDeviceOrientation.LandscapeRight:
                _previewLayer.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeLeft
                break
            default:
                _previewLayer.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeLeft
        }
    }
}

class InterfaceView : UIView {
    
    var Destination : String!
    
    var CurrentHeadingError : Double!
    var CurrentDestinationHeading : Double!
    var CurrentHeading: Double!
    
    var CurrentDistanceMeters : Double!
    
    var DeviceRoll : Double!
    var DevicePitch : Double!
    
    func _isAboveCamera() -> Bool {

        if nil != DevicePitch {
            return chevron_y <= 1
        } else {
            return false
        }
    }
    
    func _isBelowCamera() -> Bool {
        let bounds = self.bounds
        if nil != DevicePitch {
            return chevron_y >= (bounds.height - 1)
        } else {
            return false
        }
    }
    
    func _isLeftOfCamera() -> Bool{
        if nil != CurrentHeadingError {
            return chevron_x <= 1
        } else {
            return false
        }
    }
    
    func _isRightOfCamera() -> Bool {
        let bounds = self.bounds
        if nil != CurrentHeadingError {
            return chevron_x >= (bounds.width - 1)
        } else {
            return false
        }
    }
    
    func _isInView() -> Bool {
        if nil != CurrentHeadingError {
            return !(_isLeftOfCamera() || _isRightOfCamera() || _isAboveCamera() || _isBelowCamera())
        } else {
            return false
        }
    }
    
    var chevron_x : CGFloat = 0.0
    var chevron_y : CGFloat = 0.0
    
    var chevronPointQueue : [(CGFloat, CGFloat)] = [(CGFloat, CGFloat)]()
    
    func enqueue( newPoint: (CGFloat, CGFloat) ) {
        if chevronPointQueue.count >= 7 {
            let newRange = chevronPointQueue[1 ... 6]
            chevronPointQueue = Array(newRange)
        }
        chevronPointQueue = chevronPointQueue + [newPoint]
    }
    
    func averagePoints( newPoint: (CGFloat, CGFloat) ) -> (CGFloat, CGFloat) {
        enqueue(newPoint)
        
        var avg_x = CGFloat(0.0)
        var avg_y = CGFloat(0.0)
        
        for point in chevronPointQueue {
            avg_x = avg_x + point.0
            avg_y = avg_y + point.1
        }
        
        return (avg_x / CGFloat(chevronPointQueue.count), avg_y / CGFloat(chevronPointQueue.count))
    }
    
    func calculateChevronPosition() {
        
        let bounds = self.bounds
        
        var aspect = CGFloat(bounds.size.width / bounds.size.height)
        
        let absolute_heading_error = abs(self.CurrentHeadingError)
        let error_pct = CGFloat(absolute_heading_error / PelorusNav.CameraViewAngle)
        let camera_angle = CGFloat(PelorusNav.CameraViewAngle)
        
        let vertical_camera_angle = camera_angle / aspect
        
        if CurrentHeadingError < 0 {
            chevron_x = (bounds.size.width / 2.0) - (error_pct * bounds.size.width)
        } else {
            chevron_x = (bounds.size.width / 2.0) + (error_pct * bounds.size.width)
        }
        
        //figure chevron_y based on device pitch.
        if nil != DevicePitch {
            //          down    level   up
            //pitch     -1.0    0.0     1.0
            
            let cg_pitch = CGFloat(DevicePitch!)
            let adjusted_pitch = cg_pitch * aspect
            
            let mid_y = CGFloat(bounds.size.height / 2.0)
            chevron_y = mid_y + (mid_y * adjusted_pitch)
            
        } else {
            chevron_y = CGFloat(bounds.size.height) / 2.0
        }
        
        if chevron_x < 1 {
            chevron_x = 1
        } else if chevron_x >= bounds.size.width {
            chevron_x = bounds.size.width - 1
        }
        
        if chevron_y < 1 {
            chevron_y = 1
        } else if chevron_y >= bounds.size.height {
            chevron_y = bounds.size.height - 1
        }
        
        let averaged = averagePoints( (chevron_x, chevron_y) )
        
        chevron_x = averaged.0
        chevron_y = averaged.1
    }
    
    override func drawRect(rect: CGRect) {
        
        if nil == CurrentHeadingError || nil == CurrentDistanceMeters {
            return
        }
        
        calculateChevronPosition()
        
        let ctx = UIGraphicsGetCurrentContext();
        let bounds = self.bounds
        
        let font : UIFont = Themes.Current.PrimaryFont
        
        let primary_color = Themes.Current.PrimaryColor
        let secondary_color = Themes.Current.SecondaryColor
        
        let textAttributes : Dictionary<NSObject, AnyObject> = [
            NSFontAttributeName : font as AnyObject,
            NSForegroundColorAttributeName : primary_color as AnyObject,
        ]
        
        let min_dim = min(bounds.size.height, bounds.size.width)
        let max_dim = max(bounds.size.height, bounds.size.width)
        
        let chevron_max_height = min_dim / 4.0
        let chevron_max_width = max_dim / 4.0
        
        let chevron_height = chevron_max_height / 2.0
        let chevron_width = chevron_max_height / 2.0
        
        CGContextSaveGState(ctx)
        CGContextSetLineWidth(ctx, 3)
        CGContextSetStrokeColorWithColor(ctx, primary_color.CGColor)
        
        let distanceText = CompassUtil.FormatDistance(self.CurrentDistanceMeters) as NSString
        let text_size = distanceText.sizeWithAttributes(textAttributes)

        if _isInView() {

            let path = CGPathCreateMutable()
            CGPathMoveToPoint(path, nil, chevron_x, chevron_y)
            CGPathAddLineToPoint(path, nil, chevron_x - chevron_width, chevron_y - chevron_height)
            CGPathMoveToPoint(path, nil, chevron_x - 1, chevron_y + 1)
            CGPathAddLineToPoint(path, nil, chevron_x + chevron_width, chevron_y - chevron_height)
            CGPathCloseSubpath(path)
            CGContextAddPath(ctx, path)
            CGContextStrokePath(ctx)
            
            CGContextSaveGState(ctx)
            let text_x = chevron_x - (text_size.width / 2.0)
            let text_y = chevron_y + 5.0
            let text_rect = CGRectMake(CGFloat(text_x), CGFloat(text_y), text_size.width, text_size.height)
            distanceText.drawInRect(text_rect, withAttributes: textAttributes)
            
        } else if _isAboveCamera() {

            let path = CGPathCreateMutable()
            CGPathMoveToPoint(path, nil, chevron_x, chevron_y)
            CGPathAddLineToPoint(path, nil, chevron_x - chevron_width, chevron_y + chevron_height)
            CGPathMoveToPoint(path, nil, chevron_x - 1, chevron_y + 1)
            CGPathAddLineToPoint(path, nil, chevron_x + chevron_width, chevron_y + chevron_height)
            CGPathCloseSubpath(path)
            CGContextAddPath(ctx, path)
            CGContextStrokePath(ctx)
            
            CGContextSaveGState(ctx)
            
            let text_x = chevron_x - (text_size.width / 2.0)
            let text_y = chevron_y + 5.0 + chevron_height
            let text_rect = CGRectMake(CGFloat(text_x), CGFloat(text_y), text_size.width, text_size.height)
            distanceText.drawInRect(text_rect, withAttributes: textAttributes)
            
        } else if _isBelowCamera() {
            
            let path = CGPathCreateMutable()
            CGPathMoveToPoint(path, nil, chevron_x, chevron_y)
            CGPathAddLineToPoint(path, nil, chevron_x - chevron_width, chevron_y - chevron_height)
            CGPathMoveToPoint(path, nil, chevron_x - 1, chevron_y + 1)
            CGPathAddLineToPoint(path, nil, chevron_x + chevron_width, chevron_y - chevron_height)
            CGPathCloseSubpath(path)
            CGContextAddPath(ctx, path)
            CGContextStrokePath(ctx)
            
            CGContextSaveGState(ctx)
            
            let text_x = chevron_x - (text_size.width / 2.0)
            let text_y = chevron_y - (chevron_height + 5.0 + (text_size.width / 2.0))
            let text_rect = CGRectMake(CGFloat(text_x), CGFloat(text_y), text_size.width, text_size.height)
            distanceText.drawInRect(text_rect, withAttributes: textAttributes)
            
        } else if _isLeftOfCamera() {
            let path = CGPathCreateMutable()
            CGPathMoveToPoint(path, nil, chevron_x, chevron_y)
            CGPathAddLineToPoint(path, nil, chevron_x + chevron_width, chevron_y + chevron_height)
            CGPathMoveToPoint(path, nil, chevron_x - 1, chevron_y + 1)
            CGPathAddLineToPoint(path, nil, chevron_x + chevron_width, chevron_y - chevron_height)
            CGPathCloseSubpath(path)
            CGContextAddPath(ctx, path)
            CGContextStrokePath(ctx)
            
            CGContextSaveGState(ctx)
            
            let text_x = chevron_x + (chevron_width + 10)
            let text_y = chevron_y - (text_size.height / 2.0)
            let text_rect = CGRectMake(CGFloat(text_x), CGFloat(text_y), text_size.width, text_size.height)
            distanceText.drawInRect(text_rect, withAttributes: textAttributes)
            
        } else if _isRightOfCamera() {
            
            let path = CGPathCreateMutable()
            CGPathMoveToPoint(path, nil, chevron_x, chevron_y)
            CGPathAddLineToPoint(path, nil, chevron_x - chevron_width, chevron_y + chevron_height)
            CGPathMoveToPoint(path, nil, chevron_x - 1, chevron_y + 1)
            CGPathAddLineToPoint(path, nil, chevron_x - chevron_width, chevron_y - chevron_height)
            CGPathCloseSubpath(path)
            CGContextAddPath(ctx, path)
            CGContextStrokePath(ctx)
            
            CGContextSaveGState(ctx)
            
            let text_x = chevron_x - (chevron_width + 10 + text_size.width)
            let text_y = chevron_y - (text_size.height / 2.0)
            let text_rect = CGRectMake(CGFloat(text_x), CGFloat(text_y), text_size.width, text_size.height)
            distanceText.drawInRect(text_rect, withAttributes: textAttributes)
        }
        
        if nil != Destination {
            let destination_text = Destination as NSString
            let destination_text_size = destination_text.sizeWithAttributes(textAttributes)
            let destination_text_rect = CGRectMake(CGFloat(10.0), CGFloat(10.0), destination_text_size.width, destination_text_size.height)
            destination_text.drawInRect(destination_text_rect, withAttributes: textAttributes)
        }
    }
}

class RealityViewController: UIThemedViewController, UIGestureRecognizerDelegate, PelorusNavUpdateReceiverDelegate {
    
    var _motionManager: CMMotionManager!
    var _nav: PelorusNav!

    var _navigationShowing = false
    
    var _tapRecognizer : UITapGestureRecognizer!
    
    @IBOutlet var cameraFeedView : CameraFeedView!
    @IBOutlet var interfaceView : InterfaceView!
    
    @IBOutlet var setDestinationButton : UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        _nav = appDelegate.NavManager
        
        _motionManager = CMMotionManager()
        if (_motionManager.accelerometerAvailable) {
            _motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue(), withHandler: MotionUpdate)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        _nav.Receiver = self
        _navigationShowing = true
        
        if nil != _nav.CurrentDestination {
            interfaceView.Destination = _nav.CurrentDestination.Label
        }
        setDestinationButton.enabled = true
    }
    
    override func viewDidAppear(animated: Bool) {
        cameraFeedView.BeginFeed()
    }

    override func didReceiveMemoryWarning() {
        NSLog("Reality View --> Received Memory Warning")
    }
    
    func MotionUpdate(data: CMAccelerometerData!, error: NSError!) {
        if nil != data && nil == error {
            interfaceView.DevicePitch = data.acceleration.z
            interfaceView.DeviceRoll = data.acceleration.x
            interfaceView.setNeedsDisplay()
        }
    }
    
    func HeadingUpdated(sender: PelorusNav) {
        interfaceView.CurrentHeadingError = sender.CurrentHeadingError
        interfaceView.CurrentHeading = sender.CurrentHeading
        interfaceView.CurrentDestinationHeading = sender.CurrentDestinationHeading
        
        if nil != sender.CurrentDistance {
            interfaceView.CurrentDistanceMeters = sender.CurrentDistance.DistanceMeters
        }
        
        interfaceView.setNeedsDisplay()
    }
    
    func LocationUpdated(sender: PelorusNav) {
        interfaceView.CurrentHeadingError = sender.CurrentHeadingError
        interfaceView.CurrentHeading = sender.CurrentHeading
        interfaceView.CurrentDestinationHeading = sender.CurrentDestinationHeading
        
        if nil != sender.CurrentDistance {
            interfaceView.CurrentDistanceMeters = sender.CurrentDistance.DistanceMeters
        }
        
        interfaceView.setNeedsDisplay()
    }
}
    