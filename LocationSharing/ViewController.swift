//
//  ViewController.swift
//  LocationSharing
//
//  Created by Qi (Alvin) Jing on 2016-07-14.
//  Copyright © 2016 Qi (Alvin) Jing. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var map: MKMapView!
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.map.delegate = self
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
        // 44.6989212, -63.665212499999996
        // 44.699158, -63.665778
        let latitude:CLLocationDegrees = 44.698921
        let longtitude:CLLocationDegrees = -63.665212
        let latDelta = 0.01
        let longDelta = 0.01
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longtitude)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        
        map.setRegion(region, animated: true)
        map.mapType = MKMapType.Standard
        map.showsUserLocation = true
        
        
        // Halifax: lantitude: 44.6989212, longtitude: -63.665212499999996
        // Hangzhou: latitude: 30.274085, longtitude: 120.15507000000002
        
        // Display two locations on map
        
        login("alvin@example.com", password: "pass")
        
        let group = getGroupWithID("mygroup1")
        
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
            
            for obj in allResults{
                
                userID = obj.getObjectForKey("userID") as! String

//                print("\(obj.getGeoPointForKey("location")!.latitude), \(obj.getGeoPointForKey("location")!.longitude)")
                
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
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        print("viewForAnnotation delegate called")
        
        if !(annotation is CustomPointAnnotation) {
            return nil
        }
        
        let reuseId = "member"
        
        var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView!.canShowCallout = true
        }
        else {
            anView!.annotation = annotation
        }
        
        //Set annotation-specific properties **AFTER**
        //the view is dequeued or created...
        
        let cpa = annotation as! CustomPointAnnotation
        anView!.image = UIImage(named:cpa.imageName)
        
        return anView
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
        } else {
            newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRectMake(0, 0, newSize.width, newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.drawInRect(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    
    func createObjectInGroup(){
        
        let group = getGroupWithID("mygroup1")
        
        let bucket = group.bucketWithName("locations")
        
        // Create an object and set a geopoint
        // 44.699158, -63.665778
        let object = bucket.createObject()
        if let user = KiiUser.currentUser(){
            let point = KiiGeoPoint(latitude: 44.699158, andLongitude: -63.665778)
            object.setGeoPoint(point, forKey:"location")
            object.setObject(user.userID, forKey: "userID")
            
            object.saveWithBlock { (object : KiiObject?, error : NSError?) -> Void in
                if (error != nil) {
                    // Error handling
                    print(error)
                    return
                }
            }
        }

        
    }
    
    func addUserToGroupByEmail(email: String, group: KiiGroup){
    
        let user = getUserByEmail("cindy@example.com")
        
        if user != nil{
            
            group.addUser(user)
            
            do {
                try group.saveSynchronous()
            } catch let error as NSError {
                // Error handling
                return
            }
        }

    }
    
    
    func listGroupUsers(group: KiiGroup){
        
        group.getMemberListWithBlock { (group : KiiGroup?, members : [AnyObject]?, error : NSError?) -> Void in
            if error != nil {
                // Error handling
                return
            }
            let serialQueue = dispatch_queue_create("com.kii.serial", DISPATCH_QUEUE_SERIAL)
            for obj in members! {
                let user = obj as! KiiUser
                dispatch_async(serialQueue, {
                    do{
                        // refresh the member using the blocking API
                        try user.refreshSynchronous()
                    } catch let error as NSError {
                        // Error handling
                        return
                    }
                    // do something with the user
                    print(user.email!)
                })
            }
        }
        
    }
    
    func getGroupWithID(id: String) -> KiiGroup{
        return KiiGroup(ID: id)
    }
    
    func getUserByEmail(email: String) -> KiiUser?{
        
        let email = email
        let user: KiiUser
        do{
            user = try KiiUser.findUserByEmailSynchronous(email)
        }catch(let error as NSError){
            // Error handling
            print(error)
            return nil
        }
        
        return user
        
    }
    
    func CreateGroup(groupName: String, userID: String){
    
        do{
            // In this example, we assume that the user already
            
            let userID = userID
            let groupID = "mygroup" + userID
            
            let group = try KiiGroup.registerGroupSynchronousWithID(groupID, name: "myGroup", members: nil)
            
            let groupURI = group.objectURI
            // group.groupID same as groupID
        }catch (let error as NSError){
            // Group creation failed for some reasons.
            // Please check NSError to see what went wrong...
            print(error)
            return
        }

        
    }
    
    func createGeoPoint(){
        
        let bucket = Kii.bucketWithName("mapData")
        
        // Create an object and set a geopoint
        let object = bucket.createObject()
        
        let point1 = KiiGeoPoint(latitude: 35.658603, andLongitude: 139.745433)
        let point2 = KiiGeoPoint(latitude: 35.658625, andLongitude: 139.745415)
        object.setGeoPoint(point1, forKey:"location1")
        object.setGeoPoint(point2, forKey:"location2")
        
        do{
            try object.saveSynchronous()
        } catch let error as NSError {
            // Error handling
            print(error)
            return
        }

    }
    
    func login(email: String, password: String){
    
        let email = email
        let password = password
        
        do{
            try KiiUser.authenticateSynchronous(email, withPassword: password)
        }catch let error as NSError {
            // Error handling
            print("Login failed")
            return
        }
        
        print("Login successful")
    
    }
    
    func createUser(email: String, password: String){

        let email = email
        let password = password
        
        let user = KiiUser(emailAddress: email, andPassword: password)
        do{
            try user.performRegistrationSynchronous()
        } catch let error as NSError {
            // Error handling
            print("Create User Failed")
            return
        }
        
        print("Created User \(email)")

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

