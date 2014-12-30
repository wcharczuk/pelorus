//
//  GPS.swift
//  Pelorus
//
//  Created by Will Charczuk on 12/29/14.
//  Copyright (c) 2014 Will Charczuk. All rights reserved.
//

import Foundation
import CoreData

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