//
//  CompassViewController.swift
//  Pelorus
//
//  Created by Will Charczuk on 11/11/14.
//  Copyright (c) 2014 Will Charczuk. All rights reserved.
//

import UIKit
import CoreGraphics

class CompassViewController: ThemedViewController, PelorusNavUpdateReceiverDelegate {
    
    var _nav: PelorusNav!
    
    @IBOutlet var compassView : CompassView!
    @IBOutlet var setDestinationButton : UIBarButtonItem!
    
    @IBOutlet var destinationText : UILabel!
    var destinationTextTapGesture : UITapGestureRecognizer!
    
    @IBAction func clearDestinationClicked(sender: AnyObject){
        _nav.ClearDestination()
    }
    
    override init() {
        super.init()
    }
    
    override init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _nav = self.appDelegate.NavManager
        
        destinationTextTapGesture = UITapGestureRecognizer()
        destinationTextTapGesture.numberOfTapsRequired = 1
        destinationTextTapGesture.addTarget(self, action: "setDestinationTransition")
        destinationText.addGestureRecognizer(destinationTextTapGesture)
        destinationText.userInteractionEnabled = true
        
        UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleOrientationChange", name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        setDestinationButton.enabled = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        compassView.viewWillAppear(animated)
        
        compassView.interfaceOrientation = self.interfaceOrientation
        
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
    
    func handleOrientationChange() {
        compassView.interfaceOrientation = self.interfaceOrientation
        destinationText.hidden = self.interfaceOrientation == UIInterfaceOrientation.LandscapeLeft || self.interfaceOrientation == UIInterfaceOrientation.LandscapeRight
        compassView.setNeedsDisplay()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setDestinationTransition() {
        self.performSegueWithIdentifier("selectDestinationSegue", sender: self.navigationController)
    }
    
    func headingUpdated(sender: PelorusNav) {
        compassView.CurrentHeading = sender.CurrentHeading
        compassView.CurrentDestinationHeading = sender.CurrentDestinationHeading
        compassView.CurrentHeadingError = sender.CurrentHeadingError
        self.compassView.setNeedsDisplay()
    }
    
    func locationUpdated(sender: PelorusNav) {
        setDestinationButton.enabled = true

        if nil != sender.CurrentDistance {
            compassView.DistanceMeters = sender.CurrentDistance.DistanceMeters
        }
    }
}