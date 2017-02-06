//
//  NearbyLocationsTableViewController.swift
//  LocationHashtag
//
//  Created by High Jumper on 6/30/16.
//
//

import UIKit

class NearbyLocationsTableViewController: UITableViewController {
    
    var nearbyLocationArray : [LocationModel] = []
    var sortedArray : [String : [LocationModel]] = [:]
    
    let nearbyLocationCellIdentifier = "NearbyLocationCell"
    let segueIdentifier  = "ShowHashtagsSegue"
    
    @IBOutlet var nearbyLocationTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        nearbyLocationArray.removeAll()
        self.getNearbyLocations()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func sortLocationArray(){
        for location in nearbyLocationArray {
            if location.locationType == nil {
                if sortedArray["others"] == nil {
                    sortedArray["others"] = []
                }
                var otherLocations = sortedArray["others"]
                otherLocations?.append(location)
                sortedArray["others"] = otherLocations
            } else {
                if sortedArray[location.locationType!] == nil {
                    sortedArray[location.locationType!] = []
                }
                var locations = sortedArray[location.locationType!]
                locations?.append(location)
                sortedArray[location.locationType!] = locations
            }
        }
    }
    @IBAction func dismissAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sortedArray.count
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
//        return (nearbyLocationArray.count)
        return (sortedArray[Array(sortedArray.keys)[section]]?.count)!
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(nearbyLocationCellIdentifier, forIndexPath: indexPath)
        cell.imageView?.layer.cornerRadius = (cell.imageView?.bounds.height)! / 2
        
        let locations = sortedArray[Array(sortedArray.keys)[indexPath.section]]
        cell.textLabel?.text = locations![indexPath.row].locationName
//       let kBgQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
//        dispatch_async(kBgQueue) {
//            let imageURL = NSURL(string: self.nearbyLocationArray![indexPath.row].icon!)
//            let imageData = NSData(contentsOfURL: imageURL!)
//            cell.imageView?.image = UIImage(data: imageData!)
//        }
        return cell
    }
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Array(sortedArray.keys)[section].uppercaseString
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == segueIdentifier {
            let destination = segue.destinationViewController as! HashtagTableViewController
//            destination.location = nearbyLocationArray[ (nearbyLocationTable.indexPathForSelectedRow?.row)!]
            let indexPath = nearbyLocationTable.indexPathForSelectedRow
            destination.location = sortedArray[Array(sortedArray.keys)[indexPath!.section]]![(indexPath?.row)!]
        }
    }
    private func getNearbyLocations(){
//        let nearbyLocations = KOLocations.sharedInstance.getNearbyLocations(currentLocation!)
        
        SwiftSpinner.show("Nearby locations...")
        InstagramLocationAPIManager.sharedInstance.getLocationId((currentLocation?.coordinate.latitude)!, lng: (currentLocation?.coordinate.longitude)!, successHandler: { (locations) in
            
            for location in locations {
                let locationModel = LocationModel()
                locationModel.latitude = location["latitude"].double
                locationModel.longitude = location["longitude"].double
                locationModel.id = location["id"].string
                locationModel.locationName = location["name"].string
                
                var urlString = "https://maps.googleapis.com/maps/api/place/search/json?location=\(locationModel.latitude!),\(locationModel.longitude!)&radius=2&name=\(locationModel.locationName!)&sensor=true&key=\(GOOGLE_MAP_API_KEY)"
                //types=food|bar|hotel|night_club|florist|cafe|atm|park|store&
                urlString = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
                
                let url = NSURL(string: urlString)
                let jsonData = NSData(contentsOfURL: url!)
                if jsonData != nil {
                    let jsonString = NSString(data: jsonData!, encoding: NSUTF8StringEncoding)
                    debugPrint(jsonString!)
                    let json = JSON(data : jsonData!)
                    if json["results"].array != nil && json["results"].array?.count != 0 {
                        let locationInfo = json["results"].array?.first
                        if locationInfo!["types"].array?.count > 0 {
                            let locationType = locationInfo!["types"].array?.first?.string
                            locationModel.locationType = locationType
                        }
                    }

                }
                
                self.nearbyLocationArray.append(locationModel)
            }
            SwiftSpinner.hide()
            self.sortLocationArray()
            self.nearbyLocationTable.reloadData()
            
            }, failedHandler: { (error) in
                
            SwiftSpinner.hide()
        })
    }
}
