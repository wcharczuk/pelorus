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

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var shouldAutorotate: Bool {
        return false
    }

    var _nav: PelorusNav!
    
    @IBOutlet var compassView : CompassView!
    var setDestinationButton : UIBarButtonItem!

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

        forcedOrientation = .portrait
        _nav = self.appDelegate.NavManager

        setDestinationButton = UIBarButtonItem(title: "Set", style: .plain, target: self, action: #selector(setDestinationTransition))
        navigationItem.rightBarButtonItem = setDestinationButton

        destinationTextTapGesture = UITapGestureRecognizer()
        destinationTextTapGesture.numberOfTapsRequired = 1
        destinationTextTapGesture.addTarget(self, action: #selector(CompassViewController.setDestinationTransition))
        destinationText.addGestureRecognizer(destinationTextTapGesture)
        destinationText.isUserInteractionEnabled = true

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
            if nil != _nav.CurrentDestination.Label && nil != _nav.CurrentDestination.SubLabel {
                destinationText.text = "\(_nav.CurrentDestination.Label!)\n\(_nav.CurrentDestination.SubLabel!)"
            } else if nil != _nav.CurrentDestination.Label {
                destinationText.text = "\(_nav.CurrentDestination.Label!)"
            } else {
                destinationText.text = "\(_nav.CurrentDestination.Latitude), \(_nav.CurrentDestination.Longitude)"
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func setDestinationTransition() {
        self.performSegue(withIdentifier: "selectDestinationSegue", sender: self.navigationController)
    }
    
    func headingUpdated(_ sender: PelorusNav) {
        let heading = sender.CurrentHeading
        let destHeading = sender.CurrentDestinationHeading
        let headingError = sender.CurrentHeadingError

        Task { @MainActor in
            self.compassView.CurrentHeading = heading
            self.compassView.CurrentDestinationHeading = destHeading
            self.compassView.CurrentHeadingError = headingError

            self.compassView.setNeedsDisplay()
        }
    }

    func locationUpdated(_ sender: PelorusNav) {
        let distanceMeters = sender.CurrentDistance?.DistanceMeters

        Task { @MainActor in
            self.setDestinationButton.isEnabled = true
            self.compassView.DistanceMeters = distanceMeters
        }
    }
}
