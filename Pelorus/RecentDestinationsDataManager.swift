//
//  RecentDestinationsDataManager.swift
//  Pelorus
//
//  Created by Will Charczuk on 1/6/15.
//  Copyright (c) 2015 Will Charczuk. All rights reserved.
//

import UIKit

struct RecentDestinationsDataManager {
    
    static func Fetch() -> Array<GPS> {
        let defaults = UserDefaults.standard
        if nil != defaults.object(forKey: "recent_destinations") {
            return defaults.object(forKey: "recent_destinations") as! Array<GPS>
        }
        return Array<GPS>()
    }
    
    static func AddNew(_ destination : GPS) {
        let defaults = UserDefaults.standard
        var recents : Array<GPS>
        if nil != defaults.object(forKey: "recent_destinations") {
            recents = defaults.object(forKey: "recent_destinations") as! Array<GPS>
        } else {
            recents = Array<GPS>()
        }
        recents.append(destination)
        defaults.set(recents, forKey:"recent_destinations")
    }
    
    static func Purge() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "recent_destinations")
    }

}
