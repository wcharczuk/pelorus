//
//  UIThemedViewController.swift
//  Pelorus
//
//  Created by Will Charczuk on 12/16/14.
//  Copyright (c) 2014 Will Charczuk. All rights reserved.
//

import UIKit

class UIThemedViewController : UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return Themes.Current.MenubarBackgroundColor != nil
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.translucent = false
        self.tabBarController?.tabBar.translucent = false
        
        if nil != Themes.Current.MenubarBackgroundColor {
            self.navigationController?.navigationBar.barTintColor = Themes.Current.MenubarBackgroundColor!
            self.tabBarController?.tabBar.barTintColor = Themes.Current.MenubarBackgroundColor!
        } else {
            
            self.navigationController?.navigationBar.barTintColor = nil
            self.tabBarController?.tabBar.barTintColor = nil
            
        }
        
        if nil != Themes.Current.MenubarFontColor {
            let color = Themes.Current.MenubarFontColor!
            let textAttributes : Dictionary<NSObject, AnyObject> = [
                NSForegroundColorAttributeName : color as AnyObject
            ]
            
            self.navigationController?.navigationBar.titleTextAttributes = textAttributes
            self.navigationController?.navigationBar.tintColor = color

            self.tabBarController?.tabBar.selectedImageTintColor = color
            self.tabBarController?.tabBar.tintColor = color

        } else {
            self.navigationController?.navigationBar.titleTextAttributes = nil
            self.navigationController?.navigationBar.tintColor = nil
            
            self.tabBarController?.tabBar.selectedImageTintColor = nil
            self.tabBarController?.tabBar.tintColor = nil
        }
    }
}
