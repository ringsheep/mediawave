//
//  GZAlbumController.swift
//  mediawave
//
//  Created by George Zinyakov on 1/19/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import UIKit

class GZAlbumController: GZTableViewController {
    
    var currentAlbum:GZAlbum?
    var currentAlbumTracks:Array<GZTrack> = []
    var configuredCells = NSMutableDictionary()
    
    var selectedRow:Int?
}

//-------------------------------------------------------------
// MARK: - ViewController Life Cycle
extension GZAlbumController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(GZAlbumController.getAlbumData), forControlEvents: .ValueChanged)
        
        let nibTrackSimple = UINib (nibName: kGZConstants.GZtrackSimpleCell, bundle: nil)
        self.tableView.registerNib(nibTrackSimple, forCellReuseIdentifier: kGZConstants.GZtrackSimpleCell)
        
        let nibDescriptionAdvanced = UINib (nibName: kGZConstants.GZDescriptionTableViewCell, bundle: nil)
        self.tableView.registerNib(nibDescriptionAdvanced, forCellReuseIdentifier: kGZConstants.GZDescriptionTableViewCell)
        
        guard ( !(currentAlbum!.mbID.isEmpty) ) else {
            return
        }
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
        
        getAlbumData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        GZQueueManager.searchQueue.cancelAllOperations()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//-------------------------------------------------------------
// MARK: - TableView DataSource
extension GZAlbumController {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return currentAlbumTracks.count
        }
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if ( indexPath.section == 0 ) {
            let descriptionCell:GZDescriptionTableViewCell = (self.tableView.dequeueReusableCellWithIdentifier(kGZConstants.GZDescriptionTableViewCell) as? GZDescriptionTableViewCell)!
            descriptionCell.title.numberOfLines = 2
            descriptionCell.updateFonts()
            descriptionCell.configureSelfWithDataModel(self.currentAlbum!.title, avatar: self.currentAlbum!.imageMedium, description: "")
            
            descriptionCell.setNeedsUpdateConstraints()
            descriptionCell.updateConstraintsIfNeeded()
            
            return descriptionCell
        }
        let cell = tableView.dequeueReusableCellWithIdentifier(kGZConstants.GZtrackSimpleCell, forIndexPath: indexPath) as! GZTrackSimpleTableViewCell
        configureSimpleCell(tableViewCell: cell, indexPath: indexPath)
        return cell
    }
    
    private func configureSimpleCell( tableViewCell cell : GZTrackSimpleTableViewCell, indexPath : NSIndexPath ) -> Void
    {
        currentAlbumTracks[indexPath.row].imageMedium = currentAlbum!.imageMedium
        let track = self.currentAlbumTracks[indexPath.row]
        if ( self.configuredCells.valueForKey(String(indexPath.row)) != nil )  {
            let state = self.configuredCells.valueForKey(String(indexPath.row)) as! String
            if ( state == "configured" ) {
                let noMedia = track.sourceID.isEmpty
                cell.configureSelfWithDataModel(track.title, imageMedium: track.imageMedium, noMedia: noMedia)
            }
        }
        else {
            cell.activityIndicator.startAnimating()
            GZTracksManager.getTracksYTMedia(withTrack: track, success: { (resultTrack) -> Void in
                self.currentAlbumTracks[indexPath.row] = resultTrack
                let noMedia = resultTrack.sourceID.isEmpty
                cell.configureSelfWithDataModel(resultTrack.title, imageMedium: resultTrack.imageMedium, noMedia: noMedia)
            })
        }
    }
}

//-------------------------------------------------------------
// MARK: - TableView Delegate
extension GZAlbumController {
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return kGZConstants.simpleCellHeight
        }
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            return
        }
        selectedRow = indexPath.row
        for viewController:UIViewController in self.tabBarController!.viewControllers! {
            if (viewController.isKindOfClass(GZTrackViewController)) {
                let trackController = viewController as! GZTrackViewController
                self.tabBarController?.selectedViewController = trackController
                trackController.loadTracksToPlayer(atIndex: selectedRow!, playlist: self.currentAlbumTracks)
            }
        }
    }
}

//-------------------------------------------------------------
// MARK: - Procedure for getting and refreshing data
extension GZAlbumController {
    @objc private func getAlbumData() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
        })
        GZTracksManager.getTracksLF(byAlbumMbID: (currentAlbum?.mbID)!) { (resultTracks) -> Void in
            self.currentAlbumTracks = resultTracks
            self.configuredCells.removeAllObjects()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Fade)
            })
        }
        self.refreshControl?.endRefreshing()
    }
}