//
//  MapTableViewController.swift
//  Memorable Places
//
//  Created by Yohannes Wijaya on 7/21/15.
//  Copyright © 2015 Yohannes Wijaya. All rights reserved.
//

import UIKit


// MARK: - Stored properties

var placesOfInterest: [Dictionary<String,String>]! // an array of dictionaries
var selectedAddressIndex = -1


class MapTableViewController: UITableViewController {
    
    // MARK: - UIViewController methods override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if placesOfInterest == nil || placesOfInterest.count == 0 {
            placesOfInterest = [["locationMainTitle":  "23 N Santa Cruz Ave.", "locationSubTitle": "Los Gatos, CA 95030. United States.", "latitude": "37.223448", "longitude": "-121.983874"]]
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        self.navigationItem.leftBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placesOfInterest.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reusableCell", forIndexPath: indexPath)
        cell.textLabel?.font = UIFont.systemFontOfSize(16)
        cell.textLabel?.numberOfLines = 2
        let mainTitle = placesOfInterest[indexPath.row]["locationMainTitle"]!
        let subTitle = placesOfInterest[indexPath.row]["locationSubTitle"]!
        cell.textLabel?.text = mainTitle + "\n" + subTitle

        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            placesOfInterest.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            self.saveCurrentStateOfData()
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        let poi = placesOfInterest[fromIndexPath.row]
        placesOfInterest.removeAtIndex(fromIndexPath.row)
        placesOfInterest.insert(poi, atIndex: toIndexPath.row)
        self.saveCurrentStateOfData()
    }

    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        selectedAddressIndex = indexPath.row
        return indexPath
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "newLocationSegue" { selectedAddressIndex = -1 }
    }
    
    // MARK: - Local methods
    
    func saveCurrentStateOfData() {
        NSUserDefaults.standardUserDefaults().setObject(placesOfInterest, forKey: "savedPlacesOfInterest")
        NSUserDefaults.standardUserDefaults().synchronize()
    }

}
