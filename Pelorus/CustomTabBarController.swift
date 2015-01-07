//
//  CustomTabBarController.swift
//  Pelorus
//
//  Created by Will Charczuk on 12/30/14.
//  Copyright (c) 2014 Will Charczuk. All rights reserved.
//

import UIKit

class CustomTabBarController : UITabBarController, UITabBarControllerDelegate {
    
    override init() {
        super.init()
        self.delegate = self
    }
    
    var forcedOrientation : UIInterfaceOrientationMask!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self
    }
    
    override func supportedInterfaceOrientations() -> Int {
        if nil != self.forcedOrientation {
            return Int(self.forcedOrientation.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        let themed_view_controller = viewController as? ThemedViewController
        let app_delegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        if nil != themed_view_controller {
            self.forcedOrientation = themed_view_controller!.forcedOrientation
            app_delegate.forcedOrientation = themed_view_controller!.forcedOrientation
        } else {
            let nav_controller = viewController as? UINavigationController
            
            if nil != nav_controller {
                let themed_view_controller_sub = nav_controller!.viewControllers.first as? ThemedViewController
                if nil != themed_view_controller_sub {
                    self.forcedOrientation = themed_view_controller_sub!.forcedOrientation
                    app_delegate.forcedOrientation = themed_view_controller_sub!.forcedOrientation
                }
            }
        }
    }
}
