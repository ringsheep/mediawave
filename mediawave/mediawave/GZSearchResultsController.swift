//
//  GZSearchResultsController.swift
//  mediawave
//
//  Created by George Zinyakov on 1/2/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import UIKit

class GZSearchResultsController: UITableViewController {

    var tracksArray:Array<GZTrack> = Array<GZTrack>()
    var selectedRow:Int?
    
    override func viewDidLoad() {
    super.viewDidLoad()
    let resultsTableView = UITableView(frame: self.tableView.frame)
    self.tableView = resultsTableView
    self.tableView.dataSource = self
    self.tableView.delegate = self
    self.tableView.backgroundColor = UIColor.redColor()
    self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tracksArray.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let track:GZTrack = tracksArray[indexPath.row]
        cell.textLabel?.text = track.name
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        selectedRow = indexPath.row
        self.performSegueWithIdentifier("toSearchEndFromResults", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toSearchEndFromResults" {
            let viewController:GZSearchEndController = segue.destinationViewController as! GZSearchEndController
            viewController.track = tracksArray[selectedRow!]
            
        }
    }
    
}