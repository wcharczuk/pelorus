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
        NotificationCenter.default.addObserver(self, selector: #selector(CameraFeedView.handleOrientationChange), name: UIDevice.orientationDidChangeNotification, object: nil)

        _session = AVCaptureSession()
        _session.sessionPreset = .photo

        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back)
        if let device = discoverySession.devices.first {
            _captureDevice = device
        }

        if _captureDevice != nil {
            do {
                try _session.addInput(AVCaptureDeviceInput(device: _captureDevice))
            } catch {
                NSLog("Failed to add capture device input: \(error.localizedDescription)")
                return
            }

            _previewLayer = AVCaptureVideoPreviewLayer(session: _session)
            _previewLayer.videoGravity = .resizeAspectFill
            self.layer.addSublayer(_previewLayer)

            if let device = _captureDevice {
                do {
                    try device.lockForConfiguration()
                    device.focusMode = .continuousAutoFocus
                    device.unlockForConfiguration()
                } catch {
                    NSLog("Failed to lock device for configuration: \(error.localizedDescription)")
                }
            }

            if !_session.isRunning {
                _session.startRunning()
            }

            updatePreviewLayerFrame()
            updatePreviewLayerOrientation()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updatePreviewLayerFrame()
    }

    func updatePreviewLayerFrame() {
        guard _previewLayer != nil else { return }
        _previewLayer.frame = self.bounds
    }

    @objc func handleOrientationChange() {
        updatePreviewLayerOrientation()
    }

    func updatePreviewLayerOrientation() {
        guard _previewLayer != nil else { return }

        let orientation = UIDevice.current.orientation

        switch(orientation) {
            case .landscapeLeft:
                _previewLayer.connection?.videoRotationAngle = 0
            case .landscapeRight:
                _previewLayer.connection?.videoRotationAngle = 180
            case .portrait:
                _previewLayer.connection?.videoRotationAngle = 90
            case .portraitUpsideDown:
                _previewLayer.connection?.videoRotationAngle = 270
            default:
                _previewLayer.connection?.videoRotationAngle = 90
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
        
        let textAttributes : [NSAttributedString.Key : Any] = [
            .font : font,
            .foregroundColor: primary_color,
        ]
        
        let min_dim = min(bounds.size.height, bounds.size.width)
        
        let chevron_max_height = min_dim / 4.0
        
        let chevron_height = chevron_max_height / 2.0
        let chevron_width = chevron_max_height / 2.0
        
        ctx?.saveGState()
        ctx?.setLineWidth(3)
        ctx?.setStrokeColor(primary_color.cgColor)
        
        let distanceText = CompassUtil.FormatDistance(self.CurrentDistanceMeters) as NSString
        let text_size = distanceText.size(withAttributes: textAttributes)

        if _isInView() {

            let path = CGMutablePath()
            
            path.move(to: CGPoint(x: chevron_x, y: chevron_y))
            path.addLine(to: CGPoint(x: chevron_x - chevron_width, y: chevron_y - chevron_height))
            path.move(to: CGPoint(x: chevron_x-1, y: chevron_y+1))
            path.addLine(to: CGPoint(x: chevron_x + chevron_width, y: chevron_y - chevron_height))
            
            path.closeSubpath()
            ctx?.addPath(path)
            ctx?.strokePath()
            
            ctx?.saveGState()
            let text_x = chevron_x - (text_size.width / 2.0)
            let text_y = chevron_y + 5.0
            let text_rect = CGRect(x: CGFloat(text_x), y: CGFloat(text_y), width: text_size.width, height: text_size.height)
            distanceText.draw(in: text_rect, withAttributes: textAttributes)
            
        } else if _isAboveCamera() {

            let path = CGMutablePath()
            
            path.move(to: CGPoint(x: chevron_x, y: chevron_y))
            path.addLine(to: CGPoint(x: chevron_x - chevron_width, y: chevron_y + chevron_height))
            path.move(to: CGPoint(x: chevron_x-1, y: chevron_y+1))
            path.addLine(to: CGPoint(x: chevron_x + chevron_width, y: chevron_y + chevron_height))
            
            path.closeSubpath()
            ctx?.addPath(path)
            ctx?.strokePath()
            
            ctx?.saveGState()
            
            let text_x = chevron_x - (text_size.width / 2.0)
            let text_y = chevron_y + 5.0 + chevron_height
            let text_rect = CGRect(x: CGFloat(text_x), y: CGFloat(text_y), width: text_size.width, height: text_size.height)
            distanceText.draw(in: text_rect, withAttributes: textAttributes)
            
        } else if _isBelowCamera() {
            
            let path = CGMutablePath()
            
            path.move(to: CGPoint(x: chevron_x, y: chevron_y))
            path.addLine(to: CGPoint(x: chevron_x - chevron_width, y: chevron_y - chevron_height))
            path.move(to: CGPoint(x: chevron_x-1, y: chevron_y+1))
            path.addLine(to: CGPoint(x: chevron_x + chevron_width, y: chevron_y - chevron_height))
            
            path.closeSubpath()
            ctx?.addPath(path)
            ctx?.strokePath()
            
            ctx?.saveGState()
            
            let text_x = chevron_x - (text_size.width / 2.0)
            let text_y = chevron_y - (chevron_height + 5.0 + (text_size.width / 2.0))
            let text_rect = CGRect(x: CGFloat(text_x), y: CGFloat(text_y), width: text_size.width, height: text_size.height)
            distanceText.draw(in: text_rect, withAttributes: textAttributes)
            
        } else if _isLeftOfCamera() {
            let path = CGMutablePath()
            
            path.move(to: CGPoint(x: chevron_x, y: chevron_y))
            path.addLine(to: CGPoint(x: chevron_x + chevron_width, y: chevron_y + chevron_height))
            path.move(to: CGPoint(x: chevron_x-1, y: chevron_y+1))
            path.addLine(to: CGPoint(x: chevron_x + chevron_width, y: chevron_y - chevron_height))
            
            path.closeSubpath()
            ctx?.addPath(path)
            ctx?.strokePath()
            
            ctx?.saveGState()
            
            let text_x = chevron_x + (chevron_width + 10)
            let text_y = chevron_y - (text_size.height / 2.0)
            let text_rect = CGRect(x: CGFloat(text_x), y: CGFloat(text_y), width: text_size.width, height: text_size.height)
            distanceText.draw(in: text_rect, withAttributes: textAttributes)
            
        } else if _isRightOfCamera() {
            
            let path = CGMutablePath()
            
            path.move(to: CGPoint(x: chevron_x, y: chevron_y))
            path.addLine(to: CGPoint(x: chevron_x - chevron_width, y: chevron_y + chevron_height))
            path.move(to: CGPoint(x: chevron_x-1, y: chevron_y+1))
            path.addLine(to: CGPoint(x: chevron_x + chevron_width, y: chevron_y - chevron_height))
            
            path.closeSubpath()
            ctx?.addPath(path)
            ctx?.strokePath()
            
            ctx?.saveGState()
            
            let text_x = chevron_x - (chevron_width + 10 + text_size.width)
            let text_y = chevron_y - (text_size.height / 2.0)
            let text_rect = CGRect(x: CGFloat(text_x), y: CGFloat(text_y), width: text_size.width, height: text_size.height)
            distanceText.draw(in: text_rect, withAttributes: textAttributes)
        }
        
        if nil != Destination {
            let destination_text = Destination as NSString
            let destination_text_size = destination_text.size(withAttributes: textAttributes)
            let destination_text_rect = CGRect(x: CGFloat(10.0), y: CGFloat(10.0), width: destination_text_size.width, height: destination_text_size.height)
            destination_text.draw(in: destination_text_rect, withAttributes: textAttributes)
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

    var setDestinationButton : UIBarButtonItem!

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        _nav = self.appDelegate.NavManager

        setDestinationButton = UIBarButtonItem(title: "Set", style: .plain, target: self, action: #selector(setDestinationTransition))
        navigationItem.rightBarButtonItem = setDestinationButton

        _motionManager = CMMotionManager()
        if (_motionManager.isAccelerometerAvailable) {
            _motionManager.startAccelerometerUpdates(to: OperationQueue(), withHandler: motionUpdate)
        }

        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(handleOrientationChange), name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    @objc func handleOrientationChange() {
        interfaceView.setNeedsDisplay()
    }

    // Adjust heading for landscape orientation (camera view rotates with device)
    func adjustHeadingForOrientation(_ heading: Double?) -> Double? {
        guard let heading = heading else { return nil }

        let orientation = UIDevice.current.orientation
        if orientation == .landscapeLeft || orientation == .landscapeRight {
            var adjusted = heading + 90.0
            if adjusted > 360.0 {
                adjusted = adjusted - 360.0
            }
            return adjusted
        }
        return heading
    }

    @objc func setDestinationTransition() {
        self.performSegue(withIdentifier: "selectDestinationSegue", sender: self.navigationController)
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
    
    func motionUpdate(_ data: CMAccelerometerData?, error: Error?) {
        if nil != data && nil == error {
            let pitch = data?.acceleration.z
            let roll = data?.acceleration.x

            Task { @MainActor in
                self.interfaceView.DevicePitch = pitch
                self.interfaceView.DeviceRoll = roll
                self.interfaceView.setNeedsDisplay()
            }
        }
    }

    func headingUpdated(_ sender: PelorusNav) {
        let currentHeading = sender.CurrentHeading
        let destHeading = sender.CurrentDestinationHeading
        let headingError = sender.CurrentHeadingError
        let distanceMeters = sender.CurrentDistance?.DistanceMeters

        Task { @MainActor in
            let adjustedHeading = self.adjustHeadingForOrientation(currentHeading)
            self.interfaceView.CurrentHeading = adjustedHeading

            // Recalculate heading error with adjusted heading
            if let heading = adjustedHeading, let dest = destHeading {
                self.interfaceView.CurrentHeadingError = CompassUtil.CalculateBearingDifference(heading, dest)
            } else {
                self.interfaceView.CurrentHeadingError = headingError
            }

            self.interfaceView.CurrentDestinationHeading = destHeading
            self.interfaceView.CurrentDistanceMeters = distanceMeters

            self.interfaceView.setNeedsDisplay()
        }
    }

    func locationUpdated(_ sender: PelorusNav) {
        let currentHeading = sender.CurrentHeading
        let destHeading = sender.CurrentDestinationHeading
        let headingError = sender.CurrentHeadingError
        let distanceMeters = sender.CurrentDistance?.DistanceMeters

        Task { @MainActor in
            let adjustedHeading = self.adjustHeadingForOrientation(currentHeading)
            self.interfaceView.CurrentHeading = adjustedHeading

            // Recalculate heading error with adjusted heading
            if let heading = adjustedHeading, let dest = destHeading {
                self.interfaceView.CurrentHeadingError = CompassUtil.CalculateBearingDifference(heading, dest)
            } else {
                self.interfaceView.CurrentHeadingError = headingError
            }

            self.interfaceView.CurrentDestinationHeading = destHeading
            self.interfaceView.CurrentDistanceMeters = distanceMeters

            self.interfaceView.setNeedsDisplay()
        }
    }
}
    
