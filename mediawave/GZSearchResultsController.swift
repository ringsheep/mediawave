//
//  GZSearchResultsController.swift
//  mediawave
//
//  Created by George Zinyakov on 1/2/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import UIKit
import CoreData

class GZSearchResultsController: GZTableViewController {
    
    // arrays of objects for search results
    var resultArtists:Array<GZArtist> = []
    var resultAlbums:Array<GZAlbum> = []
    var resultTracks:Array<GZTrack> = []
    
    var configuredCells = NSMutableDictionary()

    // item used for query in detailed screen
    var selectedArtist:GZArtist?
    var selectedAlbum:GZAlbum?
    var selectedTrack:GZTrack?
    let perPage = 3
    
    var selectedRow:Int?
    // delegate object for previous controller
    var FeedVCDelegate:GZSearchViewController = GZSearchViewController()
    
    var searchIsPending:Bool = false
    var searchIsEnded:Bool = false
    var searchNoResults:Bool = false
    
    let searchQueue:NSOperationQueue = NSOperationQueue()
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

//-------------------------------------------------------------
// MARK: - ViewController Life Cycle
extension GZSearchResultsController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var activityIndicatorFrame = CGRect()
        activityIndicatorFrame.origin.x = (self.view.frame.size.width / 2) - (activityIndicatorFrame.size.width / 2)
        activityIndicatorFrame.origin.y = (self.view.frame.size.height / 3) - (activityIndicatorFrame.size.height / 2)
        activityIndicator.frame = activityIndicatorFrame
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(self.activityIndicator)
        activityIndicator.stopAnimating()
        
        // cell for search suggestion (simple one)
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: kGZConstants.cellGenericId)
        
        // cell for search results (advanced)
        let nibTrackAdvanced = UINib (nibName: kGZConstants.trackAdvancedCell, bundle: nil)
        self.tableView.registerNib(nibTrackAdvanced, forCellReuseIdentifier: kGZConstants.trackAdvancedCell)
        
        // cell for alerts
        let alertNib = UINib(nibName: kGZConstants.GZAlertTableViewCell, bundle: nil)
        self.tableView.registerNib(alertNib, forCellReuseIdentifier: kGZConstants.GZAlertTableViewCell)
    }
    
    override func viewDidDisappear(animated: Bool) {
        clearData()
    }
}

//-------------------------------------------------------------
// MARK: - TableViewController Delegate
extension GZSearchResultsController {
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (searchIsEnded) {
            // search results
            return kGZConstants.advancedCellHeight
        }
        else if (searchNoResults) {
            return kGZConstants.playlistCellHeight
        }
        else {
            // search suggestions
            return kGZConstants.defaultCellHeight
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        selectedRow = indexPath.row
        // hide keyboard
        FeedVCDelegate.searchController?.searchBar.resignFirstResponder()
        // add selected string to search field and refresh search results with advanced layout
        if (searchNoResults || searchIsPending) {
            return
        }
        if (searchIsEnded)
        {
            if (indexPath.section == 1 )
            {
                // FeedVCDelegate.searchController?.searchBar.text = artistsArray[indexPath.row].name
                selectedArtist = self.resultArtists[indexPath.row]
                FeedVCDelegate.performSegueWithIdentifier(kGZConstants.toArtistFromSearchResults, sender: self)
            }
            else if (indexPath.section == 2 )
            {
                selectedAlbum = self.resultAlbums[indexPath.row]
                FeedVCDelegate.performSegueWithIdentifier(kGZConstants.toAlbumFromSearchResults, sender: self)
            }
            else if (indexPath.section == 3)
            {
                selectedTrack = self.resultTracks[indexPath.row]
                guard !(selectedTrack!.sourceID.isEmpty) else {
                    return
                }
                for viewController:UIViewController in FeedVCDelegate.tabBarController!.viewControllers! {
                    if (viewController.isKindOfClass(GZTrackViewController)) {
                        let trackController = viewController as! GZTrackViewController
                        FeedVCDelegate.tabBarController?.selectedViewController = trackController
                        trackController.loadTracksToPlayer(atIndex: selectedRow!, playlist: self.resultTracks)
                    }
                }
            }
        }
        else
        {
            var currentQuery = ""
            if (indexPath.section == 1 )
            {
                selectedArtist = self.resultArtists[indexPath.row]
                FeedVCDelegate.searchController?.searchBar.text = selectedArtist!.name
                currentQuery = selectedArtist!.name
            }
            else if (indexPath.section == 2 )
            {
                selectedAlbum = self.resultAlbums[indexPath.row]
                FeedVCDelegate.searchController?.searchBar.text = selectedAlbum!.title
                currentQuery = selectedAlbum!.title
            }
            else if (indexPath.section == 3 )
            {
                selectedTrack = self.resultTracks[indexPath.row]
                FeedVCDelegate.searchController?.searchBar.text = selectedTrack!.title
                currentQuery = selectedTrack!.title
            }
            self.endCurrentSearch(withQuery: currentQuery)
        }
    }
}

//-------------------------------------------------------------
// MARK: - TableViewController DataSource
extension GZSearchResultsController {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (searchIsEnded) {
            if (section == 1 && self.resultArtists.count != 0) {
                return kGZConstants.artists
            }
            else if (section == 2 && self.resultAlbums.count != 0) {
                return kGZConstants.albums
            }
            else if (section == 3 && self.resultTracks.count != 0) {
                return kGZConstants.tracks
            }
        }
        return ""
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ( section == 0 && searchNoResults ) {
            return 1
        }
        else if ( section == 1 ) {
            return resultArtists.count
        }
        else if ( section == 2 ) {
            return resultAlbums.count
        }
        else if ( section == 3 ) {
            return resultTracks.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // advanced and simple layout
        if (searchNoResults) {
            let cell = tableView.dequeueReusableCellWithIdentifier("GZAlertTableViewCell", forIndexPath: indexPath) as! GZAlertTableViewCell
            cell.configureSelfWithAlert(GZTableViewAlert.NoSearchResults)
            return cell
        }
        else if (searchIsEnded) {
            // search results
            let cell = tableView.dequeueReusableCellWithIdentifier("trackAdvancedCell", forIndexPath: indexPath) as! GZtrackAdvancedCellTableViewCell
            configureAdvancedCell(tableViewCell: cell, indexPath: indexPath)
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
            configureSimpleCell(tableViewCell: cell, indexPath: indexPath)
            return cell
        }
    }
    
    // MARK: configure a cell of search results
    func configureAdvancedCell( tableViewCell cell : GZtrackAdvancedCellTableViewCell, indexPath : NSIndexPath ) -> Void
    {
        if ( indexPath.section == 1 ) {
            let resultArtist = self.resultArtists[indexPath.row]
            cell.configureSelfWithDataModel(resultArtist.imageMedium, title: resultArtist.name, artist: "", noMedia: false)
        }
        else if ( indexPath.section == 2 ) {
            let resultAlbum = self.resultAlbums[indexPath.row]
            cell.configureSelfWithDataModel(resultAlbum.imageMedium, title: resultAlbum.title, artist: resultAlbum.artistName, noMedia: false)
        }
        else if ( indexPath.section == 3 ) {
            let requestTrack = self.resultTracks[indexPath.row]
            if ( self.configuredCells.valueForKey(String(indexPath.row)) != nil ) {
                let state = self.configuredCells.valueForKey(String(indexPath.row)) as! String
                if (state == "configured") {
                    let noMedia = requestTrack.sourceID.isEmpty
                    cell.configureSelfWithDataModel(requestTrack.imageMedium, title: requestTrack.title, artist: requestTrack.artistName, noMedia: noMedia)
                }
            }
            else {
                cell.activityIndicator.startAnimating()
                GZTracksManager.getTracksYTMedia(withTrack: requestTrack, success: { (resultTrack) in
                    
                    self.resultTracks[indexPath.row] = resultTrack
                    let noMedia = resultTrack.sourceID.isEmpty
                    cell.configureSelfWithDataModel(resultTrack.imageMedium, title: resultTrack.title, artist: resultTrack.artistName, noMedia: noMedia)
                    self.configuredCells.setValue("configured", forKey: String(indexPath.row))
                    
                    }, failure: { (sourceTrack) in
                        
                        self.resultTracks[indexPath.row] = sourceTrack
                        let noMedia = sourceTrack.sourceID.isEmpty
                        cell.configureSelfWithDataModel(sourceTrack.imageMedium, title: sourceTrack.title, artist: sourceTrack.artistName, noMedia: noMedia)
                        self.configuredCells.setValue("configured", forKey: String(indexPath.row))
                        
                })
            }
            
        }
    }
    
    // MARK: configure a cell of search advices
    func configureSimpleCell( tableViewCell cell : UITableViewCell, indexPath : NSIndexPath ) -> Void
    {
        // set transparent cell selection style
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.selectedBackgroundView?.backgroundColor = UIColor.clearColor()
        
        if ( indexPath.section == 1 ) {
            let resultArtist = self.resultArtists[indexPath.row]
            cell.textLabel?.text = resultArtist.name
        }
        else if ( indexPath.section == 2 ) {
            let resultAlbum = self.resultAlbums[indexPath.row]
            cell.textLabel?.text = resultAlbum.title
        }
        else if ( indexPath.section == 3 ) {
            let resultTrack = self.resultTracks[indexPath.row]
            cell.textLabel?.text = resultTrack.title
        }
    }
}

//-------------------------------------------------------------
// MARK: - General function for performing search on lastfm api
extension GZSearchResultsController {
    func searchContent( withQuery query: String )
    {
        clearData()
        print("a new search is launched with a query \(query)")
        print("queue items: \(GZQueueManager.searchQueue.operations)")
        self.searchIsPending = true
        self.activityIndicator.startAnimating()
        
        GZArtistManager.getArtistsLF(query, perPage: perPage, pageNumber: 1) { (resultArtists) -> Void in
            self.resultArtists = resultArtists

            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Fade)
            })
            
            GZAlbumManager.getAlbumsLF(query, perPage: self.perPage, pageNumber: 1) { (resultAlbums) -> Void in
                self.resultAlbums = resultAlbums
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadSections(NSIndexSet(index: 2), withRowAnimation: .Fade)
                })
                
                GZTracksManager.getTracksLF(query, perPage: self.perPage, pageNumber: 1) { (resultTracks) -> Void in
                    self.resultTracks = resultTracks
                    self.searchIsPending = false
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.activityIndicator.stopAnimating()
                        self.tableView.reloadSections(NSIndexSet(index: 3), withRowAnimation: .Fade)
                    })
                    
                    if (self.resultArtists.count == 0 && self.resultAlbums.count == 0 && self.resultTracks.count == 0) {
                        self.searchNoResults = true
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.tableView.reloadData()
                        })
                    }
                    
                }
            }
        }

    }
}

//-------------------------------------------------------------
// MARK: - Clear all data within search results controller
extension GZSearchResultsController {
    func clearData() {
        GZQueueManager.searchQueue.cancelAllOperations()
        self.activityIndicator.stopAnimating()
        self.resultArtists = []
        self.resultAlbums = []
        self.resultTracks = []
        self.configuredCells.removeAllObjects()
        self.searchIsEnded = false
        self.searchNoResults = false
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
        })
    }
}

//-------------------------------------------------------------
// MARK: - Ending search and caching the search query
extension GZSearchResultsController {
    func endCurrentSearch( withQuery query: String ) {
        self.searchIsEnded = true
        
        // cache the selected search query
        guard ( query != "" || query != " " ) else {
            return
        }
        let uiContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        GZCacheManager.cacheSearchQuery(withQuery: query, andPropagateToContext: uiContext)
        try? uiContext.save()
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            // stop activity indicator when the table begins updating
            self.activityIndicator.stopAnimating()
            self.tableView.reloadData()
        })
    }
}