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
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName:"CurrentDestination")
        
        var error: NSError?
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
        
        if fetchedResults != nil && fetchedResults?.count > 0 {
            let firstResult = fetchedResults?[0]
            return GPS(serialized: firstResult!)
        } else {
            return nil
        }
    }
    
    static func Save(destination: GPS!) -> Bool {
        
        if nil == destination {
            return false
        }
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName:"CurrentDestination")
        
        var error: NSError?
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
        
        if nil != fetchedResults && fetchedResults!.count > 0 {
            let firstResult = fetchedResults![0]
            destination!.saveToManagedObject(firstResult)
            
            if !managedContext.save(&error) {
                return false
            }
            
            return true
        } else {
            let entity =  NSEntityDescription.entityForName("CurrentDestination", inManagedObjectContext:managedContext)
            let stored_destination = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
            destination!.saveToManagedObject(stored_destination)
            
            if !managedContext.save(&error) {
                return false
            }
            
            return true
        }
    }
    
    static func Purge() -> Bool {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName:"CurrentDestination")
        
        var error: NSError?
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
        
        if error != nil {
            return false
        }
        
        if fetchedResults != nil && fetchedResults?.count > 0 {
            let results :[NSManagedObject] = fetchedResults!
            for result in results {
                managedContext.deleteObject(result)
            }
            managedContext.save(&error)
        }
        
        return true
    }
}