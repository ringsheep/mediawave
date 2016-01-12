//
//  GZFeedViewController.swift
//  mediawave
//
//  Created by George Zinyakov on 1/2/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import UIKit

class GZFeedViewController: UITableViewController, UISearchControllerDelegate {
    
    var searchResultsController: GZSearchResultsController?
    var searchController: UISearchController?
    var tracksArray:Array<GZLFObject> = Array<GZLFObject>()
    var selectedRow:Int?
    var perPage = 3
    var searchRequestIsMade:Bool = false
    var searchDataIsRecieved:Bool = false
    
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
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        if searchController!.active && searchController!.searchBar.text != "" {
            let track:GZLFObject = tracksArray[indexPath.row]
            cell.textLabel?.text = track.name
            print("\(cell.textLabel?.text)")
        }
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // general function for performing search on lastfm api
    func searchContentForQuery( query: String )
    {
        GZPostManager.getTracksLF(query, perPage: perPage*2, pageNumber: 1) { (tracks) -> Void in
            self.searchResultsController?.tracksArray = tracks
            GZPostManager.getAlbumsLF(query, perPage: self.perPage, pageNumber: 1) { (albums) -> Void in
                self.searchResultsController?.albumsArray = albums
                GZPostManager.getArtistsLF(query, perPage: self.perPage, pageNumber: 1) { (artists) -> Void in
                    self.searchResultsController?.artistsArray = artists
                    self.reloadTableViewAsync()
                }
            }
        }
        
        
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toArtistFromSearchResults" {
            let viewController:GZArtistDetails = segue.destinationViewController as! GZArtistDetails
            viewController.artistQuery = (searchResultsController?.selectedItemName)!
        }
    }

}

extension GZFeedViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        // hide keyboard
        searchBar.resignFirstResponder()
        // refresh search results with advanced layout
        searchResultsController?.searchIsEnded = true
        reloadTableViewAsync()
    }
}

extension GZFeedViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if ( searchController.active && searchController.searchBar.text != "" && searchController.searchBar.isFirstResponder() ) {
        // search for content each time the search field is updated
        NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "startSearchWithTImer", userInfo: nil, repeats: false)
        }
    }
}

extension GZFeedViewController
{
    func startSearchWithTImer()
    {
        self.searchContentForQuery(self.searchController!.searchBar.text!)
        self.searchResultsController?.searchIsEnded = false
    }
    
    func reloadTableViewAsync()
    {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.searchResultsController?.tableView.reloadData()
        })
    }
}