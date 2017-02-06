//
//  KOLocationManager.swift
//  location
//
//  Created by cat on 28/06/16.
//  Copyright © 2016 High Jumper. All rights reserved.
//

import UIKit
import CoreLocation


//possible errors
enum KOLocationManagerErrors: Int {
    case AuthorizationDenied
    case AuthorizationNotDetermined
    case InvalidLocation
}

class KOLocationManager: NSObject, CLLocationManagerDelegate {
    
    //location manager
    private var locationManager: CLLocationManager?
    
    //destroy the manager
    deinit {
        locationManager?.delegate = nil
        locationManager = nil
    }
    
    typealias LocationClosure = ((location: CLLocation?, error: NSError?)->())
    
    private var didComplete: LocationClosure?
    
    //location manager returned, call didcomplete closure
    private func _didComplete(location: CLLocation?, error: NSError?) {
        locationManager?.stopUpdatingLocation()
        didComplete?(location: location, error: error)
        locationManager?.delegate = nil
        locationManager = nil
    }
    
    //location authorization status changed
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .AuthorizedWhenInUse:
            self.locationManager!.startUpdatingLocation()
        case .AuthorizedAlways:
            self.locationManager!.startUpdatingLocation()
        case .Denied:
            _didComplete(nil, error: NSError(domain: self.classForCoder.description(),
                code: KOLocationManagerErrors.AuthorizationDenied.rawValue,
                userInfo: nil))
        default:
            break
        }
    }    
    internal func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        _didComplete(nil, error: error)
    }
    
    internal func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        _didComplete(location, error: nil)
    }
    
    //ask for location permissions, fetch 1 location, and return
    func getLocation(completion: LocationClosure) {
        //store the completion closure
        didComplete = completion
        //fire the location manager
        locationManager = CLLocationManager()
        locationManager!.delegate = self
        
        //check for description key and ask permissions
        if (NSBundle.mainBundle().objectForInfoDictionaryKey("NSLocationAlwaysUsageDescription") != nil) {
            locationManager!.requestAlwaysAuthorization()
        } else if (NSBundle.mainBundle().objectForInfoDictionaryKey("NSLocationWhenInUseUsageDescription") != nil) {
            locationManager!.requestWhenInUseAuthorization()
        } else {
            fatalError("To use location in iOS8 you need to define either NSLocationWhenInUseUsageDescription or NSLocationAlwaysUsageDescription in the app bundle's Info.plist file")
        }
    }
}

