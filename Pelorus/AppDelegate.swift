 //
//  AppDelegate.swift
//  Pelorus
//
//  Created by Will Charczuk on 11/11/14.
//  Copyright (c) 2014 Will Charczuk. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UITabBarControllerDelegate {

    var window: UIWindow?
    fileprivate var _managedObjectModel: NSManagedObjectModel!
    
    var forcedOrientation : UIInterfaceOrientationMask!
    
    var NavManager: PelorusNav!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        if nil == NavManager {
            NavManager = PelorusNav(appDelegate: self)
            NavManager.Start()
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        if nil == NavManager {
            NavManager.Stop()
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        if nil == NavManager {
            NavManager.Start()
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:
        if nil == NavManager {
            NavManager.Stop()
        }
    }
    
    private func application(_ application: UIApplication, supportedInterfaceOrientationsForWindow window: UIWindow?) -> Int {
        if nil != forcedOrientation {
            return Int(forcedOrientation.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.all.rawValue)
        }
    }
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "InverseTechnologies.COREDATUMS" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1] 
        }()
}

