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
    func headingUpdated(_ sender: PelorusNav)
    func locationUpdated(_ sender: PelorusNav)
}

class PelorusNav : NSObject, CLLocationManagerDelegate {
    class var CameraViewAngle : Double { get { return 50.9 } } //degrees
    
    init(appDelegate: AppDelegate) {
        _appDelegate = appDelegate
    }
    
    var _appDelegate : AppDelegate!
    
    fileprivate var _motionManager : CMMotionManager!
    fileprivate var _locationManager : CLLocationManager!
    
    fileprivate var _headingQueue = FixedQueue<Double>()
    fileprivate var _locationQueue = FixedQueue<GPS>()
    
    fileprivate var _motionQueue : OperationQueue = OperationQueue()
    
    fileprivate var _currentUserLocationRaw : GPS!
    fileprivate var _currentUserLocation : GPS!
    fileprivate var _currentDestination : GPS!
    fileprivate var _currentDistance : DistanceVector!
    
    var CurrentUserLocation : GPS! {
        get { return _currentUserLocation }
    }
    
    var CurrentDestination : GPS! {
        get { return _currentDestination }
    }
    
    var CurrentDistance : DistanceVector! {
        get { return _currentDistance }
    }
    
    fileprivate var _currentRawHeading : Double!
    fileprivate var _currentHeading : Double!
    fileprivate var _currentDestinationHeading: Double!
    fileprivate var _currentHeadingError : Double!
    
    var CurrentHeading : Double! {
        get { return _currentHeading }
    }
    var CurrentHeadingError : Double! {
        get { return _currentHeadingError }
    }
    var CurrentDestinationHeading : Double! {
        get { return _currentDestinationHeading }
    }
    
    fileprivate var _receiver : PelorusNavUpdateReceiverDelegate!
    var Receiver : PelorusNavUpdateReceiverDelegate! {
        get {
            return _receiver
        } set(value) {
            _receiver = value
        }
    }
    
    fileprivate var _status : String!
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
        _currentDestination = CurrentDestinationDataManager.Fetch()
    }
    
    func Stop() {
        _stopLocationServices()
        if nil != self.CurrentDestination {
            CurrentDestinationDataManager.Save(self.CurrentDestination)
        } else {
            CurrentDestinationDataManager.Purge()
        }
    }
    
    func ClearDestination() {
        _currentDestination = nil
        _currentDistance = nil
    }
    
    func SetDestination(_ destination: GPS) {
        _currentDestination = destination
        
        CurrentDestinationDataManager.Save(_currentDestination)
        RecentDestinationsDataManager.AddNew(_currentDestination)
        
        if nil != _currentUserLocation {
            _currentDistance = DistanceVector(origin: _currentUserLocation, destination: _currentDestination)
            _currentDestinationHeading = _currentDistance.CompassHeading
        }
    }
    
    func ChangeQueueLengths(_ length: Int) {
        _headingQueue.MaxLength = length
        _locationQueue.MaxLength = length
    }
    
    /******* Location Manager Specific Delegates *******/
    
    //location updated
    private func locationManager(_ manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let locationArray = locations as NSArray
        let locationObj = locationArray.lastObject as! CLLocation
        let coord = locationObj.coordinate
        
        let my_lat = coord.latitude
        let my_long = coord.longitude
        let my_elev = locationObj.altitude
        
        self._currentUserLocationRaw = GPS(latitude: my_lat, longitude: my_long, elevation: my_elev)
        
        if UserPreferences.ShouldSmoothLocation {
            self._locationQueue.Enqueue(self._currentUserLocationRaw)
            let reduced_totals = _locationQueue.Reduce {
                (total : (Double, Double, Double)?, value : GPS) in
                if nil == total {
                    return (value.Latitude, value.Longitude, value.Elevation)
                } else {
                    return (value.Latitude + total!.0, value.Longitude + total!.1, value.Elevation + total!.2)
                }
            }
            let count = Double(_locationQueue.Length)
            self._currentUserLocation = GPS(latitude: reduced_totals!.0 / count , longitude: reduced_totals!.1 / count, elevation: reduced_totals!.2 / count)
        } else {
            self._currentUserLocation = self._currentUserLocationRaw
        }
        
        if(_currentDestination != nil) {
            _currentDistance = DistanceVector(origin: CurrentUserLocation, destination: CurrentDestination)
            _currentDestinationHeading = _currentDistance.CompassHeading
        }
        
        if nil != Receiver {
            Receiver.locationUpdated(self)
        }
    }
    
    //heading updated
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
        self._currentRawHeading = newHeading.trueHeading
        
        if UserPreferences.ShouldSmoothCompass {
            self._headingQueue.Enqueue(self._currentRawHeading)
            
            self._currentHeading = CompassUtil.CalculateAverageBearing( self._headingQueue.ToList() )
        } else {
            self._currentHeading = self._currentRawHeading
        }
        
        let orientation = UIDevice.current.orientation
        if orientation == UIDeviceOrientation.landscapeLeft || orientation == UIDeviceOrientation.landscapeRight {
            _currentHeading = CurrentHeading + 90.0
            
            if _currentHeading > 360.0 {
                _currentHeading = _currentHeading - 360.0
            }
        }
        
        if _currentDestination != nil && _currentDistance != nil {
            _currentDestinationHeading = _currentDistance.CompassHeading
            _currentHeadingError = CompassUtil.CalculateBearingDifference(_currentHeading, _currentDestinationHeading)
        }
        
        if nil != Receiver {
            Receiver.headingUpdated(self)
        }
    }
    
    // authorization status
    func locationManager (_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        var shouldAllow = false
        var locationStatus : String = ""
        
        switch status {
            case CLAuthorizationStatus.restricted:
                locationStatus = "Restricted Access to location"
                break;
            case CLAuthorizationStatus.denied:
                locationStatus = "User denied access to location"
                break;
            case CLAuthorizationStatus.notDetermined:
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

    fileprivate func _startLocationSevices() {
        if CLLocationManager.locationServicesEnabled() {
            if nil == _locationManager {
                _locationManager = CLLocationManager()
            }
            
            _locationManager.delegate = self
            _locationManager.desiredAccuracy = kCLLocationAccuracyBest
            _locationManager.startUpdatingLocation()
            _locationManager.startUpdatingHeading()
            
            _status = "Location Services started."
            
            _headingQueue = FixedQueue<Double>(maxLength: UserPreferences.SensorSmoothing)
            _locationQueue = FixedQueue<GPS>(maxLength: UserPreferences.SensorSmoothing)
        } else {
            _status = "Location Services are disabled."
        }
    }
    
    fileprivate func _stopLocationServices() {
        if nil != _locationManager {
            _locationManager.stopUpdatingHeading()
            _locationManager.stopUpdatingLocation()
        }
    }
}
