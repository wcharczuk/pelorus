//
//  GpsManager.swift
//  Pelorus
//
//  Created by Will Charczuk on 1/6/15.
//  Copyright (c) 2015 Will Charczuk. All rights reserved.
//

import UIKit
import CoreData

struct CurrentDestinationDataManager {
    
    static func Fetch() -> GPS! {
        let defaults = UserDefaults.standard
        if nil != defaults.object(forKey: "current_destination") {
            return defaults.object(forKey: "current_destination") as! GPS
        }
        return nil
    }
    
    static func Save(_ destination: GPS!) {
        let defaults = UserDefaults.standard
        defaults.set(destination, forKey: "current_destination")
    }
    
    static func Purge() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "current_destination")
    }
    
}
