//
//  CustomTabBarController.swift
//  Pelorus
//
//  Created by Will Charczuk on 12/30/14.
//  Copyright (c) 2014 Will Charczuk. All rights reserved.
//

import UIKit

class CustomTabBarController : UITabBarController, UITabBarControllerDelegate {

    var forcedOrientation : UIInterfaceOrientationMask?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if let selected = selectedViewController {
            if let navController = selected as? UINavigationController,
               let topVC = navController.topViewController {
                return topVC.supportedInterfaceOrientations
            }
            return selected.supportedInterfaceOrientations
        }
        return .all
    }

    override var shouldAutorotate: Bool {
        return true
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        if let themedViewController = viewController as? ThemedViewController {
            self.forcedOrientation = themedViewController.forcedOrientation
            appDelegate.forcedOrientation = themedViewController.forcedOrientation
        } else if let navController = viewController as? UINavigationController,
                  let themedViewController = navController.viewControllers.first as? ThemedViewController {
            self.forcedOrientation = themedViewController.forcedOrientation
            appDelegate.forcedOrientation = themedViewController.forcedOrientation
        }
    }
}
