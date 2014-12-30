//
//  DistanceVector.swift
//  Pelorus
//
//  Created by Will Charczuk on 11/12/14.
//  Copyright (c) 2014 Will Charczuk. All rights reserved.
//

import Foundation

struct DistanceVector {
    init(origin: GPS, destination: GPS) {
        self.Origin = origin
        self.Destination = destination
        
        self.DistanceMeters = CompassUtil.CalculateDistanceMeters(point1: origin, point2: destination)
        self.ElevationAngle = CompassUtil.CalculateElevationAngle(point1: origin, point2: destination)
        self.CompassHeading = CompassUtil.CalculateCompassHeading(point1: origin, point2: destination)
    }
    
    var Origin : GPS
    var Destination : GPS
    
    var DistanceMeters : Double
    var ElevationAngle : Double
    var CompassHeading : Double
}