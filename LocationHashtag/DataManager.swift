//
//  DataManager.swift
//  LocationHashtag
//
//  Created by High Jumper on 6/30/16.
//
//

import UIKit
import CoreData

let moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
class DataManager: NSObject {
    
    static let sharedInstance = DataManager()
    
    override init() {
        super.init()
    }
    func seedLocation(locationModel : LocationModel){
        let locationEntity = NSEntityDescription.insertNewObjectForEntityForName("KOLocation", inManagedObjectContext: moc) as! KOLocation
        locationEntity.name = locationModel.locationName
        locationEntity.latitude =  locationModel.latitude
        locationEntity.longitude = locationModel.longitude
        if locationModel.locationType != nil {
            locationEntity.type = locationModel.locationType
        }
//        locationEntity.icon = locationModel.icon
        locationEntity.id = locationModel.id
        saveMoc()
        
        for item in locationModel.hashtags! {
            seedHashtag(item, location: locationEntity)
        }
    }
    
    func updateNewLocation(locationModel : LocationModel){
        if let location = fetchLocationWithId(locationModel.id!){
            deleteLocation(location)
        }
        seedLocation(locationModel)
    }
    
    func fetchLocationWithId(id : String)->KOLocation?{
        let request = NSFetchRequest(entityName : "KOLocation")
        let predicate = NSPredicate(format: "id=%@", id)
        request.predicate = predicate
        var fetchedComponents : [KOLocation] = []
        do{
            fetchedComponents = try moc.executeFetchRequest(request) as! [KOLocation]
        }catch{
            NSLog("bad things happened : \(error)")
            return nil
        }
        if fetchedComponents.count  == 0 {
            return nil
        }
        return fetchedComponents.first
    }
    
    func fetchLocation()->[LocationModel]?{
        let request = NSFetchRequest(entityName: "KOLocation")
        var fetchedComponents : [KOLocation] = []
        do{
            fetchedComponents = try moc.executeFetchRequest(request) as! [KOLocation]
        }catch{
            NSLog("bad things happened : \(error)")
            return nil
        }
        if fetchedComponents.count  == 0 {
            return nil
        }
        var locations : [LocationModel] = []
        for fetchLocation in fetchedComponents {
            let location = getLocationModelFromKOLocation(fetchLocation)
            locations.append(location)
        }
        return locations
    }
    func getLocationModelFromKOLocation(location : KOLocation) -> LocationModel{
        let locationModel =  LocationModel()
        locationModel.locationName = location.name
        locationModel.id = location.id
        locationModel.latitude = location.latitude as? Double
        locationModel.longitude = location.longitude as? Double
        if location.type != nil {
            locationModel.locationType = location.type
        }
        var types : [[String : AnyObject]] = []
        let hashtags = location.mutableSetValueForKey("hashtags")
        for item in hashtags {
            let hashtag = item as! Hashtag
            var type : [String : AnyObject] = [:]
            type["type"] = hashtag.name
            type["popular"] = hashtag.population
            
            types.append(type)
        }
        locationModel.hashtags = types
        
        return locationModel
    }
    func deleteLocation(location : KOLocation){
        moc.deleteObject(location as NSManagedObject)
        saveMoc()
    }
    
    func seedHashtag(params : [String : AnyObject], location : KOLocation?){
        let hsEntity = NSEntityDescription.insertNewObjectForEntityForName("Hashtag", inManagedObjectContext: moc) as! Hashtag
        hsEntity.name = params["type"] as? String
        hsEntity.population = params["popular"] as! Int
        if location != nil {
            hsEntity.location = location
        }
        saveMoc()
    }
    
    func saveMoc() {
        do {
            try moc.save()
        }catch{
            debugPrint("failure to save context : \(error)")
        }
    }
}
