//
//  GPS.swift
//  Pelorus
//
//  Created by Will Charczuk on 12/29/14.
//  Copyright (c) 2014 Will Charczuk. All rights reserved.
//

import Foundation
import CoreData
import MapKit

struct GPS {
    
    var Latitude : Double
    var Longitude : Double
    var Elevation : Double
    
    init(latitude: Double, longitude: Double, elevation: Double) {
        self.Latitude = latitude
        self.Longitude = longitude
        self.Elevation = elevation
    }
    
    init(fromPlacemark: MKMapItem) {
        self.Elevation = 0.0
        self.Latitude = (fromPlacemark.placemark.location?.coordinate.latitude)!
        self.Longitude = (fromPlacemark.placemark.location?.coordinate.longitude)!
        self.Label = fromPlacemark.name
        self.SubLabel = fromPlacemark.placemark.toLabelString()
    }
    
    var Label : String!
    var SubLabel : String!
    
    func equals(_ other: GPS) -> Bool {
        return self.Label == other.Label && self.Latitude == other.Latitude && self.Longitude == other.Longitude
    }
}
