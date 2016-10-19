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

class CameraFeedView : GraphicsView {
    
    var _session : AVCaptureSession!
    var _captureDevice : AVCaptureDevice!
    var _previewLayer : AVCaptureVideoPreviewLayer!
    
    func beginFeed() {
        
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(CameraFeedView.handleOrientationChange), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        _session = AVCaptureSession()
        _session.sessionPreset = AVCaptureSessionPresetPhoto
        
        let devices = AVCaptureDevice.devices()
        for device in devices! {
            // Make sure this particular device supports video
            if ((device as AnyObject).hasMediaType(AVMediaTypeVideo)) {
                if((device as AnyObject).position == AVCaptureDevicePosition.back) {
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
                device.focusMode = .continuousAutoFocus
                device.unlockForConfiguration()
            }
            
            if !_session.isRunning {
                _session.startRunning()
            }
            
            handleOrientationChange()
        }
    }
    
    func handleOrientationChange() {
        
        let frame_bounds = self.bounds
        _previewLayer.frame = frame_bounds
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        _previewLayer.contentsGravity = kCAGravityResizeAspectFill
        _previewLayer.position = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        
        let orientation = UIDevice.current.orientation
        
        switch(orientation) {
            case UIDeviceOrientation.landscapeLeft:
                _previewLayer.connection.videoOrientation = AVCaptureVideoOrientation.landscapeRight
            case UIDeviceOrientation.landscapeRight:
                _previewLayer.connection.videoOrientation = AVCaptureVideoOrientation.landscapeLeft
            case UIDeviceOrientation.portrait:
                _previewLayer.connection.videoOrientation = AVCaptureVideoOrientation.portrait
            case UIDeviceOrientation.portraitUpsideDown:
                _previewLayer.connection.videoOrientation = AVCaptureVideoOrientation.portraitUpsideDown
            default:
                _previewLayer.connection.videoOrientation = AVCaptureVideoOrientation.landscapeLeft
        }
    }
}

class InterfaceView : GraphicsView {
    
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
    
    var chevronPointQueue : FixedQueue<(CGFloat, CGFloat)>!
    
    func averagePoints( _ newPoint: (CGFloat, CGFloat) ) -> (CGFloat, CGFloat) {
        
        if nil == chevronPointQueue {
            chevronPointQueue = FixedQueue<(CGFloat, CGFloat)>( maxLength: 5 )
        }
        
        chevronPointQueue.Enqueue( newPoint )
        
        var avg_x = CGFloat(0.0)
        var avg_y = CGFloat(0.0)
        
        for point in chevronPointQueue.ToList() {
            avg_x = avg_x + point.0
            avg_y = avg_y + point.1
        }
        
        return (avg_x / CGFloat(chevronPointQueue.Length), avg_y / CGFloat(chevronPointQueue.Length))
    }
    
    func calculateChevronPosition() {
        
        let bounds = self.bounds
        
        let aspect = CGFloat(bounds.size.width / bounds.size.height)
        
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
    
    override func draw(_ rect: CGRect) {
        
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
            NSFontAttributeName as NSObject : font as AnyObject,
            NSForegroundColorAttributeName as NSObject : primary_color as AnyObject,
        ]
        
        let min_dim = min(bounds.size.height, bounds.size.width)
        let max_dim = max(bounds.size.height, bounds.size.width)
        
        let chevron_max_height = min_dim / 4.0
        let chevron_max_width = max_dim / 4.0
        
        let chevron_height = chevron_max_height / 2.0
        let chevron_width = chevron_max_height / 2.0
        
        ctx?.saveGState()
        ctx?.setLineWidth(3)
        ctx?.setStrokeColor(primary_color.cgColor)
        
        let distanceText = CompassUtil.FormatDistance(self.CurrentDistanceMeters) as NSString
        let text_size = distanceText.sizeWithAttributes(textAttributes)

        if _isInView() {

            let path = CGMutablePath()
            CGPathMoveToPoint(path, nil, chevron_x, chevron_y)
            CGPathAddLineToPoint(path, nil, chevron_x - chevron_width, chevron_y - chevron_height)
            CGPathMoveToPoint(path, nil, chevron_x - 1, chevron_y + 1)
            CGPathAddLineToPoint(path, nil, chevron_x + chevron_width, chevron_y - chevron_height)
            path.closeSubpath()
            ctx?.addPath(path)
            ctx?.strokePath()
            
            ctx?.saveGState()
            let text_x = chevron_x - (text_size.width / 2.0)
            let text_y = chevron_y + 5.0
            let text_rect = CGRect(x: CGFloat(text_x), y: CGFloat(text_y), width: text_size.width, height: text_size.height)
            distanceText.drawInRect(text_rect, withAttributes: textAttributes)
            
        } else if _isAboveCamera() {

            let path = CGMutablePath()
            CGPathMoveToPoint(path, nil, chevron_x, chevron_y)
            CGPathAddLineToPoint(path, nil, chevron_x - chevron_width, chevron_y + chevron_height)
            CGPathMoveToPoint(path, nil, chevron_x - 1, chevron_y + 1)
            CGPathAddLineToPoint(path, nil, chevron_x + chevron_width, chevron_y + chevron_height)
            path.closeSubpath()
            ctx?.addPath(path)
            ctx?.strokePath()
            
            ctx?.saveGState()
            
            let text_x = chevron_x - (text_size.width / 2.0)
            let text_y = chevron_y + 5.0 + chevron_height
            let text_rect = CGRect(x: CGFloat(text_x), y: CGFloat(text_y), width: text_size.width, height: text_size.height)
            distanceText.drawInRect(text_rect, withAttributes: textAttributes)
            
        } else if _isBelowCamera() {
            
            let path = CGMutablePath()
            CGPathMoveToPoint(path, nil, chevron_x, chevron_y)
            CGPathAddLineToPoint(path, nil, chevron_x - chevron_width, chevron_y - chevron_height)
            CGPathMoveToPoint(path, nil, chevron_x - 1, chevron_y + 1)
            CGPathAddLineToPoint(path, nil, chevron_x + chevron_width, chevron_y - chevron_height)
            path.closeSubpath()
            ctx?.addPath(path)
            ctx?.strokePath()
            
            ctx?.saveGState()
            
            let text_x = chevron_x - (text_size.width / 2.0)
            let text_y = chevron_y - (chevron_height + 5.0 + (text_size.width / 2.0))
            let text_rect = CGRect(x: CGFloat(text_x), y: CGFloat(text_y), width: text_size.width, height: text_size.height)
            distanceText.drawInRect(text_rect, withAttributes: textAttributes)
            
        } else if _isLeftOfCamera() {
            let path = CGMutablePath()
            CGPathMoveToPoint(path, nil, chevron_x, chevron_y)
            CGPathAddLineToPoint(path, nil, chevron_x + chevron_width, chevron_y + chevron_height)
            CGPathMoveToPoint(path, nil, chevron_x - 1, chevron_y + 1)
            CGPathAddLineToPoint(path, nil, chevron_x + chevron_width, chevron_y - chevron_height)
            path.closeSubpath()
            ctx?.addPath(path)
            ctx?.strokePath()
            
            ctx?.saveGState()
            
            let text_x = chevron_x + (chevron_width + 10)
            let text_y = chevron_y - (text_size.height / 2.0)
            let text_rect = CGRect(x: CGFloat(text_x), y: CGFloat(text_y), width: text_size.width, height: text_size.height)
            distanceText.drawInRect(text_rect, withAttributes: textAttributes)
            
        } else if _isRightOfCamera() {
            
            let path = CGMutablePath()
            CGPathMoveToPoint(path, nil, chevron_x, chevron_y)
            CGPathAddLineToPoint(path, nil, chevron_x - chevron_width, chevron_y + chevron_height)
            CGPathMoveToPoint(path, nil, chevron_x - 1, chevron_y + 1)
            CGPathAddLineToPoint(path, nil, chevron_x - chevron_width, chevron_y - chevron_height)
            path.closeSubpath()
            ctx?.addPath(path)
            ctx?.strokePath()
            
            ctx?.saveGState()
            
            let text_x = chevron_x - (chevron_width + 10 + text_size.width)
            let text_y = chevron_y - (text_size.height / 2.0)
            let text_rect = CGRect(x: CGFloat(text_x), y: CGFloat(text_y), width: text_size.width, height: text_size.height)
            distanceText.drawInRect(text_rect, withAttributes: textAttributes)
        }
        
        if nil != Destination {
            let destination_text = Destination as NSString
            let destination_text_size = destination_text.sizeWithAttributes(textAttributes)
            let destination_text_rect = CGRect(x: CGFloat(10.0), y: CGFloat(10.0), width: destination_text_size.width, height: destination_text_size.height)
            destination_text.drawInRect(destination_text_rect, withAttributes: textAttributes)
        }
    }
}

class CameraViewController: ThemedViewController, UIGestureRecognizerDelegate, PelorusNavUpdateReceiverDelegate {
    
    var _motionManager: CMMotionManager!
    var _nav: PelorusNav!

    var _navigationShowing = false
    
    var _tapRecognizer : UITapGestureRecognizer!
    
    @IBOutlet var cameraFeedView : CameraFeedView!
    @IBOutlet var interfaceView : InterfaceView!
    
    @IBOutlet var setDestinationButton : UIBarButtonItem!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _nav = self.appDelegate.NavManager
        
        _motionManager = CMMotionManager()
        if (_motionManager.isAccelerometerAvailable) {
            _motionManager.startAccelerometerUpdates(to: OperationQueue(), withHandler: motionUpdate as! CMAccelerometerHandler)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        _nav.Receiver = self
        _navigationShowing = true
        
        if nil != _nav.CurrentDestination {
            interfaceView.Destination = _nav.CurrentDestination.Label
        }
        
        setDestinationButton.isEnabled = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        cameraFeedView.beginFeed()
    }

    override func didReceiveMemoryWarning() {
        if nil != _motionManager {
            _motionManager.stopDeviceMotionUpdates()
        }
    }
    
    func motionUpdate(_ data: CMAccelerometerData!, error: NSError!) {
        if nil != data && nil == error {
            interfaceView.DevicePitch = data.acceleration.z
            interfaceView.DeviceRoll = data.acceleration.x
            interfaceView.setNeedsDisplay()
        }
    }
    
    func headingUpdated(_ sender: PelorusNav) {
        interfaceView.CurrentHeadingError = sender.CurrentHeadingError
        interfaceView.CurrentHeading = sender.CurrentHeading
        interfaceView.CurrentDestinationHeading = sender.CurrentDestinationHeading
        
        if nil != sender.CurrentDistance {
            interfaceView.CurrentDistanceMeters = sender.CurrentDistance.DistanceMeters
        }
        
        interfaceView.setNeedsDisplay()
    }
    
    func locationUpdated(_ sender: PelorusNav) {
        interfaceView.CurrentHeadingError = sender.CurrentHeadingError
        interfaceView.CurrentHeading = sender.CurrentHeading
        interfaceView.CurrentDestinationHeading = sender.CurrentDestinationHeading
        
        if nil != sender.CurrentDistance {
            interfaceView.CurrentDistanceMeters = sender.CurrentDistance.DistanceMeters
        }
        
        interfaceView.setNeedsDisplay()
    }
}
    
