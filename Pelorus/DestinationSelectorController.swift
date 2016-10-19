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
    var _recentResults : [GPS]!
    var _searchResults : [GPS]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        _nav = appDelegate.NavManager
        
        mapView.delegate = self

        mapView.showsUserLocation = true
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView?.register(UITableViewCell.self, forCellReuseIdentifier: _cellIdentifier)
        
        let long_press = UILongPressGestureRecognizer()
        long_press.minimumPressDuration = 1.0
        long_press.delegate = self

        mapView.addGestureRecognizer(long_press)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.title = "Choose a Destination"
        
        didZoomToUserLocation = false
        _destination = _nav.CurrentDestination
        
        tableView.isHidden = true
        
        if nil != _nav.CurrentDestination {
            mapView.removeAnnotations(mapView.annotations)
            
            let annot = MKPointAnnotation()
            annot.coordinate = CLLocationCoordinate2D(latitude: _nav.CurrentDestination.Latitude, longitude: _nav.CurrentDestination.Longitude)
            annot.title = "Destination"
            
            mapView.addAnnotation(annot)
        }
        
        _searchResults = nil
        _recentResults = RecentDestinationsDataManager.Fetch()
        
        zoomMapView()
    }
    
    @IBAction func doneButton(_ sender: UIBarButtonItem) {
        
        if nil != _destination {
            _nav.SetDestination(_destination)
        }
        
        let nc = self.navigationController
        let _ = nc?.popToRootViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mapView.removeAnnotations(mapView.annotations)
        
        let item = getItem((indexPath as NSIndexPath).row)
        let coordinate = CLLocationCoordinate2D(latitude: item.Latitude, longitude: item.Longitude)

        let annot = MKPointAnnotation()
        annot.title = item.Label
        annot.coordinate = coordinate
        
        mapView.addAnnotation(annot)
        
        doneButton.isEnabled = true
        
        tableView.isHidden = true
        searchBar.text = ""
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
        searchBar.searchBarStyle = UISearchBarStyle.default
        
        self._destination = item
        
        zoomMapView()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if nil != _searchResults {
            return _searchResults.count
        } else if nil != _recentResults {
            return _recentResults.count
        } else {
            return 0
        }
    }
    
    func getItem(_ atIndex: Int) -> GPS {
        var item : GPS!
        if nil != _searchResults {
            item = _searchResults![atIndex]
        } else {
            item = _recentResults![atIndex]
        }
        return item
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: _cellIdentifier)
        
        let item = getItem((indexPath as NSIndexPath).row)
        
        cell.textLabel?.text = item.Label
        cell.detailTextLabel?.text = item.SubLabel
        return cell
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
    }
    
    func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        tableView.isHidden = false
        searchBar.showsCancelButton = true
        searchBar.searchBarStyle = UISearchBarStyle.default
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        tableView.isHidden = false
        searchBar.showsCancelButton = true
        searchBar.searchBarStyle = UISearchBarStyle.default
        performSearch()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        tableView.isHidden = true
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.searchBarStyle = UISearchBarStyle.minimal
        searchBar.resignFirstResponder()
    }
    
    func performSearch() {
        if nil != searchBar.text && !(searchBar.text?.isEmpty)! {
            let request = MKLocalSearchRequest()
            
            if nil != mapView.userLocation.location  {
                let user = mapView.userLocation.location?.coordinate
                
                let adjustedRegion = mapView.regionThatFits(MKCoordinateRegionMakeWithDistance(user!, 500, 500))
                
                request.region = adjustedRegion
            }

            
            request.naturalLanguageQuery = searchBar.text
            request.region = mapView.region
            
            let search = MKLocalSearch(request: request)
            search.start(completionHandler: searchCompleteHandler as! MKLocalSearchCompletionHandler)
        }
    }
    
    func searchCompleteHandler(_ response: MKLocalSearchResponse!, error: NSError!) {
        if nil != response {
            
            var items = [GPS]()
            for result in response.mapItems {
                let mapItem = result as MKMapItem
                items.append(GPS(fromPlacemark: mapItem))
            }
            
            _searchResults = items
            
            tableView.reloadData()
        }
    }
    
    // ******************** Map View Stuff ****************************** /
    
    func mapView(_ mapView: MKMapView, didUpdate didUpdateUserLocation: MKUserLocation) {
        if !didZoomToUserLocation {
            zoomMapView()
            didZoomToUserLocation = true
        }
    }
    
    func zoomMapView() {
        if nil != _destination {
            //set zoom such that the users location and the destination are in frame plus a nominal margin of 10%
            let user = mapView.userLocation.location?.coordinate
            let destination = CLLocationCoordinate2D(latitude: _destination.Latitude, longitude: _destination.Longitude)
            
            let userPoint = MKMapPointForCoordinate(user!)
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
        } else if mapView.userLocation.location != nil {
            let location = mapView.userLocation.location?.coordinate
            let adjustedRegion = mapView.regionThatFits(MKCoordinateRegionMakeWithDistance(location!, 500, 500))
            mapView.setRegion(adjustedRegion, animated: false)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is MKPointAnnotation) {
            return nil
        }
        
        let reuseId = "destination_annotation_view"
        var anView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if anView == nil {
            anView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView?.isEnabled = true
            anView?.canShowCallout = true
            anView?.isDraggable = true
        }
        else {
            //we are re-using a view, update its annotation reference...
            anView?.annotation = annotation
        }
        
        return anView
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        mapView.removeAnnotations(mapView.annotations)
        let touch_point = gestureRecognizer.location(in: mapView)
        let touch_point_coord = mapView.convert(touch_point, toCoordinateFrom: self.mapView)
        
        let annot = MKPointAnnotation()
        annot.coordinate = touch_point_coord
        annot.title = "Destination"
        
        self._destination = GPS(latitude: touch_point_coord.latitude, longitude: touch_point_coord.longitude, elevation: 0.0)
        
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: touch_point_coord.latitude, longitude: touch_point_coord.longitude), completionHandler: {
            (placemarks, error) in
            let pm = placemarks as [CLPlacemark]!
            if pm!.count > 0 {
                if let p = placemarks?[0] as CLPlacemark! {
                    self._destination.Label = p.name
                    self._destination.SubLabel = p.toLabelString()
                    annot.title = self._destination.Label
                }
            }
        })
        
        mapView.addAnnotation(annot)
        
        doneButton.isEnabled = true
        
        return true
    }

    fileprivate func getElevation(lat: Double, _ long:Double) -> Double {
        let service_url = "http://maps.googleapis.com/maps/api/elevation/json?locations=\(lat),\(long)"
        let url = URL(string: service_url)
        let json = try! Data(contentsOf: url!)
        
        let data : NSDictionary = try! JSONSerialization.jsonObject(with: json, options: .mutableContainers) as! NSDictionary
        
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
