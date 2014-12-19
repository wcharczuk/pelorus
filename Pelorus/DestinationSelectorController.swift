//
//  DestinationSelectorController.swift
//  Pelorus
//
//  Created by Will Charczuk on 11/12/14.
//  Copyright (c) 2014 Will Charczuk. All rights reserved.
//

import UIKit
import CoreLocation
import CoreMotion
import MapKit

class DestinationSelectorController: UIViewController, UIGestureRecognizerDelegate, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var didZoomToUserLocation = false
    
    @IBOutlet var doneButton : UIBarButtonItem!
    @IBOutlet var mapView : MKMapView!
    
    @IBOutlet var searchBar : UISearchBar!
    @IBOutlet var tableView : UITableView!
    
    var _destination : GPS!
    var _nav : PelorusNav!
    
    let _cellIdentifier = "searchResult"
    var _searchResults : [AnyObject]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        _nav = appDelegate.NavManager
        
        mapView.delegate = self

        mapView.showsUserLocation = true
        mapView.zoomEnabled = true
        mapView.scrollEnabled = true
        
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView?.registerClass(UITableViewCell.self, forCellReuseIdentifier: _cellIdentifier)
        
        let long_press = UILongPressGestureRecognizer()
        long_press.minimumPressDuration = 1.0
        long_press.delegate = self

        mapView.addGestureRecognizer(long_press)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.title = "Choose a Destination"
        
        didZoomToUserLocation = false
        _destination = _nav.CurrentDestination
        
        tableView.hidden = true
        
        if nil != _nav.CurrentDestination {
            mapView.removeAnnotations(mapView.annotations)
            
            let annot = MKPointAnnotation()
            annot.coordinate = CLLocationCoordinate2D(latitude: _nav.CurrentDestination.Latitude, longitude: _nav.CurrentDestination.Longitude)
            annot.title = "Destination"
            
            mapView.addAnnotation(annot)
        }
        
        zoomMapView()
    }
    
    @IBAction func doneButton(sender: UIBarButtonItem) {
        if nil != _destination {
            _nav.SetDestination(_destination)
        }
        
        let nc = self.navigationController
        nc?.popToRootViewControllerAnimated(true)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        mapView.removeAnnotations(mapView.annotations)
        
        let item = _searchResults[indexPath.row] as MKMapItem
        
        let coord = item.placemark.coordinate
        
        let elevation = getElevation(lat: coord.latitude, long: coord.longitude)
        _destination = GPS(latitude: coord.latitude, longitude: coord.longitude, elevation: elevation)
        _destination.Label = item.name
        
        mapView.addAnnotation(item.placemark)
        
        doneButton.enabled = true
        
        tableView.hidden = true
        searchBar.text = ""
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
        searchBar.searchBarStyle = UISearchBarStyle.Default
        
        zoomMapView()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if nil != _searchResults {
            return _searchResults.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let item = (_searchResults[indexPath.row] as MKMapItem)
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: _cellIdentifier)
        
        let item_location = GPS(latitude: item.placemark.location.coordinate.latitude, longitude: item.placemark.location.coordinate.longitude, elevation: 0.0)
        
        if nil != _nav.CurrentUserLocation {
            let item_distance = DistanceVector(origin: _nav.CurrentUserLocation, destination: item_location)
        }
        
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = item.placemark.ToLabelString()
        return cell
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        performSearch()
    }
    
    func searchBarResultsListButtonClicked(searchBar: UISearchBar) {
        performSearch()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        tableView.hidden = false
        searchBar.showsCancelButton = true
        searchBar.searchBarStyle = UISearchBarStyle.Default
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        tableView.hidden = false
        searchBar.showsCancelButton = true
        searchBar.searchBarStyle = UISearchBarStyle.Default
        performSearch()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        tableView.hidden = true
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.searchBarStyle = UISearchBarStyle.Minimal
        searchBar.resignFirstResponder()
    }
    
    func performSearch() {
        if nil != searchBar.text && !searchBar.text.isEmpty {
            let request = MKLocalSearchRequest()
            request.naturalLanguageQuery = searchBar.text
            request.region = mapView.region
            
            let search = MKLocalSearch(request: request)
            search.startWithCompletionHandler(searchCompleteHandler)
        }
    }
    
    func searchCompleteHandler(response: MKLocalSearchResponse!, error: NSError!) {
        if nil != response {
            _searchResults = response.mapItems
            tableView.reloadData()
        }
    }
    
    // ******************** Map View Stuff ****************************** /
    
    func mapView(mapView: MKMapView, didUpdateUserLocation: MKUserLocation) {
        if !didZoomToUserLocation {
            zoomMapView()
            didZoomToUserLocation = true
        }
    }
    
    func zoomMapView() {
        if nil != _destination && nil != mapView.userLocation && nil != mapView.userLocation.location {
            //set zoom such that the users location and the destination are in frame plus a nominal margin of 10%
            let user = mapView.userLocation.location.coordinate
            let destination = CLLocationCoordinate2D(latitude: _destination.Latitude, longitude: _destination.Longitude)
            
            let userPoint = MKMapPointForCoordinate(user)
            let destinationPoint = MKMapPointForCoordinate(destination)
            
            let userRect = MKMapRectMake(userPoint.x, userPoint.y, 100, 100)
            let destinationRect = MKMapRectMake(destinationPoint.x, destinationPoint.y, 100, 100);

            let unionRect = MKMapRectUnion(userRect, destinationRect)
            
            let unionRectThatFits = mapView.mapRectThatFits(unionRect)
            
            mapView.setVisibleMapRect(unionRectThatFits, edgePadding:UIEdgeInsetsMake(75, 10, 10, 10), animated:false)
        } else if nil != _destination {
            let location = CLLocationCoordinate2D(latitude: _destination.Latitude, longitude: _destination.Longitude)
            let adjustedRegion = mapView.regionThatFits(MKCoordinateRegionMakeWithDistance(location, 500, 500))
            mapView.setRegion(adjustedRegion, animated: false)
        } else if mapView.userLocation != nil && mapView.userLocation.location != nil {
            let location = mapView.userLocation.location.coordinate
            let adjustedRegion = mapView.regionThatFits(MKCoordinateRegionMakeWithDistance(location, 500, 500))
            mapView.setRegion(adjustedRegion, animated: false)
        }
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if !(annotation is MKPointAnnotation) {
            return nil
        }
        
        let reuseId = "destination_annotation_view"
        var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        if anView == nil {
            anView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView.enabled = true
            anView.canShowCallout = true
            anView.draggable = true
        }
        else {
            //we are re-using a view, update its annotation reference...
            anView.annotation = annotation
        }
        
        return anView
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        mapView.removeAnnotations(mapView.annotations)
        let touch_point = gestureRecognizer.locationInView(mapView)
        let touch_point_coord = mapView.convertPoint(touch_point, toCoordinateFromView: self.mapView)
        
        let annot = MKPointAnnotation()
        annot.coordinate = touch_point_coord
        annot.title = "Destination"
        
        let elevation = getElevation(lat: touch_point_coord.latitude, long: touch_point_coord.longitude)
        _destination = GPS(latitude: touch_point_coord.latitude, longitude: touch_point_coord.longitude, elevation: elevation)
        
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: touch_point_coord.latitude, longitude: touch_point_coord.longitude), completionHandler: {
            (placemarks, error) in
            let pm = placemarks as? [CLPlacemark]
            if nil != pm && pm?.count > 0 {
                if let p = placemarks[0] as? CLPlacemark {
                    self._destination.Label = p.ToLabelString()
                    annot.title = self._destination.Label
                }
            }
        })
        
        mapView.addAnnotation(annot)
        
        doneButton.enabled = true
        
        return true
    }

    private func getElevation(#lat: Double, long:Double) -> Double {
        
        var error: NSError?
        
        let service_url = "http://maps.googleapis.com/maps/api/elevation/json?locations=\(lat),\(long)"
        let url = NSURL(string: service_url)
        let json = NSData(contentsOfURL: url!)
        let data : NSDictionary = NSJSONSerialization.JSONObjectWithData(json!, options: NSJSONReadingOptions.MutableContainers, error: &error) as NSDictionary
        
        if let results = data["results"] as? NSArray {
            if let container = results[0] as? NSDictionary {
                if let elevation = container["elevation"] as? Double {
                    return elevation
                }
            }
        }
        
        return 0.0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
