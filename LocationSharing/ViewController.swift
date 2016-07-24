//
//  ViewController.swift
//  LocationSharing
//
//  Created by Qi (Alvin) Jing on 2016-07-14.
//  Copyright © 2016 Qi (Alvin) Jing. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var locationInfo: UIView!
    
    @IBOutlet weak var map: MKMapView!

    var locationDetailView: LocationInfoView!
    
    var locationManager = CLLocationManager()
    
    var functions = TestFunctions()
    
    var writeTimer = NSTimer()
    
    var readTimer = NSTimer()
    
    var usersLocations: [AnyObject] = []
    
    var usersAnnotations = [CustomPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.map.delegate = self
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        // Display two locations on map
        
        functions.login("alvin@example.com", password: "pass")
        
        usersLocations = retrieveUsersLocations()
        
        setDefaultLocations()

        let latitude:CLLocationDegrees = usersLocations[0].getGeoPointForKey("location")!.latitude
        let longtitude:CLLocationDegrees = usersLocations[0].getGeoPointForKey("location")!.longitude
        //let longtitude:CLLocationDegrees = 0
        let latDelta = 0.05
        let longDelta = 0.05
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longtitude)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        
        map.setRegion(region, animated: true)
        map.mapType = MKMapType.Standard
        map.showsUserLocation = true
        
        initUsersAnnotations()
        
        updateUsersAnnotations()
        
        if let customView = NSBundle.mainBundle().loadNibNamed("LocationInfoSubview", owner: self, options: nil).first as? LocationInfoView {
            
            locationDetailView = customView
            
            locationInfo.addSubview(customView)
            
            //customView.setTranslatesAutoresizingMaskIntoConstraints(false)
        }

        //writeTimer = NSTimer.scheduledTimerWithTimeInterval(0.6, target: self, selector: #selector(ViewController.updateUsersLocations), userInfo: nil, repeats: true)
        
        //readTimer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(ViewController.readUsersLocations), userInfo: nil, repeats: true)
        
    }
    
    func updateUsersAnnotations(){
    
        let group = functions.getGroupWithID("mygroup1")
        
        let bucket = group.bucketWithName("locations")
        
        let allQuery = KiiQuery(clause: nil)
        
        // Create an array to store all the results in
        var allResults = [AnyObject]()
        
        // Get an array of KiiObjects by querying the bucket
        bucket.executeQuery(allQuery) { (query : KiiQuery?, KiiBucket, results : [AnyObject]?, nextQuery : KiiQuery?, error : NSError?) -> Void in
            if error != nil {
                // Error handling
                return
            }
            // Add all the results from this query to the total results
            allResults.appendContentsOf(results!)
            
            // list all users and corresponding latitude and longtitude
            
            var userID: String
            var latitude: CLLocationDegrees
            var longtitude: CLLocationDegrees
            
            let allAnnotations = self.map.annotations
            self.map.removeAnnotations(allAnnotations)
            
            for index in 0 ... allResults.count - 1{
                
                userID = allResults[index].getObjectForKey("userID") as! String
                
                latitude = allResults[index].getGeoPointForKey("location")!.latitude
                longtitude = allResults[index].getGeoPointForKey("location")!.longitude
                
                if userID == self.usersAnnotations[index].id {
                    
                    latitude = allResults[index].getGeoPointForKey("location")!.latitude
                    longtitude = allResults[index].getGeoPointForKey("location")!.longitude
                    self.usersAnnotations[index].coordinate = CLLocationCoordinate2DMake(latitude, longtitude)
                }
 
            }
            
            self.map.addAnnotations(self.usersAnnotations)
        }

    }
    
    
    func initUsersAnnotations(){
        
        let group = functions.getGroupWithID("mygroup1")
        
        let bucket = group.bucketWithName("locations")
        
        let allQuery = KiiQuery(clause: nil)
        
        // Create an array to store all the results in
        var allResults = [AnyObject]()
        
        // Get an array of KiiObjects by querying the bucket
        do{
            let results = try bucket.executeQuerySynchronous(allQuery, nextQuery: nil)
            // Add all the results from this query to the total results
            allResults.appendContentsOf(results)
            
            var userID: String
            var latitude: CLLocationDegrees
            var longtitude: CLLocationDegrees
            
            for obj in allResults{
                
                userID = obj.getObjectForKey("userID") as! String
                
                latitude = obj.getGeoPointForKey("location")!.latitude
                longtitude = obj.getGeoPointForKey("location")!.longitude
                
                let annotation = CustomPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2DMake(latitude, longtitude)
                annotation.id = userID
                //annotation.subtitle = "Subtitle"
                annotation.imageName = "pin2X.png"
                
                self.usersAnnotations.append(annotation)
                
            }
   
        } catch let error as NSError {
            // Error handling
            print(error)
            return
        }
        
    }
    
    func setDefaultLocations(){
        
        // 44.6989212, -63.665212499999996
        // 44.699158, -63.665778
        
        var latitude: CLLocationDegrees = 44.698921
        var longitude: CLLocationDegrees = -63.665212
        
        let allResults:[AnyObject] = usersLocations

        if allResults.isEmpty == false{
            
            for obj in allResults{
                
                latitude += 0.005
                longitude += 0.005
                
                let location = KiiGeoPoint(latitude: latitude, andLongitude: longitude)
                
                obj.setGeoPoint(location, forKey:"location")
                
                obj.saveAllFields(true, withBlock: { (object : KiiObject?, error : NSError?) -> Void in
                    if error != nil {
                        // Error handling
                        return
                    }
                })
            }
        }
        
    }
    
    func readUsersLocations(){
    
        let group = functions.getGroupWithID("mygroup1")
        
        let bucket = group.bucketWithName("locations")
        
        let allQuery = KiiQuery(clause: nil)
        
        // Create an array to store all the results in
        var allResults = [AnyObject]()
        
        // Get an array of KiiObjects by querying the bucket
        bucket.executeQuery(allQuery) { (query : KiiQuery?, KiiBucket, results : [AnyObject]?, nextQuery : KiiQuery?, error : NSError?) -> Void in
            if error != nil {
                // Error handling
                return
            }
            // Add all the results from this query to the total results
            allResults.appendContentsOf(results!)
            
            // list all users and corresponding latitude and longtitude
            
            var userID: String
            var latitude: CLLocationDegrees
            var longtitude: CLLocationDegrees
            
            let allAnnotations = self.map.annotations
            self.map.removeAnnotations(allAnnotations)

            for obj in allResults{
                
                userID = obj.getObjectForKey("userID") as! String
                
                latitude = obj.getGeoPointForKey("location")!.latitude
                longtitude = obj.getGeoPointForKey("location")!.longitude
                
                let annotation = CustomPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2DMake(latitude, longtitude)
                annotation.title = userID
                //annotation.subtitle = "Subtitle"
                annotation.imageName = "pin2X.png"
                
                self.map.addAnnotation(annotation)
                
            }
        }
    
    }
    
    func updateUsersLocations(){

        let allResults:[AnyObject] = usersLocations

        //print(allResults)

        if allResults.isEmpty == false{

            for obj in allResults{
                
                let latitude = obj.getGeoPointForKey("location")!.latitude + 0.0002
                let longtitude = obj.getGeoPointForKey("location")!.longitude + 0.0002
                
                let location = KiiGeoPoint(latitude: latitude, andLongitude: longtitude)
                
                obj.setGeoPoint(location, forKey:"location")
                
                obj.saveAllFields(true, withBlock: { (object : KiiObject?, error : NSError?) -> Void in
                    if error != nil {
                        // Error handling
                        print(error)
                        return
                    }
                })
            }
        }
    }

    func retrieveUsersLocations() -> [AnyObject]{
        
        let group = functions.getGroupWithID("mygroup1")
        
        let bucket = group.bucketWithName("locations")

        // Build "all" query
        let allQuery = KiiQuery(clause: nil)
        
        // Create an array to store all the results in
        var allResults = [AnyObject]()
        
        // Get an array of KiiObjects by querying the bucket
        do{
            let results = try bucket.executeQuerySynchronous(allQuery, nextQuery: nil)
            // Add all the results from this query to the total results
            allResults.appendContentsOf(results)
        } catch let error as NSError {
            // Error handling
            return []
        }

        return allResults
        
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {

        if !(annotation is CustomPointAnnotation) {
            return nil
        }
        
        let annotation = annotation as! CustomPointAnnotation

        let reuseId = "member"
        
        var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView!.canShowCallout = false
        }
        else {
            anView!.annotation = annotation
        }
        
        //Set annotation-specific properties **AFTER**
        //the view is dequeued or created...
        
        let cpa = annotation 
        anView!.image = UIImage(named:cpa.imageName)
        
        return anView
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {

        if !(view.annotation is CustomPointAnnotation) {
            return
        }
        
        let annotation = view.annotation as! CustomPointAnnotation
        
        locationDetailView.nameValueLabel.text = "Alvin"
        
        locationDetailView.latitudeValueLabel.text = String(annotation.coordinate.latitude)
        
        locationDetailView.longitudeValueLabel.text = String(annotation.coordinate.longitude)

        locationInfo.hidden = false
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

