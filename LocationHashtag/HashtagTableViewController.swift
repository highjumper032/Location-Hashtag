//
//  HashtagTableViewController.swift
//  LocationHashtag
//
//  Created by High Jumper on 6/30/16.
//
//
import UIKit

class HashtagTableViewController: UITableViewController {

    var location : LocationModel?
    var hashtagArray : [[String : AnyObject]] = [[:]]
    var flag : Bool = false

    @IBOutlet var hashtagTable: UITableView!
    let hashtagCellIdentifier = "HashtagCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.getHashtagArray()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func saveAction(sender: AnyObject) {
        DataManager.sharedInstance.updateNewLocation(location!)
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func popAction(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return hashtagArray.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(hashtagCellIdentifier, forIndexPath: indexPath)        
        cell.textLabel?.text = "#\((hashtagArray[indexPath.row]["type"] as! String))"
        cell.detailTextLabel?.text = String(hashtagArray[indexPath.row]["popular"] as! Int)
        return cell
    }
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "MOST POPULAR"
    }
    
    func getHashtagArray(){
        hashtagArray.removeAll()
        if location?.hashtags != nil && location?.hashtags?.count > 0 {
            hashtagArray = (location?.hashtags?.sort({ ($0["popular"] as! Int) > ($1["popular"] as! Int) }))!
            if self.flag == true {
                self.navigationItem.rightBarButtonItem = nil
            }
        } else {
            SwiftSpinner.show("Loag Hashtags")
            InstagramLocationAPIManager.sharedInstance.getLocationMediaRecent((location?.id)!, successHandler: { media in
                for medium in media {
                    let tags = medium["tags"].array
                    for tag in tags! {
                        let tagName = tag.string
                        self.addHashtag(tagName!)
                    }
                }
                self.hashtagArray = (self.hashtagArray.sort({ ($0["popular"] as! Int) > ($1["popular"] as! Int) }))
                self.location?.hashtags = self.hashtagArray
                self.hashtagTable.reloadData()
                    SwiftSpinner.hide()
                }, failedHandler: { (error) in
                    SwiftSpinner.hide()
                
            })
        }
    }
    func addHashtag(tagName : String){
        var isNew = true
        for i in 0 ..< hashtagArray.count  {
            var tag = hashtagArray[i]
            if (tag["type"] as! String) == tagName {
                tag["popular"] = (tag["popular"] as! Int) + 1
                isNew = false
                hashtagArray.removeAtIndex(i)
                hashtagArray.append(tag)
            }
        }
        if isNew == true {
            var tag : [String : AnyObject] = [:]
            tag["type"] = tagName
            tag["popular"] = 1
            hashtagArray.append(tag)
        }
    }
}
