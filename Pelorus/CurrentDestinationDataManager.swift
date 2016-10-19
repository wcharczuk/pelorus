//
//  GpsManager.swift
//  Pelorus
//
//  Created by Will Charczuk on 1/6/15.
//  Copyright (c) 2015 Will Charczuk. All rights reserved.
//

import UIKit
import CoreData

struct CurrentDestinationDataManager {
    static func Fetch() -> GPS! {
        return nil
    }
    
    static func Save(_ destination: GPS!) -> Bool {
        return true
    }
    
    static func Purge() -> Bool {
        return false
    } 
}
