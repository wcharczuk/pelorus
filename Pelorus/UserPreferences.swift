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
    
    static var SensorSmoothing : Int {
        get {
            let defaults = NSUserDefaults.standardUserDefaults()
            if nil != defaults.objectForKey("units") {
                let value = defaults.integerForKey("sensor_smoothing")
                if value < 1 {
                    return 1
                } else {
                    return value
                }
            } else {
                return Configuration.SENSOR_SMOOTHING
            }
        }
        set(value) {
            
            var newValue = value
            if newValue < 1 {
                newValue = 1
            }
            
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setInteger(newValue, forKey: "sensor_smoothing")
        }
    }
    
    static var ShouldSmoothLocation : Bool {
        get {
            let defaults = NSUserDefaults.standardUserDefaults()
            if nil != defaults.objectForKey("should_smooth_location") {
                return defaults.boolForKey("should_smooth_location")
            } else {
                return Configuration.SHOULD_SMOOTH_LOCATION
            }
        }
        set(value) {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setBool(value, forKey: "should_smooth_location")
        }
    }
    
    static var ShouldSmoothCompass : Bool {
        get {
            let defaults = NSUserDefaults.standardUserDefaults()
            if nil != defaults.objectForKey("should_smooth_compass") {
                return defaults.boolForKey("should_smooth_compass")
            } else {
                return Configuration.SHOULD_SMOOTH_COMPASS
            }
        }
        set(value) {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setBool(value, forKey: "should_smooth_compass")
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