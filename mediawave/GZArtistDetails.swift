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
    var nextAlbumsPage:Int?
    var nextTracksPage:Int?
    
    var artistAlbums:Array<GZAlbum> = Array<GZAlbum>()
    var artistTracks:Array<GZTrack> = Array<GZTrack>()
    
    var totalAlbumPages:Int = 0
    
    var artistInfoView:UIView?
    var descriptionCell:GZDescriptionTableViewCell?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // cell for loader
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: kGZConstants.cellGenericId)
        
        let nibDescriptionAdvanced = UINib (nibName: kGZConstants.GZDescriptionTableViewCell, bundle: nil)
        self.tableView.registerNib(nibDescriptionAdvanced, forCellReuseIdentifier: kGZConstants.GZDescriptionTableViewCell)
        
        // cell for albums
        let nibTrackAdvanced = UINib (nibName: kGZConstants.trackAdvancedCell, bundle: nil)
        self.tableView.registerNib(nibTrackAdvanced, forCellReuseIdentifier: kGZConstants.trackAdvancedCell)
        
        // cell for tracks
        let nibTrackSimple = UINib (nibName: kGZConstants.GZtrackSimpleCell, bundle: nil)
        self.tableView.registerNib(nibTrackSimple, forCellReuseIdentifier: kGZConstants.GZtrackSimpleCell)
        
        self.nextTracksPage = 1
        self.nextAlbumsPage = 1
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0

        GZArtistManager.getArtistsInfoLF(artist!, success: { (resultArtist) -> Void in
            self.artist! = resultArtist
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
            })
        })
        GZAlbumManager.getAlbumsLF(byArtistMbID: (self.artist?.mbID)!, perPage: 3, pageNumber: nextAlbumsPage!) { (resultAlbums, totalPages) -> Void in
            self.artistAlbums = resultAlbums
            self.totalAlbumPages = totalPages
            self.nextAlbumsPage! += 1
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
            })
        }
        GZTracksManager.getTracksLF(byArtistMbID: (self.artist?.mbID)!, perPage: 6, pageNumber: nextTracksPage!) { (resultTracks) -> Void in
            self.artistTracks = resultTracks
            self.nextTracksPage! += 1
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
            })
        }

    }
    
    override func viewWillDisappear(animated: Bool) {
        GZQueueManager.searchQueue.cancelAllOperations()
    }
    
    convenience init(horizontalAlignment: FSQCollectionViewHorizontalAlignment, verticalAlignment: FSQCollectionViewVerticalAlignment, itemSpacing: CGFloat, lineSpacing: CGFloat, insets: UIEdgeInsets) {
        self.init()
    }
    
    // MARK: Table View functions
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // number of sections: first header section + albums section if there are albums + tracks section if there are tracks
        return Int(!(self.artist == nil)) + Int(!(self.artistAlbums.isEmpty)) + Int(!(self.artistTracks.isEmpty))
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if (section == 1)
        {
            return kGZConstants.topalbums
        }
        else if (section == 2)
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
        else if (section == 1 && self.nextAlbumsPage != self.totalAlbumPages)
        {
            return self.artistAlbums.count + 1
        }
        else if (section == 1 && self.nextAlbumsPage == self.totalAlbumPages)
        {
            return self.artistAlbums.count
        }
        else if (section == 2)
        {
            return self.artistTracks.count
        }
        return 0
    }
    
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
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if ( indexPath.row == (self.artistTracks.count - 1) && indexPath.section == 2 && nextTracksPage != 1 ) {
            GZTracksManager.getTracksLF(byArtistMbID: (self.artist?.mbID)!, perPage: 6, pageNumber: nextTracksPage!) { (resultTracks) -> Void in
                self.nextTracksPage! += 1
                self.artistTracks.appendContentsOf(resultTracks)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                })
            }
        }
        else if ( indexPath.row == self.artistAlbums.count && indexPath.section == 1 ) {
            // last cell in albums section - load more button
            let cell = tableView.dequeueReusableCellWithIdentifier(kGZConstants.cellGenericId, forIndexPath: indexPath)
            cell.textLabel?.text = "Load more"
            // fontsize
            return cell
        }
        else if ( indexPath.section == 0 ) {
            let descriptionCell:GZDescriptionTableViewCell = (self.tableView.dequeueReusableCellWithIdentifier(kGZConstants.GZDescriptionTableViewCell) as? GZDescriptionTableViewCell)!
            descriptionCell.updateFonts()
            descriptionCell.configureSelfWithDataModel(self.artist!.name, avatar: self.artist!.imageMedium, description: self.artist!.summary)
            
            descriptionCell.setNeedsUpdateConstraints()
            descriptionCell.updateConstraintsIfNeeded()
            
            return descriptionCell
        }
        else if ( indexPath.section == 1 ) {
            let cell = tableView.dequeueReusableCellWithIdentifier(kGZConstants.trackAdvancedCell, forIndexPath: indexPath) as! GZtrackAdvancedCellTableViewCell
            configureAdvancedCell(tableViewCell: cell, indexPath: indexPath)
            return cell
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(kGZConstants.GZtrackSimpleCell, forIndexPath: indexPath) as! GZTrackSimpleTableViewCell
        configureSimpleCell(tableViewCell: cell, indexPath: indexPath)
        return cell
    }
    
    // MARK: configure a cell of search results
    func configureAdvancedCell( tableViewCell cell : GZtrackAdvancedCellTableViewCell, indexPath : NSIndexPath ) -> Void
    {
        let model = self.artistAlbums[indexPath.row]
        cell.title.numberOfLines = 2
        cell.configureSelfWithDataModel(model.imageMedium, title: model.title, artist: "", noMedia: false)
    }
    
    func configureSimpleCell( tableViewCell cell : GZTrackSimpleTableViewCell, indexPath : NSIndexPath ) -> Void
    {
        let track = self.artistTracks[indexPath.row]
        if ( !(cell.isConfigured) ) {
            GZTracksManager.getTracksYTMedia(withTrack: track, success: { (resultTrack) -> Void in
                self.artistTracks[indexPath.row] = resultTrack
                let noMedia = self.artistTracks[indexPath.row].sourceID.isEmpty
                cell.configureSelfWithDataModel(resultTrack.title, imageMedium: resultTrack.imageMedium, noMedia: noMedia)
            })
        }
        else {
            let noMedia = track.sourceID.isEmpty
            cell.configureSelfWithDataModel(track.title, imageMedium: track.imageMedium, noMedia: noMedia)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        self.selectedRow = indexPath.row
        if ( indexPath == NSIndexPath(forRow: (self.artistAlbums.count), inSection: 1 ) && nextAlbumsPage < totalAlbumPages ) {
            // if "Load more" was pressed
            GZAlbumManager.getAlbumsLF(byArtistMbID: (self.artist?.mbID)!, perPage: 6, pageNumber: nextAlbumsPage!) { (resultAlbums, totalPages) -> Void in
                self.artistAlbums.appendContentsOf(resultAlbums)
                self.totalAlbumPages = totalPages
                self.nextAlbumsPage! += 1
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                })
            }
        }
        else if ( indexPath.section == 1 && indexPath.row != self.artistAlbums.count ) {
            selectedAlbum = self.artistAlbums[indexPath.row]
            self.performSegueWithIdentifier(kGZConstants.toAlbumFromArtist, sender: self)
        }
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