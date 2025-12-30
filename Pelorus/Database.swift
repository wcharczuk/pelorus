//
//  Database.swift
//  Pelorus
//
//  Created by Will Charczuk on 10/22/16.
//  Copyright © 2016 Will Charczuk. All rights reserved.
//

import Foundation
import SQLite

struct Database {
    
    static let dbName = "pelorus.sqlite3"
    
    static func Open() throws -> Connection {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
        
        let db = try Connection("\(path)/\(dbName)")
        return db
    }
    
    static func Initialize() throws {
        let db = try Open()
        try CurrentDestinationDataManager.Initialize(db)
        try RecentDestinationsDataManager.Initialize(db)
    }
    
    static func _initCurrentDestination(_ connection: Connection) throws {
        
    }
    
    static func _initRecentDestinations(_ connection: Connection) throws {
        let recentDestinations = Table("RecentDestinations")
        let latitude = Expression<Float64>("Latitude")
        let longitude = Expression<Float64>("Longitude")
        let elevation = Expression<Float64>("Elevation")
        let label = Expression<String?>("Label")
        let subLabel = Expression<String?>("SubLabel")
        
        try connection.run(recentDestinations.create(ifNotExists: true) { t in
            t.column(latitude)
            t.column(longitude)
            t.column(elevation)
            t.column(label)
            t.column(subLabel)
        })
    }
}
