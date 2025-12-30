//
//  RecentDestinationsDataManager.swift
//  Pelorus
//
//  Created by Will Charczuk on 1/6/15.
//  Copyright (c) 2015 Will Charczuk. All rights reserved.
//

import UIKit
import SQLite

struct RecentDestinationsDataManager {
    
    static let recentDestinations = Table("recentDestinations")
    
    static let created = Expression<Date>("Created")
    static let latitude = Expression<Float64>("Latitude")
    static let longitude = Expression<Float64>("Longitude")
    static let elevation = Expression<Float64>("Elevation")
    static let label = Expression<String?>("Label")
    static let subLabel = Expression<String?>("SubLabel")
    
    static func Initialize(_ db: Connection) throws {
        try db.run(recentDestinations.create(ifNotExists: true) { t in
            t.column(created)
            t.column(latitude)
            t.column(longitude)
            t.column(elevation)
            t.column(label)
            t.column(subLabel)
        })
    }
    
    static func Fetch() -> Array<GPS> {
        let db = try! Database.Open()
        
        var values = Array<GPS>()
        for rd in try! db.prepare(recentDestinations) {
            values.append(GPS(
                latitude: rd[latitude],
                longitude: rd[longitude],
                elevation: rd[elevation],
                label: rd[label],
                subLabel: rd[subLabel]
            ))
        }
        return values
    }
    
    static func AddNew(_ destination : GPS) {
        let db = try! Database.Open()

        let _ = try! db.run(recentDestinations.insert(
            created <- Date(),
            latitude <- destination.Latitude,
            longitude <- destination.Longitude,
            elevation <- destination.Elevation,
            label <- destination.Label,
            subLabel <- destination.SubLabel
        ))
    }
    
    static func Purge() {
        let db = try! Database.Open()
        let _ = try! db.run(recentDestinations.delete())
    }

}
