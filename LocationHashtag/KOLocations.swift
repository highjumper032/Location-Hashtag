//
//  KOLocations.swift
//  location
//
//  Created by cat on 28/06/16.
//  Copyright © 2016 High Jumper. All rights reserved.
//

import UIKit
import CoreLocation
import SystemConfiguration

public let ERROR_CODE:Int = 99999
let GOOGLE_MAP_API_KEY = "AIzaSyAmQKD3EHINf0N7pYJ1S2Qek7_iKgqZ-rM"

public class KOLocations: NSObject {
    
    public static var sharedInstance = KOLocations()
    
    private var locationManager : KOLocationManager?
    private var storeInfoArray : [[String : String]]?
    
    public typealias getLocationSuccessed = ((location: CLLocation) -> Void)
    public typealias myfailedHandler = ( (error: NSError?) -> Void )
    public typealias getGeocodeSuccessed = ((locationName: String) -> Void)
    
    override init() {
        super.init()
        //TODO write the initial code here
    }
    
    public func getCurrentLocation(successHandler : getLocationSuccessed, failedHandler :myfailedHandler){
        
        locationManager = KOLocationManager()
        locationManager!.getLocation {location, error in
            // fetch location or an error
            if let loc = location {
                successHandler(location: loc)
            } else if let err = error {
                failedHandler(error: err)
            }
            self.locationManager = nil
        }
    }
    
    func getGeocode(location : CLLocation, successHandler : getGeocodeSuccessed, failedHandler :myfailedHandler){
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location) {(placeMarks, error) -> Void in
            if(error != nil){
                failedHandler(error:error)
                return
            }
            if(placeMarks!.count > 0) {
                let placeMark = placeMarks!.first
                let locationName = placeMark!.name//addressDictionary?["name"] as? String
                successHandler(locationName: locationName!)
                return
            } else {
                let err = NSError(domain: "Can't find matched place", code: ERROR_CODE, userInfo: nil)
                failedHandler(error: err)
            }
        }
    }
    
    func getNearbyLocations(currentLocation : CLLocation) -> [LocationModel]{
        
        var urlString = "https://maps.googleapis.com/maps/api/place/search/json?location=\(currentLocation.coordinate.latitude),\(currentLocation.coordinate.longitude)&radius=500&types=food|bar|hotel|night_club|florist|cafe|atm|park|store&sensor=true&key=\(GOOGLE_MAP_API_KEY)"
        urlString = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        
        let url = NSURL(string: urlString)
        let jsonData = NSData(contentsOfURL: url!)
        if jsonData != nil {
            let jsonString = NSString(data: jsonData!, encoding: NSUTF8StringEncoding)
            debugPrint(jsonString!)
            let json = JSON(data : jsonData!)
            var nearbyLocations : [LocationModel] = []
            if json["results"].array != nil && json["results"].array?.count != 0 {
                for location in json["results"].array! {
                    let nearbyLocation = LocationModel()
                    nearbyLocation.locationName = location["name"].string
                    nearbyLocation.latitude = location["location"]["lat"].double
                    nearbyLocation.longitude = location["location"]["lng"].double
                    nearbyLocation.icon = location["icon"].string
                    nearbyLocation.id = location["place_id"].string
                    var types : [[String : AnyObject]] = []
                    for item in location["types"].array! {
                        var type : [String : AnyObject] = [:]
                        type["type"] = item.string
                        type["popular"] = random() % 40
                        types.append(type)
                    }
                    nearbyLocation.hashtags = types
                    
                    nearbyLocations.append(nearbyLocation)
                }
            }
            return nearbyLocations
        }
        return []
    }
}
