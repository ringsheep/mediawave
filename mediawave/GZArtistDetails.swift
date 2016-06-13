//
//  GZArtistDetails.swift
//  mediawave
//
//  Created by George Zinyakov on 1/10/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import UIKit
import CoreData

class GZArtistDetails: GZTableViewController {
    // item used for query in detailed screen
    var selectedAlbum:GZAlbum?
    
    var artist:GZArtist?
    var selectedRow:Int?
    
    let perPage:Int = 6
    var nextAlbumsPage:Int?
    var nextTracksPage:Int?
    
    var artistAlbums:Array<GZAlbum> = Array<GZAlbum>()
    var artistTracks:Array<GZTrack> = Array<GZTrack>()
    
    var totalAlbumPages:Int = 0
    
    var artistInfoView:UIView?
    var descriptionCell:GZDescriptionTableViewCell?
    
    var didLoadMoreAlbumsStarted:Bool = false
    var isTracksActivityIndicatorNeeded = false
    
    var configuredCells = NSMutableDictionary()
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == kGZConstants.toAlbumFromArtist) {
            let viewController:GZAlbumController = segue.destinationViewController as! GZAlbumController
            viewController.currentAlbum = selectedAlbum
        }
    }
    //
}

//-------------------------------------------------------------
// MARK: - ViewController Life Cycle
extension GZArtistDetails {
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(GZArtistDetails.getArtistData), forControlEvents: .ValueChanged)
        
        // cell for loader
        let nibLoaderCell = UINib(nibName: kGZConstants.GZLoaderTableViewCell, bundle: nil)
        self.tableView.registerNib(nibLoaderCell, forCellReuseIdentifier: kGZConstants.GZLoaderTableViewCell)
        
        // cell for artist description
        let nibDescriptionAdvanced = UINib (nibName: kGZConstants.GZDescriptionTableViewCell, bundle: nil)
        self.tableView.registerNib(nibDescriptionAdvanced, forCellReuseIdentifier: kGZConstants.GZDescriptionTableViewCell)
        
        // cell for albums
        let nibTrackAdvanced = UINib (nibName: kGZConstants.trackAdvancedCell, bundle: nil)
        self.tableView.registerNib(nibTrackAdvanced, forCellReuseIdentifier: kGZConstants.trackAdvancedCell)
        
        // cell for tracks
        let nibTrackSimple = UINib (nibName: kGZConstants.GZtrackSimpleCell, bundle: nil)
        self.tableView.registerNib(nibTrackSimple, forCellReuseIdentifier: kGZConstants.GZtrackSimpleCell)
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
        
        getArtistData()
        
        self.nextTracksPage = 2
        self.nextAlbumsPage = 2
    }
    
    override func viewWillDisappear(animated: Bool) {
        GZQueueManager.searchQueue.cancelAllOperations()
    }
    
    convenience init(horizontalAlignment: FSQCollectionViewHorizontalAlignment, verticalAlignment: FSQCollectionViewVerticalAlignment, itemSpacing: CGFloat, lineSpacing: CGFloat, insets: UIEdgeInsets) {
        self.init()
    }
}

//-------------------------------------------------------------
// MARK: - TableViewController Delegate
extension GZArtistDetails {
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        if ( indexPath == NSIndexPath(forRow: (self.artistAlbums.count), inSection: 1 ) ) {
            return kGZConstants.defaultCellHeight
        }
        else if ( indexPath.section == 1 ) {
            return kGZConstants.advancedCellHeight
        }
        else if ( indexPath.section == 2 ) {
            return kGZConstants.simpleCellHeight
        }
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        self.selectedRow = indexPath.row
        // if "Load more" was pressed
        let loaderIndexPath = NSIndexPath(forRow: (self.artistAlbums.count), inSection: 1 )
        if ( indexPath == loaderIndexPath && nextAlbumsPage < totalAlbumPages ) {
            self.didLoadMoreAlbumsStarted = true
            self.tableView.reloadRowsAtIndexPaths([loaderIndexPath], withRowAnimation: .None)
            GZAlbumManager.getAlbumsLF(byArtistMbID: (self.artist?.mbID)!, perPage: self.perPage, pageNumber: nextAlbumsPage!) { (resultAlbums, totalPages) -> Void in
                
                var newRowsIndexArray = Array<NSIndexPath>()
                for (index, element) in resultAlbums.enumerate() {
                    let newIndex = index + self.artistAlbums.count
                    let newIndexPath = NSIndexPath(forRow: newIndex, inSection: 1)
                    newRowsIndexArray.append(newIndexPath)
                }
                
                self.artistAlbums.appendContentsOf(resultAlbums)
                self.totalAlbumPages = totalPages
                self.nextAlbumsPage! += 1
                
                let newLoaderIndexPath = NSIndexPath(forRow: (self.artistAlbums.count), inSection: 1 )
                self.didLoadMoreAlbumsStarted = false
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.insertRowsAtIndexPaths(newRowsIndexArray, withRowAnimation: .Fade)
                    self.tableView.reloadRowsAtIndexPaths([newLoaderIndexPath], withRowAnimation: .None)
                })
            }
        }
        // if an album was selected
        else if ( indexPath.section == 1 && indexPath.row != self.artistAlbums.count ) {
            selectedAlbum = self.artistAlbums[indexPath.row]
            self.performSegueWithIdentifier(kGZConstants.toAlbumFromArtist, sender: self)
        }
        // if a track was selected
        else if ( indexPath.section == 2 ) {
            let track = self.artistTracks[indexPath.row]
            guard !(track.sourceID.isEmpty) else {
                return
            }
            for viewController:UIViewController in self.tabBarController!.viewControllers! {
                if (viewController.isKindOfClass(GZTrackViewController)) {
                    let trackController = viewController as! GZTrackViewController
                    self.tabBarController?.selectedViewController = trackController
                    trackController.loadTracksToPlayer(atIndex: selectedRow!, playlist: self.artistTracks)
                }
            }
        }
    }
}

//-------------------------------------------------------------
// MARK: - TableViewController DataSource
extension GZArtistDetails {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if (section == 1 && self.artistAlbums.count != 0)
        {
            return kGZConstants.topalbums
        }
        else if (section == 2 && self.artistTracks.count != 0)
        {
            return kGZConstants.toptracks
        }
        return ""
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (section == 0)
        {
            return 1
        }
        if (section == 1 && self.artistAlbums.count != 0) {
            if (self.nextAlbumsPage <= self.totalAlbumPages)
            {
                return self.artistAlbums.count + 1
            }
            else
            {
                return self.artistAlbums.count
            }
        }
        else if (section == 2)
        {
            return self.artistTracks.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        // infinite scroll for tracks
        if ( indexPath.row == (self.artistTracks.count - 1) && indexPath.section == 2 && nextTracksPage != 1 ) {
            GZTracksManager.getTracksLF(byArtistMbID: (self.artist?.mbID)!, perPage: self.perPage, pageNumber: nextTracksPage!) { (resultTracks) -> Void in
                
                var newRowsIndexArray = Array<NSIndexPath>()
                for (index, element) in resultTracks.enumerate() {
                    let newIndex = index + self.artistTracks.count
                    let newIndexPath = NSIndexPath(forRow: newIndex, inSection: 2)
                    newRowsIndexArray.append(newIndexPath)
                }
                
                self.nextTracksPage! += 1
                self.artistTracks.appendContentsOf(resultTracks)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.insertRowsAtIndexPaths(newRowsIndexArray, withRowAnimation: .Fade)
                })
            }
        }
        // last cell in albums section - load more button
        else if ( indexPath.row == self.artistAlbums.count && indexPath.section == 1 ) {
            let loaderCell:GZLoaderTableViewCell = (self.tableView.dequeueReusableCellWithIdentifier(kGZConstants.GZLoaderTableViewCell, forIndexPath: indexPath) as? GZLoaderTableViewCell)!
            if (didLoadMoreAlbumsStarted) {
                loaderCell.activityIndicator.startAnimating()
            }
            else {
                loaderCell.activityIndicator.stopAnimating()
            }
            return loaderCell
        }
        // artist description cell
        else if ( indexPath.section == 0 ) {
            let descriptionCell:GZDescriptionTableViewCell = (self.tableView.dequeueReusableCellWithIdentifier(kGZConstants.GZDescriptionTableViewCell) as? GZDescriptionTableViewCell)!
            descriptionCell.updateFonts()
            descriptionCell.configureSelfWithDataModel(self.artist!.name, avatar: self.artist!.imageMedium, description: self.artist!.summary)
            
            descriptionCell.setNeedsUpdateConstraints()
            descriptionCell.updateConstraintsIfNeeded()
            
            return descriptionCell
        }
        // album cell
        else if ( indexPath.section == 1 ) {
            let cell = tableView.dequeueReusableCellWithIdentifier(kGZConstants.trackAdvancedCell, forIndexPath: indexPath) as! GZtrackAdvancedCellTableViewCell
            configureAdvancedCell(tableViewCell: cell, indexPath: indexPath)
            return cell
        }
        // track's cell
        let cell = tableView.dequeueReusableCellWithIdentifier(kGZConstants.GZtrackSimpleCell, forIndexPath: indexPath) as! GZTrackSimpleTableViewCell
        configureSimpleCell(tableViewCell: cell, indexPath: indexPath)
        return cell
    }
    
    // MARK: configure an album's cell
    private func configureAdvancedCell( tableViewCell cell : GZtrackAdvancedCellTableViewCell, indexPath : NSIndexPath ) -> Void
    {
        let model = self.artistAlbums[indexPath.row]
        cell.title.numberOfLines = 2
        cell.configureSelfWithDataModel(model.imageMedium, title: model.title, artist: "", noMedia: false)
    }
    
    // MARK: configure a track's cell
    private func configureSimpleCell( tableViewCell cell : GZTrackSimpleTableViewCell, indexPath : NSIndexPath ) -> Void
    {
        let track = self.artistTracks[indexPath.row]
        if ( (configuredCells.valueForKey(String(indexPath.row))) != nil) {
            let state = configuredCells.valueForKey(String(indexPath.row)) as! String
            if (state == "configured") {
                let noMedia = track.sourceID.isEmpty
                cell.configureSelfWithDataModel(track.title, imageMedium: track.imageMedium, noMedia: noMedia)
            }
        }
        else {
            cell.activityIndicator.startAnimating()
            GZTracksManager.getTracksYTMedia(withTrack: track, success: { (resultTrack) in
                
                self.artistTracks[indexPath.row] = resultTrack
                let noMedia = self.artistTracks[indexPath.row].sourceID.isEmpty
                cell.configureSelfWithDataModel(resultTrack.title, imageMedium: resultTrack.imageMedium, noMedia: noMedia)
                self.configuredCells.setValue("configured", forKey: String(indexPath.row))
                
                }, failure: { (sourceTrack) in
                    
                    self.artistTracks[indexPath.row] = sourceTrack
                    let noMedia = self.artistTracks[indexPath.row].sourceID.isEmpty
                    cell.configureSelfWithDataModel(sourceTrack.title, imageMedium: sourceTrack.imageMedium, noMedia: noMedia)
                    self.configuredCells.setValue("configured", forKey: String(indexPath.row))
                    
            })
            
        }
    }
}

//-------------------------------------------------------------
// MARK: - Get Artist's Data
extension GZArtistDetails {
    @objc private func getArtistData() {
        if (GZQueueManager.searchQueue.operations.count != 0) {
            GZQueueManager.searchQueue.cancelAllOperations()
        }
        GZArtistManager.getArtistsInfoLF(artist!, success: { (resultArtist) -> Void in
            self.artist! = resultArtist
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
            })

        })
        GZAlbumManager.getAlbumsLF(byArtistMbID: (self.artist?.mbID)!, perPage: (self.perPage)/2, pageNumber: 1) { (resultAlbums, totalPages) -> Void in
            self.artistAlbums = resultAlbums
            self.totalAlbumPages = totalPages
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Fade)
            })
            
        }
        GZTracksManager.getTracksLF(byArtistMbID: (self.artist?.mbID)!, perPage: self.perPage, pageNumber: 1) { (resultTracks) -> Void in
            self.artistTracks = resultTracks
            
            self.configuredCells.removeAllObjects()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadSections(NSIndexSet(index: 2), withRowAnimation: .Fade)
            })
            
        }
        self.refreshControl?.endRefreshing()
    }
}