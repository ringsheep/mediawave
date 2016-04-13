//
//  GZFeedViewController.swift
//  mediawave
//
//  Created by George Zinyakov on 2/5/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import UIKit

class GZFeedViewController: GZTableViewController {
    
    var selectedTags:Array<GZLFTag> = Array<GZLFTag>()
    var selectedPath:NSIndexPath?
    var playlists:Array<GZPlaylist> = []
    
    let perPage = 10
    var nextPageTokens:Array<String> = Array<String>()
    
    @IBAction func settingsButtonPressed(sender: AnyObject) {
        let appDelegate  = UIApplication.sharedApplication().delegate as! AppDelegate
        let viewController = appDelegate.window!.rootViewController
        if (viewController!.isKindOfClass(GZTagsSelectViewController)) {
            // check if root vc is tag select - then we pop the stack of nav controller
            self.presentingViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
            })
        }
        else {
            // otherwise, we just add tag select to the stack
            self.performSegueWithIdentifier(kGZConstants.toTagsFromFeed, sender: self)
        }
    }

}

//-------------------------------------------------------------
//MARK: - ViewController Life Cycle
extension GZFeedViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = kGZConstants.feedTitle
        self.navigationItem.rightBarButtonItem?.title = kGZConstants.edit
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(GZFeedViewController.refreshData), forControlEvents: .ValueChanged)
        
        let playlistNib = UINib(nibName: kGZConstants.GZPlaylistTableViewCell, bundle: nil)
        self.tableView.registerNib(playlistNib, forCellReuseIdentifier: kGZConstants.GZPlaylistTableViewCell)
        
        getPlaylists(self.perPage)
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
extension GZFeedViewController {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // infinite scroll
        if ( indexPath.row == (self.playlists.count - 1) && nextPageTokens.last != "" ) {
            GZPlaylistManager.getYTPlaylists(self.selectedTags, perPage: self.perPage, nextPageToken: self.nextPageTokens.last!, success: { (resultPlaylists, nextPageToken) -> Void in
                
                var newRowsIndexArray = Array<NSIndexPath>()
                for (index, element) in resultPlaylists.enumerate() {
                    let newIndex = index + self.playlists.count
                    let newIndexPath = NSIndexPath(forRow: newIndex, inSection: 0)
                    newRowsIndexArray.append(newIndexPath)
                }
                self.nextPageTokens.append(nextPageToken)
                self.playlists.appendContentsOf(resultPlaylists)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.insertRowsAtIndexPaths(newRowsIndexArray, withRowAnimation: .Fade)
                })
            })
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(kGZConstants.GZPlaylistTableViewCell, forIndexPath: indexPath) as! GZPlaylistTableViewCell
        configure(tableViewCell: cell, indexPath: indexPath)
        return cell
    }
    
    // MARK: configure a singe cell
    func configure( tableViewCell cell : GZPlaylistTableViewCell, indexPath : NSIndexPath ) -> Void
    {
        let model = self.playlists[indexPath.row]
        cell.configureSelfWithDataModel(model.title, image: NSURL(string: model.imageMedium)!, playlistID: model.playlistID)
    }
}

//-------------------------------------------------------------
// MARK: - TableView Delegate
extension GZFeedViewController {
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedPath = indexPath
        self.performSegueWithIdentifier(kGZConstants.toPlaylistFromFeed, sender: self)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return kGZConstants.playlistCellHeight
    }
}

//-------------------------------------------------------------
// MARK: - Navigation
extension GZFeedViewController {
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == kGZConstants.toPlaylistFromFeed) {
            let viewController:GZTracklistViewController = segue.destinationViewController as! GZTracklistViewController
            let sendedModel = playlists[(selectedPath?.row)!]
            viewController.selectedPlaylist = sendedModel
        }
        else if ( segue.identifier == kGZConstants.toTagsFromFeed ) {
            let viewController:UINavigationController = segue.destinationViewController as! UINavigationController
            let tagsController = viewController.topViewController as! GZTagsSelectViewController
            tagsController.selectedTagsArray = Array<GZLFTag>()
        }
    }
}

//-------------------------------------------------------------
//MARK: - Getting data and refreshing main procedures
extension GZFeedViewController {
    @objc private func getPlaylists( perPage: Int ) {
        // if we have some selected tags, we perform a request for playlists
        if (selectedTags.count != 0) {
            GZPlaylistManager.getYTPlaylists(selectedTags, perPage: perPage, nextPageToken: "", success: { (resultPlaylists, nextPageToken) -> Void in
                self.playlists = resultPlaylists
                self.nextPageTokens.append(nextPageToken)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
                })
                self.refreshControl?.endRefreshing()
            })
        }
    }
    
    @objc private func refreshData() {
        if (GZQueueManager.searchQueue.operations.count != 0) {
            GZQueueManager.searchQueue.cancelAllOperations()
        }
        let numberOfPagesDownloaded = self.nextPageTokens.count
        var totalPerPage = numberOfPagesDownloaded * self.perPage
        if (totalPerPage > 50) {
            totalPerPage = 50
            self.nextPageTokens.removeRange(5...(self.nextPageTokens.count-1))
        }
        getPlaylists(totalPerPage)
    }
}