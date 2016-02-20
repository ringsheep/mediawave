//
//  GZSearchViewController.swift
//  mediawave
//
//  Created by George Zinyakov on 1/2/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import UIKit

class GZSearchViewController: UITableViewController, UISearchControllerDelegate {
    
    var searchResultsController: GZSearchResultsController?
    var searchController: UISearchController?
    var tracksArray:Array<GZLFObject> = Array<GZLFObject>()
    var selectedRow:Int?
    var perPage = 3
    var searchRequestIsMade:Bool = false
    var searchDataIsRecieved:Bool = false
    
    @IBAction func settingsButton(sender: AnyObject) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.searchResultsController = GZSearchResultsController()
        self.searchResultsController?.FeedVCDelegate = self
        // Register cell class for the identifier.
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        self.searchController = UISearchController(searchResultsController: self.searchResultsController!)
        self.searchController?.searchResultsUpdater = self
        self.searchController?.delegate = self
        self.searchController?.searchBar.sizeToFit() // bar size
        self.searchController?.searchBar.delegate = self
        self.searchController?.dimsBackgroundDuringPresentation = false
        self.tableView.tableHeaderView = self.searchController?.searchBar
        self.definesPresentationContext = true
        
        print("self.navigationController?.viewControllers.count \(self.navigationController?.viewControllers.count)")
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    //MARK: Configure cells
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // if search is activated - search suggestions
        if searchController!.active && searchController!.searchBar.text != "" {
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
            let track:GZLFObject = tracksArray[indexPath.row]
            cell.textLabel?.text = track.name
            // set transparent cell selection style
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.selectedBackgroundView?.backgroundColor = UIColor.clearColor()
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
            // set transparent cell selection style
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.selectedBackgroundView?.backgroundColor = UIColor.clearColor()
            return cell
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: prepare for segue
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toArtistFromSearchResults" {
            let viewController:GZArtistDetails = segue.destinationViewController as! GZArtistDetails
            viewController.artistQuery = (searchResultsController?.selectedItemName)!
        }
        else if segue.identifier == "toAlbumFromSearchResults" {
            let viewController:GZAlbumUIViewController = segue.destinationViewController as! GZAlbumUIViewController
            
            viewController.currentAlbum = (searchResultsController?.albumsArray[(searchResultsController?.selectedRow!)!])!
        }
        else if segue.identifier == "toTrackFromSearchResults" {
            let viewController:GZTrackViewController = segue.destinationViewController as! GZTrackViewController
            viewController.loadTracks((searchResultsController?.tracksArray)!, index: (searchResultsController?.selectedRow!)!)
        }
    }

}

// MARK: - UISearchBar Delegate
extension GZSearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        // hide keyboard
        searchBar.resignFirstResponder()
        // refresh search results with advanced layout
        searchResultsController?.searchIsEnded = true
        reloadSearchTableViewAsync()
    }
}

// MARK: - UISearchResultsUpdating Delegate
extension GZSearchViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if ( searchController.active && searchController.searchBar.text != "" && searchController.searchBar.isFirstResponder() ) {
        // search for content each time the search field is updated
        NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "startSearchWithTImer", userInfo: nil, repeats: false)
        }
    }
}

//MARK: search for content in search bar
extension GZSearchViewController
{
    func startSearchWithTImer()
    {
        self.searchContentForQuery(self.searchController!.searchBar.text!)
        self.searchResultsController?.searchIsEnded = false
    }
}

//MARK: reload table view of search results
extension GZSearchViewController
{
    func reloadSearchTableViewAsync()
    {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.searchResultsController?.tableView.reloadData()
        })
    }
}

//MARK: reload table view of self
extension GZSearchViewController
{
    func reloadTableViewAsync()
    {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
        })
    }
}

// MARK: general function for performing search on lastfm api
extension GZSearchViewController {
    func searchContentForQuery( query: String )
    {
        GZLastFmSearchManager.getTracksLF(query, perPage: perPage*2, pageNumber: 1) { (tracks) -> Void in
            GZLastFmSearchManager.getAlbumsLF(query, perPage: self.perPage, pageNumber: 1) { (albums) -> Void in
                GZLastFmSearchManager.getArtistsLF(query, perPage: self.perPage, pageNumber: 1) { (artists) -> Void in
                    GZYoutubeSearchManager.getYTMediaItem(tracks, success: { (tracks) -> Void in
                        self.searchResultsController?.tracksArray = tracks
                        self.searchResultsController?.albumsArray = albums
                        self.searchResultsController?.artistsArray = artists
                        self.reloadSearchTableViewAsync()
                    })
                }
            }
        }
        
        
    }
}