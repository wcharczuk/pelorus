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

    override func viewDidLoad() {
        self.appDelegate = UIApplication.shared.delegate as! AppDelegate
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.tabBarController?.tabBar.isTranslucent = false
        
        if nil != Themes.Current.MenubarBackgroundColor {
            self.navigationController?.navigationBar.barTintColor = Themes.Current.MenubarBackgroundColor!
            self.tabBarController?.tabBar.barTintColor = Themes.Current.MenubarBackgroundColor!
            
            UIApplication.shared.setStatusBarHidden(true, with: UIStatusBarAnimation.none)
        } else {
            
            self.navigationController?.navigationBar.barTintColor = nil
            self.tabBarController?.tabBar.barTintColor = nil
            UIApplication.shared.setStatusBarHidden(false, with: UIStatusBarAnimation.none)
        }
        
        if nil != Themes.Current.MenubarFontColor {
            let color = Themes.Current.MenubarFontColor!
            let textAttributes : [String: Any]? = [
                NSForegroundColorAttributeName : color
            ]
            
            self.navigationController?.navigationBar.titleTextAttributes = textAttributes
            self.navigationController?.navigationBar.tintColor = color

            self.tabBarController?.tabBar.tintColor = color

        } else {
            self.navigationController?.navigationBar.titleTextAttributes = nil
            self.navigationController?.navigationBar.tintColor = nil
            
            self.tabBarController?.tabBar.tintColor = nil
        }
    }
}
