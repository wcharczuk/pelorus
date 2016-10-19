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
        
        self.DistanceMeters = CompassUtil.CalculateDistanceMeters(origin, destination)
        self.ElevationAngle = CompassUtil.CalculateElevationAngle(origin, destination)
        self.CompassHeading = CompassUtil.CalculateCompassHeading(origin, destination)
    }
    
    var Origin : GPS
    var Destination : GPS
    
    var DistanceMeters : Double
    var ElevationAngle : Double
    var CompassHeading : Double
}
