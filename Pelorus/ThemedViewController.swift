//
//  UIThemedViewController.swift
//  Pelorus
//
//  Created by Will Charczuk on 12/16/14.
//  Copyright (c) 2014 Will Charczuk. All rights reserved.
//

import UIKit

class ThemedViewController : UIViewController {

    var appDelegate : AppDelegate!
    var forcedOrientation : UIInterfaceOrientationMask?

    private var _statusBarHidden = false

    override func viewDidLoad() {
        self.appDelegate = UIApplication.shared.delegate as! AppDelegate
        super.viewDidLoad()
    }

    override var prefersStatusBarHidden: Bool {
        return _statusBarHidden
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let currentTheme = Themes.Current
        let isSystemTheme = currentTheme.Id == 5

        self.navigationController?.navigationBar.isTranslucent = false
        self.tabBarController?.tabBar.isTranslucent = false

        // Configure navigation bar appearance
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()

        // Configure tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()

        if isSystemTheme {
            // Use system default colors that adapt to light/dark mode
            navBarAppearance.backgroundColor = UIColor.systemBackground
            tabBarAppearance.backgroundColor = UIColor.systemBackground

            self.navigationController?.navigationBar.barTintColor = nil
            self.tabBarController?.tabBar.barTintColor = nil
            self.navigationController?.navigationBar.tintColor = UIColor.systemBlue
            self.tabBarController?.tabBar.tintColor = UIColor.systemBlue

            self.view.window?.backgroundColor = UIColor.systemBackground

            _statusBarHidden = false
            setNeedsStatusBarAppearanceUpdate()
        } else if let menubarBgColor = currentTheme.MenubarBackgroundColor {
            navBarAppearance.backgroundColor = menubarBgColor
            tabBarAppearance.backgroundColor = menubarBgColor

            self.navigationController?.navigationBar.barTintColor = menubarBgColor
            self.tabBarController?.tabBar.barTintColor = menubarBgColor

            self.view.window?.backgroundColor = menubarBgColor

            _statusBarHidden = true
            setNeedsStatusBarAppearanceUpdate()

            if let menubarFontColor = currentTheme.MenubarFontColor {
                let textAttributes : [NSAttributedString.Key: Any] = [
                    .foregroundColor : menubarFontColor
                ]
                navBarAppearance.titleTextAttributes = textAttributes
                self.navigationController?.navigationBar.tintColor = menubarFontColor
                self.tabBarController?.tabBar.tintColor = menubarFontColor
            }
        } else {
            navBarAppearance.backgroundColor = UIColor.systemBackground
            tabBarAppearance.backgroundColor = UIColor.systemBackground

            self.navigationController?.navigationBar.barTintColor = nil
            self.tabBarController?.tabBar.barTintColor = nil
            self.navigationController?.navigationBar.tintColor = nil
            self.tabBarController?.tabBar.tintColor = nil

            self.view.window?.backgroundColor = UIColor.systemBackground

            _statusBarHidden = false
            setNeedsStatusBarAppearanceUpdate()
        }

        // Apply the appearances
        self.navigationController?.navigationBar.standardAppearance = navBarAppearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        self.tabBarController?.tabBar.standardAppearance = tabBarAppearance
        self.tabBarController?.tabBar.scrollEdgeAppearance = tabBarAppearance
    }
}
