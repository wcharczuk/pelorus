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
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName:"RecentDestinations")
        
        var error: NSError?
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
        
        if fetchedResults != nil && fetchedResults?.count > 0 {
            var results = Array<GPS>()
            for result in fetchedResults! {
                results.append(GPS(serialized: result))
            }
            return results
        } else {
            return Array<GPS>()
        }
    }
    
    static func AddNew(destination : GPS) -> Bool {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        var error: NSError?
        
        //purge dupes && the older 'recent results'
        let fetchRequest = NSFetchRequest(entityName:"RecentDestinations")
        var current = managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?

    
        if nil == error {
            
            if nil != current && current!.count > 0 {
                for item in current! {
                    let typed = GPS(serialized: item)
                    if typed.equals(destination) {
                        managedContext.deleteObject(item)
                    }
                }
                managedContext.save(&error)
            }
        }

        current = managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
        let max_recent = Configuration.MAXIMUM_RECENT
        if nil == error {

            if nil != current && current!.count > max_recent {
                let overageCount = current!.count - max_recent
                
                let overage = current![0 ... overageCount]
                for item in overage {
                    managedContext.deleteObject(item)
                }
                
                managedContext.save(&error)
            }
        }
        
        let entity =  NSEntityDescription.entityForName("RecentDestinations", inManagedObjectContext:managedContext)
        let stored_destination = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
        
        destination.saveToManagedObject(stored_destination)
        managedContext.save(&error)
        
        return nil == error
    }
    
    static func Purge() -> Bool {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName:"RecentDestinations")
        
        var error: NSError?
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
        
        if error != nil {
            return false
        }
        
        if fetchedResults != nil && fetchedResults!.count > 0 {
            let results :[NSManagedObject] = fetchedResults!
            for result in results {
                managedContext.deleteObject(result)
            }
            managedContext.save(&error)
        }
        
        return true
    }
}