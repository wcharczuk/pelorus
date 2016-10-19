//
//  RecentDestinationsDataManager.swift
//  Pelorus
//
//  Created by Will Charczuk on 1/6/15.
//  Copyright (c) 2015 Will Charczuk. All rights reserved.
//

import UIKit
import CoreData

struct RecentDestinationsDataManager {
    static func Fetch() -> Array<GPS> {
       return Array<GPS>()
    }
    
    static func AddNew(_ destination : GPS) -> Bool {
        return false
    }
    
    static func Purge() -> Bool {
        return false
    }
}
