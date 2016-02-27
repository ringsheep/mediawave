//
//  GZSearchResultsController.swift
//  mediawave
//
//  Created by George Zinyakov on 1/2/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import UIKit

class GZSearchResultsController: UITableViewController {

    var tracksArray:Array<GZLFObject> = Array<GZLFObject>()
    var albumsArray:Array<GZLFObject> = Array<GZLFObject>()
    var artistsArray:Array<GZLFObject> = Array<GZLFObject>()
    // array for search suggestions
    var searchArray:Array<GZLFObject>?
    // item used for query in detailed screen
    var selectedItemName:String?
    
    var selectedRow:Int?
    // delegate object for previous controller
    var FeedVCDelegate:GZSearchViewController = GZSearchViewController()
    var searchIsEnded:Bool = false
    
    override func viewDidLoad() {
    super.viewDidLoad()
    // setting the table view
    self.tableView.dataSource = self
    self.tableView.delegate = self
    // cell for search suggestion (simple one)
    self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    // cell for search results (advanced)
    let nibTrackAdvanced = UINib (nibName: "trackAdvancedCell", bundle: nil)
    self.tableView.registerNib(nibTrackAdvanced, forCellReuseIdentifier: "trackAdvancedCell")
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if (searchIsEnded) {
            return 3
        }
        else {
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (searchIsEnded) {
            if (section == 0) {
                return "Artists"
            }
            else if (section == 1) {
                return "Albums"
            }
            else {
                return "Tracks"
            }
        }
        else {
            return ""
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (searchIsEnded) {
            // search results
            if (section == 0) {
                return artistsArray.count
            }
            else if (section == 1) {
                return albumsArray.count
            }
            else {
                return tracksArray.count
            }
        }
        else {
            // search suggestions
            return artistsArray.count + albumsArray.count + tracksArray.count
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (searchIsEnded) {
            // search results
            return 70.00
        }
        else {
            // search suggestions
            return 35.0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // todo: advanced and simple layout
        if (searchIsEnded) {
            // search results
            let cell = tableView.dequeueReusableCellWithIdentifier("trackAdvancedCell", forIndexPath: indexPath) as! GZtrackAdvancedCellTableViewCell
            if (indexPath.section == 0) {
                let artist:GZLFObject = artistsArray[indexPath.row]
                cell.configureSelfWithDataModel(artist)
            }
            else if (indexPath.section == 1) {
                let album:GZLFObject = albumsArray[indexPath.row]
                cell.configureSelfWithDataModel(album)
            }
            else if (indexPath.section == 2) {
                let track:GZLFObject = tracksArray[indexPath.row]
                cell.configureSelfWithDataModel(track)
            }
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
            searchArray = Array<GZLFObject>()
            searchArray!.appendContentsOf(artistsArray)
            searchArray!.appendContentsOf(albumsArray)
            searchArray!.appendContentsOf(tracksArray)
            let LFObject:GZLFObject = searchArray![indexPath.row]
            cell.textLabel?.text = LFObject.name
            // set transparent cell selection style
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.selectedBackgroundView?.backgroundColor = UIColor.clearColor()
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        selectedRow = indexPath.row
        // hide keyboard
        FeedVCDelegate.searchController?.searchBar.resignFirstResponder()
        // add selected string to search field and refresh search results with advanced layout
        if (searchIsEnded)
        {
            if (indexPath.section == 0 )
            {
                // FeedVCDelegate.searchController?.searchBar.text = artistsArray[indexPath.row].name
                selectedItemName = artistsArray[indexPath.row].id
                FeedVCDelegate.performSegueWithIdentifier("toArtistFromSearchResults", sender: self)
            }
            else if (indexPath.section == 1 )
            {
                selectedItemName = albumsArray[indexPath.row].id
                FeedVCDelegate.performSegueWithIdentifier("toAlbumFromSearchResults", sender: self)
            }
            else if (indexPath.section == 2)
            {
                selectedItemName = tracksArray[indexPath.row].id
                FeedVCDelegate.performSegueWithIdentifier("toTrackFromSearchResults", sender: self)
            }
        }
        else
        {
            FeedVCDelegate.searchController?.searchBar.text = searchArray![indexPath.row].name
            FeedVCDelegate.searchContentForQuery((FeedVCDelegate.searchController?.searchBar.text)!)
            self.searchIsEnded = true
        }
        
        // todo: segue inside object
//        FeedVCDelegate.performSegueWithIdentifier("toSearchEndFromHome", sender: self)
//        FeedVCDelegate.searchController?.active = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // todo: segue inside object
        if segue.identifier == "toArtistFromSearchResults" {
            let viewController:GZArtistDetails = segue.destinationViewController as! GZArtistDetails
            viewController.artistQuery = selectedItemName!
        }
        else if segue.identifier == "toAlbumFromSearchResults" {
            let viewController:GZAlbumUIViewController = segue.destinationViewController as! GZAlbumUIViewController
            viewController.currentAlbum = albumsArray[selectedRow!]
        }
        else if segue.identifier == "toTrackFromSearchResults" {
            let viewController:GZArtistDetails = segue.destinationViewController as! GZArtistDetails
            viewController.artistQuery = selectedItemName!
        }
    }
    
}

extension GZSearchResultsController {
    func launchOneAfterAnother(completion: () -> ()) {
        completion()
    }
}