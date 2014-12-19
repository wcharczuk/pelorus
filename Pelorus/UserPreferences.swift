//
//  UserPreferences.swift
//  Pelorus
//
//  Created by Will Charczuk on 12/13/14.
//  Copyright (c) 2014 Will Charczuk. All rights reserved.
//

import Foundation

struct UserPreferences {
    
    static var UseMetric : Bool {
        get {
            let defaults = NSUserDefaults.standardUserDefaults()
            if nil != defaults.objectForKey("units") {
                return defaults.boolForKey("units")
            } else {
                return Configuration.UNITS_USE_METRIC
            }
        }
        set(value) {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setBool(value, forKey: "units")
        }
    }
    
    static var CompassSmoothing : Int {
        get {
            let defaults = NSUserDefaults.standardUserDefaults()
            if nil != defaults.objectForKey("units") {
                let value = defaults.integerForKey("compass_smoothing")
                if value < 1 {
                    return 1
                } else {
                    return value
                }
            } else {
                return Configuration.COMPASS_SMOOTHING
            }
        }
        set(value) {
            
            var newValue = value
            if newValue < 1 {
                newValue = 1
            }
            
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setInteger(newValue, forKey: "compass_smoothing")
        }
    }
    
    static var Theme : Int {
        get {
            let defaults = NSUserDefaults.standardUserDefaults()
            if nil != defaults.objectForKey("theme") {
                return defaults.integerForKey("theme")
            } else {
                return Configuration.THEME
            }
        }
        set(value) {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setInteger(value, forKey: "theme")
        }
    }
}