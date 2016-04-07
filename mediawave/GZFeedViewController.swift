//
//  GZFeedViewController.swift
//  mediawave
//
//  Created by George Zinyakov on 2/5/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import UIKit
import CoreData

class GZFeedViewController: GZTableViewController {
    
    var selectedTags:Array<GZLFTag> = Array<GZLFTag>()
    var selectedPath:NSIndexPath?
    var playlists:Array<GZPlaylist> = []
    let perPage = 9
    var nextPageToken:String?
    
    @IBAction func settingsButtonPressed(sender: AnyObject) {
        let appDelegate  = UIApplication.sharedApplication().delegate as! AppDelegate
        let viewController = appDelegate.window!.rootViewController
        if (viewController!.isKindOfClass(GZTagsSelectViewController)) {
            // check if root vc is tag select - then we pop the stack of nav controller
//            self.navigationController?.popToViewController(viewController, animated: true)
            self.presentingViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
            })
        }
        else {
            // otherwise, we just add tag select to the stack
            self.performSegueWithIdentifier(kGZConstants.toTagsFromFeed, sender: self)
        }
    }
    
    // MARK: Fetch Results Controller Wrapper
    var fetchResultsControllerWrapper:FetchedResultsControllerDelegate?

    // MARK: View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = kGZConstants.feedTitle
        self.navigationItem.rightBarButtonItem?.title = kGZConstants.edit
        
        let playlistNib = UINib(nibName: kGZConstants.GZPlaylistTableViewCell, bundle: nil)
        self.tableView.registerNib(playlistNib, forCellReuseIdentifier: kGZConstants.GZPlaylistTableViewCell)
        
        // if we have some selected tags, we perform a request for playlists
        if (selectedTags.count != 0) {
            GZPlaylistManager.getYTPlaylists(selectedTags, perPage: self.perPage, nextPageToken: "", success: { (resultPlaylists, nextPageToken) -> Void in
                self.playlists = resultPlaylists
                self.nextPageToken = nextPageToken
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
                })
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

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return kGZConstants.playlistCellHeight
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // infinite scroll
        if ( indexPath.row == (self.playlists.count - 1) && nextPageToken != "" ) {
            GZPlaylistManager.getYTPlaylists(self.selectedTags, perPage: self.perPage, nextPageToken: self.nextPageToken!, success: { (resultPlaylists, nextPageToken) -> Void in
                self.nextPageToken = nextPageToken
                self.playlists.appendContentsOf(resultPlaylists)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedPath = indexPath
        self.performSegueWithIdentifier(kGZConstants.toPlaylistFromFeed, sender: self)
    }

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
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