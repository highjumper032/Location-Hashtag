//
//  ViewController.swift
//  LocationHashtag
//
//  Created by High Jumper on 6/26/16.
//
//

import UIKit



class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var submitBtn: UIBarButtonItem!
    @IBOutlet weak var savedLocationTable: UITableView!
    
    var savedLocationArray : [LocationModel]?
    var sortedArray : [String : [LocationModel]] = [:]
    //identifier
    let locationCellIdentifier = "LocationCell"
    let nearbySegueIdentifier = "ShowNearbySegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        InstagramAPIManager.sharedInstance.authorization()
        
        self.viewConfiguration()
        self.loadCurrentLocation()
        
        //Get SavedLocationArray
        savedLocationArray = DataManager.sharedInstance.fetchLocation()
        sortLocationArray()
        savedLocationTable.reloadData()
    }
    
    func sortLocationArray(){
        if savedLocationArray != nil {
            sortedArray.removeAll()
            for location in savedLocationArray! {
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        savedLocationArray = DataManager.sharedInstance.fetchLocation()
        sortLocationArray()
        savedLocationTable.reloadData()
        self.setLeftBarButtonItem()
    }
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == nearbySegueIdentifier {
            if currentLocation != nil {
                return true
            }
            return false
        }
        return false
    }
    func setLeftBarButtonItem(){
        if savedLocationArray == nil || savedLocationArray?.count == 0 {
            self.navigationItem.leftBarButtonItem = nil
            savedLocationTable.setEditing(false, animated: true)
        } else {
            let barBtnItem = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: #selector(ViewController.deleteAction))
            self.navigationItem.setLeftBarButtonItem(barBtnItem, animated: true)
        }
    }
    func deleteAction(){
        savedLocationTable.setEditing(true, animated: true)
        let barBtnItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(ViewController.doneAction))
        self.navigationItem.setLeftBarButtonItem(barBtnItem, animated: true)
    }
    func doneAction(){
        savedLocationTable.setEditing(false, animated: true)
        let barBtnItem = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: #selector(ViewController.deleteAction))
        self.navigationItem.setLeftBarButtonItem(barBtnItem, animated: true)
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sortedArray.count
    }
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Array(sortedArray.keys)[section].uppercaseString
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if savedLocationArray != nil {
//            return (savedLocationArray?.count)!
//        }
//        return 0
        
        return (sortedArray[Array(sortedArray.keys)[section]]?.count)!
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let destination = self.storyboard?.instantiateViewControllerWithIdentifier("HashtagTableViewController") as! HashtagTableViewController
        destination.location = savedLocationArray![indexPath.row]
        destination.flag = true
        self.navigationController?.pushViewController(destination, animated: true)
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(locationCellIdentifier, forIndexPath: indexPath)
        let locations = sortedArray[Array(sortedArray.keys)[indexPath.section]]
        cell.textLabel?.text = locations![indexPath.row].locationName
//        cell.textLabel?.text = savedLocationArray![indexPath.row].locationName
        cell.backgroundColor = UIColor.whiteColor()
        return cell
    }
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            if let koLocation = DataManager.sharedInstance.fetchLocationWithId(savedLocationArray![indexPath.row].id!) {
                DataManager.sharedInstance.deleteLocation(koLocation)
            }
            
            var locations = sortedArray[Array(sortedArray.keys)[indexPath.section]]
            locations?.removeAtIndex(indexPath.row)
            sortedArray[Array(sortedArray.keys)[indexPath.section]] = locations
            
            savedLocationTable.reloadData()
            if savedLocationArray == nil || savedLocationArray?.count == 0 {
                self.navigationItem.leftBarButtonItem = nil
                savedLocationTable.setEditing(false, animated: true)
            }
        }
    }
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if (tableView.editing) {
            return UITableViewCellEditingStyle.Delete
        }
        return UITableViewCellEditingStyle.None
    }
    func loadCurrentLocation(){
        SwiftSpinner.show("Loading Current location...")
        KOLocations.sharedInstance.getCurrentLocation({ (location) in
            SwiftSpinner.show("Success", animated: false).addTapHandler({
                currentLocation = location
                SwiftSpinner.hide()               
            })
        }) { (error) in
            SwiftSpinner.show("Can't load current location", animated: false).addTapHandler({
                SwiftSpinner.hide()
            })
        }
    }
    private func viewConfiguration(){
        self.navigationController?.toolbarHidden = false
//        self.navigationController?.toolbar.barTintColor = UIColorFromHex(0x7D8FFF)
    }
    
    
    
}

