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
    var Label : String!
    var SubLabel : String!
    
    init(latitude: Double, longitude: Double, elevation: Double) {
        self.Latitude = latitude
        self.Longitude = longitude
        self.Elevation = elevation
    }
    
    init(latitude: Double, longitude: Double, elevation: Double, label: String!, subLabel:String!) {
        self.Latitude = latitude
        self.Longitude = longitude
        self.Elevation = elevation
        self.Label = label
        self.SubLabel = subLabel
    }
    
    init(fromPlacemark: MKMapItem) {
        self.Elevation = 0.0
        self.Latitude = (fromPlacemark.placemark.location?.coordinate.latitude)!
        self.Longitude = (fromPlacemark.placemark.location?.coordinate.longitude)!
        self.Label = fromPlacemark.name!
        self.SubLabel = fromPlacemark.placemark.title
    }
    
    func equals(_ other: GPS) -> Bool {
        return self.Label == other.Label && self.Latitude == other.Latitude && self.Longitude == other.Longitude
    }
}
