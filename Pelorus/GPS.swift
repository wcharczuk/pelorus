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
        self.SubLabel = serialized.valueForKey("subLabel") as? String
    }
    
    init(fromPlacemark: MKMapItem) {
        self.Elevation = 0.0
        self.Latitude = fromPlacemark.placemark.location.coordinate.latitude
        self.Longitude = fromPlacemark.placemark.location.coordinate.longitude
        self.Label = fromPlacemark.name
        self.SubLabel = fromPlacemark.placemark.toLabelString()
    }
    
    func saveToManagedObject(serialized: NSManagedObject) {
        serialized.setValue(self.Latitude, forKey: "latitude")
        serialized.setValue(self.Longitude, forKey: "longitude")
        serialized.setValue(self.Elevation, forKey: "elevation")
        serialized.setValue(self.Label, forKey: "label")
        serialized.setValue(self.SubLabel, forKey: "subLabel")
    }
    
    var Latitude : Double
    var Longitude : Double
    var Elevation : Double
    
    var Label : String!
    var SubLabel : String!
    
    func equals(other: GPS) -> Bool {
        return self.Label == other.Label && self.Latitude == other.Latitude && self.Longitude == other.Longitude
    }
}