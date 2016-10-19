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
    
    @IBAction func clearDestinationClicked(_ sender: AnyObject){
        _nav.ClearDestination()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _nav = self.appDelegate.NavManager
        
        destinationTextTapGesture = UITapGestureRecognizer()
        destinationTextTapGesture.numberOfTapsRequired = 1
        destinationTextTapGesture.addTarget(self, action: #selector(CompassViewController.setDestinationTransition))
        destinationText.addGestureRecognizer(destinationTextTapGesture)
        destinationText.isUserInteractionEnabled = true
        
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(CompassViewController.handleOrientationChange), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        setDestinationButton.isEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
    
    func handleOrientationChange() {
        compassView.setNeedsDisplay()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setDestinationTransition() {
        self.performSegue(withIdentifier: "selectDestinationSegue", sender: self.navigationController)
    }
    
    func headingUpdated(_ sender: PelorusNav) {
        compassView.CurrentHeading = sender.CurrentHeading
        compassView.CurrentDestinationHeading = sender.CurrentDestinationHeading
        compassView.CurrentHeadingError = sender.CurrentHeadingError
        
        self.compassView.setNeedsDisplay()
    }
    
    func locationUpdated(_ sender: PelorusNav) {
        setDestinationButton.isEnabled = true

        if nil != sender.CurrentDistance {
            compassView.DistanceMeters = sender.CurrentDistance.DistanceMeters
        } else {
            compassView.DistanceMeters = nil
        }
    }
}
