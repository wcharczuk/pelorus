//
//  GpsManager.swift
//  Pelorus
//
//  Created by Will Charczuk on 1/6/15.
//  Copyright (c) 2015 Will Charczuk. All rights reserved.
//

import UIKit
import SQLite

struct CurrentDestinationDataManager {
    
    static let currentDestination = Table("CurrentDestination")
    
    static let latitude = Expression<Float64>("Latitude")
    static let longitude = Expression<Float64>("Longitude")
    static let elevation = Expression<Float64>("Elevation")
    static let label = Expression<String?>("Label")
    static let subLabel = Expression<String?>("SubLabel")
    
    static func Initialize(_ db: Connection) throws {
        try db.run(currentDestination.create(ifNotExists: true) { t in
            t.column(latitude)
            t.column(longitude)
            t.column(elevation)
            t.column(label)
            t.column(subLabel)
        })
    }
    
    static func Fetch() -> GPS! {
        let db = try! Database.Open()
        
        let cd = try! db.pluck(currentDestination)
        
        if let cd = cd {
            return GPS(
                latitude: cd[latitude],
                longitude: cd[longitude],
                elevation: cd[elevation],
                label: cd[label],
                subLabel: cd[subLabel]
            )
        }
        
        return nil
    }
    
    static func Save(_ destination: GPS!) {
        let db = try! Database.Open()
        let _ = try! db.run(currentDestination.delete())
        
        let _ = try! db.run(currentDestination.insert(
            latitude <- destination.Latitude,
            longitude <- destination.Longitude,
            elevation <- destination.Elevation,
            label <- destination.Label,
            subLabel <- destination.SubLabel
        ))
    }
    
    static func Purge() {
        let db = try! Database.Open()
        let _ = try! db.run(currentDestination.delete())
    }
    
}
