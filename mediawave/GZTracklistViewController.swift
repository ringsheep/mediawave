//
//  GZTracklistViewController.swift
//  mediawave
//
//  Created by George Zinyakov on 1/16/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import UIKit
import CoreData

class GZTracklistViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var sendedID:Int64?
    var currentPlaylist:GZPlaylist?
    var playlistItems:Array<GZLFObject> = Array<GZLFObject>()
    var selectedRow:Int?
    var headerImage:UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        // nib for head cell
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        let playlistNib = UINib(nibName: "GZPlaylistTableViewCell", bundle: nil)
        self.tableView.registerNib(playlistNib, forCellReuseIdentifier: "GZPlaylistTableViewCell")
        
        // nib for track cell
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        let trackNib = UINib(nibName: "GZtrackSimpleCell", bundle: nil)
        self.tableView.registerNib(trackNib, forCellReuseIdentifier: "GZtrackSimpleCell")
        
        self.tableView.separatorColor = UIColor.clearColor()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        print("sended id is \(sendedID)")
        
        GZPlaylistFabric.loadExistingPlaylist(withID: sendedID!, success: { (existingPlaylist) -> Void in
            self.currentPlaylist = existingPlaylist
            }) { () -> Void in
        }
        
        guard ( currentPlaylist != nil ) else {
            return
        }
        GZYoutubeSearchManager.getYTPlaylistItems(currentPlaylist!.playlistID, perPage: 10, pageNumber: 1) { (tracks) -> Void in
            self.playlistItems = tracks
            
            // creating the background in seperate context
            UIGraphicsBeginImageContext(self.view.frame.size)
            let bgImage:UIImageView = UIImageView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height))
            bgImage.sd_setImageWithURL(NSURL(string: self.currentPlaylist!.imageMedium))
            let image:UIImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                //                    self.tracklistTitle.text = self.currentTracklist.name
                //                    self.tracklistDescription.text = self.currentTracklist.summary
                //                    self.view.backgroundColor = UIColor(patternImage: blurredImage!)
                self.tableView.reloadData()
            })
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        //self.performSegueWithIdentifier("toTrackFromTracklist", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ( section == 0) {
            return 1
        }
        else {
            return playlistItems.count
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
//        if ( headerImage != nil ) {
//            let blurredImage = headerImage!.applyBlurWithRadius(self.scrollView.contentOffset.y, tintColor: UIColor.blackColor(), saturationDeltaFactor: 0)
//            headerImage = blurredImage
//            self.tableView.reloadData()
//        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if ( indexPath.section == 0) {
            return 210.0
        }
        else {
            return 50.0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if ( indexPath.section == 0) {
            let cell = tableView.dequeueReusableCellWithIdentifier("GZPlaylistTableViewCell", forIndexPath: indexPath) as! GZPlaylistTableViewCell
            //cell.configureSelfWithDataModel(currentTracklist)
            headerImage = cell.playlistBackground.image
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("GZtrackSimpleCell", forIndexPath: indexPath) as! GZTrackSimpleTableViewCell
            cell.configureSelfWithDataModel(playlistItems[indexPath.row])
            self.tableViewHeight.constant = self.tableView.contentSize.height
            // set transparent cell selection style
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.selectedBackgroundView?.backgroundColor = UIColor.clearColor()
//            if ( (self.tableView.frame.origin.y + self.tableViewHeight.constant) < UIScreen.mainScreen().bounds.height ) {
//                self.tracklistBGImageHeight.constant = UIScreen.mainScreen().bounds.height
//            }
//            else {
//                self.tracklistBGImageHeight.constant = self.tableView.frame.origin.y + self.tableViewHeight.constant
//            }
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if ( indexPath.section == 0) {
            
        }
        else {
            selectedRow = indexPath.row
            for viewController:UIViewController in self.tabBarController!.viewControllers! {
                if (viewController.isKindOfClass(GZTrackViewController)) {
                    let trackController = viewController as! GZTrackViewController
                    self.tabBarController?.selectedViewController = trackController
                    trackController.loadTracks(playlistItems, index: selectedRow!)
                }
            }
            //self.performSegueWithIdentifier("toTrackFromTracklist", sender: self)
        }
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "toTrackFromTracklist") {
            let viewController:GZTrackViewController = segue.destinationViewController as! GZTrackViewController
            viewController.loadTracks(playlistItems, index: selectedRow!)
        }
        else if (segue.identifier == "toArtistFromTracklist") {
            let viewController:GZArtistDetails = segue.destinationViewController as! GZArtistDetails
        }
        
    }

}
