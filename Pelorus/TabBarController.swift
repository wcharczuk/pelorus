//
//  OrientationAwareTabBarController.swift
//  Pelorus
//
//  Created by Will Charczuk on 12/30/14.
//  Copyright (c) 2014 Will Charczuk. All rights reserved.
//

import UIKit

class TabBarController : UITabBarController {
    
    var appDelegate : AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate

    func _setAppOrientation(orientationMask: UIInterfaceOrientationMask) {
        self.appDelegate.ForcedOrientation = orientationMask
    }
}
