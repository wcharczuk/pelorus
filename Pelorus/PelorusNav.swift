//
//  PelorusNav.swift
//  Pelorus
//
//  Created by Will Charczuk on 11/17/14.
//  Copyright (c) 2014 Will Charczuk. All rights reserved.
//

import UIKit
import CoreLocation
import CoreMotion
import CoreData

protocol PelorusNavUpdateReceiverDelegate {
    func HeadingUpdated(sender: PelorusNav)
    func LocationUpdated(sender: PelorusNav)
}

class PelorusNav : NSObject, CLLocationManagerDelegate {
    class var CameraViewAngle : Double { get { return 50.9 } } //degrees
    
    init(appDelegate: AppDelegate) {
        _appDelegate = appDelegate
    }
    
    var _appDelegate : AppDelegate!
    
    private var _motionManager : CMMotionManager!
    private var _locationManager : CLLocationManager!
    
    private var _headingQueue : [Double]!
    private var _motionQueue : NSOperationQueue = NSOperationQueue()
    
    private var _currentUserLocation : GPS!
    private var _currentDestination : GPS!
    private var _currentDistance : DistanceVector!
    
    var CurrentUserLocation : GPS! {
        get { return _currentUserLocation }
    }
    
    var CurrentDestination : GPS! {
        get { return _currentDestination }
    }
    
    var CurrentDistance : DistanceVector! {
        get { return _currentDistance }
    }
    
    private var _currentRawHeading : Double!
    private var _currentHeading : Double!
    private var _currentDestinationHeading: Double!
    private var _currentHeadingError : Double!
    
    var CurrentHeading : Double! {
        get { return _currentHeading }
    }
    var CurrentHeadingError : Double! {
        get { return _currentHeadingError }
    }
    var CurrentDestinationHeading : Double! {
        get { return _currentDestinationHeading }
    }
    
    private var _receiver : PelorusNavUpdateReceiverDelegate!
    var Receiver : PelorusNavUpdateReceiverDelegate! {
        get {
            return _receiver
        } set(value) {
            _receiver = value
        }
    }
    
    private var _status : String!
    var Status : String {
        get {
            return _status
        }
        set(value) {
            _status = value
        }
    }
    
    func Start() {
        _startLocationSevices()
        _currentDestination = FetchStorage()
    }
    
    func Stop() {
        _stopLocationServices()
        if nil != CurrentDestination {
            SaveStorage()
        } else {
            PurgeStorage()
        }
    }
    
    func ClearDestination() {
        _currentDestination = nil
        _currentDistance = nil
    }
    
    func SetDestination(destination: GPS) {
        _currentDestination = destination
        
        SaveStorage()
        
        if nil != _currentUserLocation {
            _currentDistance = DistanceVector(origin: _currentUserLocation, destination: _currentDestination)
            _currentDestinationHeading = _currentDistance.CompassHeading
        }
    }
    
    /******* Location Manager Specific Delegates *******/
    
    func locationManager (manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var locationArray = locations as NSArray
        var locationObj = locationArray.lastObject as CLLocation
        var coord = locationObj.coordinate
        
        let my_lat = coord.latitude
        let my_long = coord.longitude
        let my_elev = locationObj.altitude
        
        _currentUserLocation = GPS(latitude: my_lat, longitude: my_long, elevation: my_elev)
        
        if(_currentDestination != nil) {
            _currentDistance = DistanceVector(origin: CurrentUserLocation, destination: CurrentDestination)
            _currentDestinationHeading = _currentDistance.CompassHeading
        }
        
        if nil != Receiver {
            Receiver.LocationUpdated(self)
        }
    }
    
    private func _pushNewHeading(queue: [Double], newHeading: Double) -> [Double] {
        if queue.count == 0 || queue.count == 1 {
            return queue + [newHeading]
        } else if queue.count < UserPreferences.CompassSmoothing {
            return queue + [newHeading]
        } else {
            return queue[1 ... (queue.count - 1)] + [newHeading]
        }
    }
    
    private func _movingAverageFilter(newHeading: Double) -> Double {
        self._headingQueue = _pushNewHeading(self._headingQueue, newHeading: _currentRawHeading)
        return DistanceVector.CalculateAverageBearing(self._headingQueue)
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateHeading newHeading: CLHeading!) {
        
        self._currentRawHeading = newHeading.trueHeading
        self._currentHeading = _movingAverageFilter(self._currentRawHeading)
        
        let orientation = UIDevice.currentDevice().orientation
        if orientation == UIDeviceOrientation.LandscapeLeft || orientation == UIDeviceOrientation.LandscapeRight {
            _currentHeading = CurrentHeading + 90.0
            
            if _currentHeading > 360.0 {
                _currentHeading = _currentHeading - 360.0
            }
        }
        
        if _currentDestination != nil && _currentDistance != nil {
            _currentDestinationHeading = _currentDistance.CompassHeading
            _currentHeadingError = DistanceVector.CalculateBearingDifference(_currentHeading, to: _currentDestinationHeading)
        }
        
        if nil != Receiver {
            Receiver.HeadingUpdated(self)
        }
    }
    
    // authorization status
    func locationManager (manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        var shouldAllow = false
        var locationStatus : String = ""
        
        switch status {
            case CLAuthorizationStatus.Restricted:
                locationStatus = "Restricted Access to location"
                break;
            case CLAuthorizationStatus.Denied:
                locationStatus = "User denied access to location"
                break;
            case CLAuthorizationStatus.NotDetermined:
                locationStatus = "Status not determined"
                _locationManager.requestAlwaysAuthorization();
                break;
            default:
                locationStatus = "Allowed to location Access"
                shouldAllow = true
        }
        
        if shouldAllow {
            _status = "Access to Location Allowed."
            _locationManager.startUpdatingLocation()
            _locationManager.startUpdatingHeading()
        } else {
            _status = "Denied Location Access: \(locationStatus)"
        }
    }

    private func _startLocationSevices() {
        if CLLocationManager.locationServicesEnabled() {
            if nil == _locationManager {
                _locationManager = CLLocationManager()
            }
            
            _locationManager.delegate = self
            _locationManager.desiredAccuracy = kCLLocationAccuracyBest
            _locationManager.startUpdatingLocation()
            _locationManager.startUpdatingHeading()
            
            _status = "Location Services started."
            
            _headingQueue = [Double]()
        } else {
            _status = "Location Services are disabled."
        }
    }
    
    private func _stopLocationServices() {
        if nil != _locationManager {
            _locationManager.stopUpdatingHeading()
            _locationManager.stopUpdatingLocation()
        }
    }
    
    /******* Interacting With Core Data *******/
    
    func FetchStorage() -> GPS! {
        let managedContext = _appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName:"Destination")
        
        var error: NSError?
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
        
        if fetchedResults != nil && fetchedResults?.count > 0 {
            let firstResult = fetchedResults?[0]
            return GPS(serialized: firstResult!)
        } else {
            return nil
        }
    }
    
    func PurgeStorage() -> Bool {
        let managedContext = _appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName:"Destination")
        
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
    
    func SaveStorage() -> Bool {
        
        if nil == _currentDestination {
            return false
        }
        
        let managedContext = _appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName:"Destination")
        
        var error: NSError?
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
        
        if nil != fetchedResults && fetchedResults!.count > 0 {
            let firstResult = fetchedResults![0]
            CurrentDestination.saveToManagedObject(firstResult)
            
            if !managedContext.save(&error) {
                return false
            }
            
            return true
        } else {
            let entity =  NSEntityDescription.entityForName("Destination", inManagedObjectContext:managedContext)
            let stored_destination = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
            _currentDestination.saveToManagedObject(stored_destination)
            
            if !managedContext.save(&error) {
                return false
            }
            
            return true
        }
    }
}
