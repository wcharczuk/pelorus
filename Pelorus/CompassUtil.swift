//
//  CompassMath.swift
//  Pelorus
//
//  Created by Will Charczuk on 12/29/14.
//  Copyright (c) 2014 Will Charczuk. All rights reserved.
//

import Foundation

struct CompassUtil {
    
    //Uses user preferences to format a distance in appropriate major / minor units.
    static func FormatDistance(distanceInMeters: Double) -> String {
        if UserPreferences.UseMetric {
            if(distanceInMeters > 1000) {
                return String(NSString(format:"%.2f km", distanceInMeters / 1000.0))
            } else {
                return String(NSString(format:"%.2f m", distanceInMeters))
            }
        } else {
            let distanceInMiles = distanceInMeters / 1609.34
            let distanceInFeet = distanceInMeters * 3.28084
            if distanceInFeet > 1000.0 {
                return String(NSString(format:"%.2f mi", distanceInFeet / 5280.0))
            } else if distanceInFeet > 5280.0 {
                return String(NSString(format:"%.2f mi", distanceInMiles))
            } else {
                return String(NSString(format:"%.2f ft", distanceInFeet))
            }
        }
    }
    
    //Uses the Haversine formula to work with the curvature of the earth etc.
    static func CalculateDistanceMeters(#point1: GPS, point2: GPS) -> Double {
        
        var R : Double = 6371 * 1000; //meters
        
        let theta_1 = ToRadians(point1.Latitude)
        let theta_2 = ToRadians(point2.Latitude)
        
        let d_theta = ToRadians(abs(point1.Latitude - point2.Latitude))
        let d_lambda = ToRadians(abs(point1.Longitude - point2.Longitude))
        
        let a = (sin(d_theta / 2.0) * sin(d_theta / 2))
            + (cos(theta_1) * cos(theta_2) * sin(d_lambda / 2.0) * sin(d_lambda / 2.0))
        let c = 2 * atan2(sqrt(a), sqrt(1.0 - a))
        
        return R * c
    }
    
    static func CalculateElevationAngle(#point1: GPS, point2: GPS) -> Double {
        let d = CalculateDistanceMeters(point1: point1, point2: point2)
        
        let delta_elev = point1.Elevation - point2.Elevation
        
        return sin(delta_elev / d)
    }
    
    //Again, uses orthodrome path to determine bearing
    static func CalculateCompassHeading(#point1: GPS, point2: GPS) -> Double {
        let theta_1 = ToRadians(point1.Latitude)
        let theta_2 = ToRadians(point2.Latitude)
        
        let lambda_1 = ToRadians(point1.Longitude)
        let lambda_2 = ToRadians(point2.Longitude)
        
        let y = sin(lambda_2 - lambda_1) * cos(theta_2)
        let x = (cos(theta_1) * sin(theta_2))
            - (sin(theta_1) * cos(theta_2) * cos(lambda_2 - lambda_1))
        
        let heading = ToDegrees(atan2(y, x))
        
        if heading < 0 {
            return heading + 360
        } else {
            return heading
        }
    }
    
    static func CalculateBearingDifference(from: Double, to: Double) -> Double {
        
        if from == to {
            return 0.0
        }
        
        if(from < to) {
            //if from is less than to, to is either clockwise (right) or anti-clockwise to zero (left
            let to_to_zero = 360 - to
            let from_to_zero = from
            
            let cw = to - from
            let acw = to_to_zero + from_to_zero
            
            if(abs(acw) < cw) {
                return -1*acw
            } else {
                return cw
            }
        } else {
            //here, from is ahead of to. the 'to zero' for from will be 360 - from
            let to_to_zero = to
            let from_to_zero = 360 - from
            
            let cw = to - from //this will be negative!!
            let acw = to_to_zero + from_to_zero
            
            if(abs(acw) < abs(cw)) {
                return acw
            } else {
                return cw
            }
        }
    }
    
    static func CalculateBearingDifferenceRadians(from: Double, to: Double) -> Double {
        if from == to {
            return 0.0
        }
        
        if(from < to) {
            //if from is less than to, to is either clockwise (right) or anti-clockwise to zero (left
            let to_to_zero = (2*M_PI) - to
            let from_to_zero = from
            
            let cw = to - from
            let acw = to_to_zero + from_to_zero
            
            if(abs(acw) < cw) {
                return -1*acw
            } else {
                return cw
            }
        } else {
            //here, from is ahead of to. the 'to zero' for from will be 360 - from
            let to_to_zero = to
            let from_to_zero = (2*M_PI) - from
            
            let cw = to - from //this will be negative!!
            let acw = to_to_zero + from_to_zero
            
            if(abs(acw) < abs(cw)) {
                return acw
            } else {
                return cw
            }
        }
        
    }
    
    static func CalculateAverageBearing(bearings: [Double]) -> Double {
        var x = 0.0
        var y = 0.0
        
        for bearing in bearings {
            x += cos(ToRadians(bearing))
            y += sin(ToRadians(bearing))
        }
        
        let bearing_average_radians = atan2(y, x)
        var bearing_average = ToDegrees(bearing_average_radians)
        
        if bearing_average < 0 {
            bearing_average = bearing_average + 360
        }
        
        return bearing_average
    }
    
    static func AddRadians(base:Double, addition:Double) -> Double {
        let new_base = base + addition
        if new_base > (2*M_PI) {
            return new_base - (2*M_PI)
        } else if new_base < 0 {
            return new_base + (2*M_PI)
        } else {
            return new_base
        }
    }
    
    static func AddDegrees(base: Double, addition: Double) -> Double {
        let new_base = base + addition
        if new_base > 360.0 {
            return new_base - 360.0
        } else if new_base < 0 {
            return 360.0 + new_base
        } else {
            return new_base
        }
    }
    
    static func ToRadians(value:Double) -> Double {
        return value * M_PI / 180.0
    }
    
    static func DegreesToCompassRadians(value: Double) -> Double {
        let inverted = 360.0 - value
        return ToRadians(inverted)
    }
    
    static func RadiansToCompassRadians(value: Double) -> Double {
        return (2.0 * M_PI) - value
    }
    
    static func ToDegrees(value:Double) -> Double {
        return value * 180.0 / M_PI
    }

}