//
//  DistanceVector.swift
//  Pelorus
//
//  Created by Will Charczuk on 11/12/14.
//  Copyright (c) 2014 Will Charczuk. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

extension CLPlacemark {
    func ToLabelString() -> String {
        if nil != self.thoroughfare && nil != self.subThoroughfare {
            return "\(self.subThoroughfare) \(self.thoroughfare), \(self.locality), \(self.administrativeArea)"
        } else if nil != self.thoroughfare {
            return "\(self.thoroughfare), \(self.locality), \(self.administrativeArea)"
        } else {
            return "\(self.locality), \(self.administrativeArea)"
        }
    }
}

struct GPS {
    
    init(latitude: Double, longitude: Double, elevation: Double) {
        self.Latitude = latitude
        self.Longitude = longitude
        self.Elevation = elevation
    }
    
    init(serialized: NSManagedObject) {
        self.Latitude = serialized.valueForKey("latitude") as Double
        self.Longitude = serialized.valueForKey("longitude") as Double
        self.Elevation = serialized.valueForKey("elevation") as Double
        self.Label = serialized.valueForKey("label") as? String
    }
    
    func saveToManagedObject(serialized: NSManagedObject) {
        serialized.setValue(self.Latitude, forKey: "latitude")
        serialized.setValue(self.Longitude, forKey: "longitude")
        serialized.setValue(self.Elevation, forKey: "elevation")
        serialized.setValue(self.Label, forKey: "label")
    }
    
    var Latitude : Double
    var Longitude : Double
    var Elevation : Double
    
    var Label : String!
}

struct DistanceVector {
    
    init(origin: GPS, destination: GPS) {
        self.Origin = origin
        self.Destination = destination
        
        self.DistanceMeters = DistanceVector.CalculateDistanceMeters(point1: origin, point2: destination)
        self.ElevationAngle = DistanceVector.CalculateElevationAngle(point1: origin, point2: destination)
        self.CompassHeading = DistanceVector.CalculateCompassHeading(point1: origin, point2: destination)
    }
    
    var Origin : GPS
    var Destination : GPS
    
    var DistanceMeters : Double
    var ElevationAngle : Double
    var CompassHeading : Double
    
    static func FormatDistance(distanceInMeters: Double) -> String {
        if UserPreferences.UseMetric {
            if(distanceInMeters > 1000) {
                return String(NSString(format:"%.2f km", distanceInMeters / 1000.0))
            } else {
                return String(NSString(format:"%.2f m", distanceInMeters))
            }
        } else {
            let distanceInFeet = distanceInMeters * 3.28084
            if distanceInFeet > 5280.0 {
                return String(NSString(format:"%.2f mi", distanceInFeet / 5280.0))
            } else {
                return String(NSString(format:"%.2f ft", distanceInFeet))
            }
        }
    }
    
    //Uses the Haversine formula to work with the curvature of the earth etc.
    static func CalculateDistanceMeters(#point1: GPS, point2: GPS) -> Double {
        
        var R : Double = 6371 * 1000; //meters
        
        let theta_1 = Radians(point1.Latitude)
        let theta_2 = Radians(point2.Latitude)
        
        let d_theta = Radians(abs(point1.Latitude - point2.Latitude))
        let d_lambda = Radians(abs(point1.Longitude - point2.Longitude))
        
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
        let theta_1 = Radians(point1.Latitude)
        let theta_2 = Radians(point2.Latitude)
        
        let lambda_1 = Radians(point1.Longitude)
        let lambda_2 = Radians(point2.Longitude)
        
        let y = sin(lambda_2 - lambda_1) * cos(theta_2)
        let x = (cos(theta_1) * sin(theta_2))
                - (sin(theta_1) * cos(theta_2) * cos(lambda_2 - lambda_1))
        
        let heading = Degrees(atan2(y, x))
        
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

    static func CalculateAverageBearing(bearings: [Double]) -> Double {
        var x = 0.0
        var y = 0.0

        for bearing in bearings {
            x += cos(Radians(bearing))
            y += sin(Radians(bearing))
        }

        let bearing_average_radians = atan2(y, x)
        var bearing_average = Degrees(bearing_average_radians)

        if bearing_average < 0 {
            bearing_average = bearing_average + 360
        }
        
        return bearing_average
    }
    
    static func Radians(value:Double) -> Double {
        return value * M_PI / 180.0
    }
    
    static func Degrees(value:Double) -> Double {
        return value * 180.0 / M_PI
    }
    
    static func Rotate(x: Double, y: Double, rotation_radians: Double) -> (Double, Double) {
        return (
            cos(rotation_radians)*x + sin(rotation_radians) * y,
            -1 * sin(rotation_radians) * x + cos(rotation_radians) * y
        )
    }
}