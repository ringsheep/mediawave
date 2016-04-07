//
//  GZTracklistViewController.swift
//  mediawave
//
//  Created by George Zinyakov on 1/16/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import UIKit

class GZTracklistViewController: GZTableViewController {
    
    var selectedRow:Int?
    var selectedPlaylist:GZPlaylist?
    var playlistTracks:Array<GZTrack> = []
    var nextPageToken:String?

    // MARK: View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // nib for head cell
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: kGZConstants.cellGenericId)
        let playlistNib = UINib(nibName: kGZConstants.GZPlaylistTableViewCell, bundle: nil)
        self.tableView.registerNib(playlistNib, forCellReuseIdentifier: kGZConstants.GZPlaylistTableViewCell)
        
        // nib for track cell
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: kGZConstants.cellGenericId)
        let trackNib = UINib(nibName: kGZConstants.GZtrackSimpleCell, bundle: nil)
        self.tableView.registerNib(trackNib, forCellReuseIdentifier: kGZConstants.GZtrackSimpleCell)
        
        GZTracksManager.getYTPlaylistItems(selectedPlaylist!.playlistID, perPage: 10, nextPageToken: "") { (resultTracks, nextPageToken) -> Void in
            self.playlistTracks = resultTracks
            self.nextPageToken = nextPageToken
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
            })
        }
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        GZQueueManager.searchQueue.cancelAllOperations()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    // MARK: Back button is pressed
    override func willMoveToParentViewController(parent: UIViewController?) {
        if parent == nil {
        }
    }
    
    // MARK: table view data source functions
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playlistTracks.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // playlist tracks section with list of tracks
        return kGZConstants.simpleCellHeight
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // infinite scroll
        if ( indexPath.row == (self.playlistTracks.count - 1) && nextPageToken != "" ) {
            GZTracksManager.getYTPlaylistItems(selectedPlaylist!.playlistID, perPage: 10, nextPageToken: nextPageToken!) { (resultTracks, nextPageToken) -> Void in
                self.nextPageToken = nextPageToken
                self.playlistTracks.appendContentsOf(resultTracks)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                })
            }
        }
        
        // playlist tracks section with list of tracks
        let cell = tableView.dequeueReusableCellWithIdentifier(kGZConstants.GZtrackSimpleCell, forIndexPath: indexPath) as! GZTrackSimpleTableViewCell
        configureTrackCell(tableViewCell: cell, indexPath: indexPath)
        return cell
    }
    
    // MARK: configure a playlist info cell
    func configureInfoCell( tableViewCell cell : GZPlaylistTableViewCell, indexPath : NSIndexPath ) -> Void
    {
        cell.configureSelfWithDataModel(selectedPlaylist!.title, image: NSURL(string: (selectedPlaylist!.imageMedium))!, playlistID: selectedPlaylist!.playlistID)
    }
    
    // MARK: configure a track cell
    func configureTrackCell( tableViewCell cell : GZTrackSimpleTableViewCell, indexPath : NSIndexPath ) -> Void
    {
        let track = self.playlistTracks[indexPath.row]
        cell.configureSelfWithDataModel(track.title, imageMedium: track.imageMedium, noMedia: track.sourceID.isEmpty)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // playlist tracks section with list of tracks
        selectedRow = indexPath.row
        for viewController:UIViewController in self.tabBarController!.viewControllers! {
            if (viewController.isKindOfClass(GZTrackViewController)) {
                let trackController = viewController as! GZTrackViewController
                self.tabBarController?.selectedViewController = trackController
                trackController.loadTracksToPlayer(atIndex: selectedRow!, playlist: self.playlistTracks)
            }
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCellWithIdentifier(kGZConstants.GZPlaylistTableViewCell) as! GZPlaylistTableViewCell
        configureInfoCell(tableViewCell: cell, indexPath: NSIndexPath(forRow: 0, inSection: 0))
        let view = UIView(frame: cell.frame)
        view.addSubview(cell)
        return view
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 210.0
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }

}
