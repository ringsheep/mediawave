//
//  GZArtistDetails.swift
//  mediawave
//
//  Created by George Zinyakov on 1/10/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import UIKit

class GZArtistDetails: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var artistBio: UILabel!
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var bgImageHeight: NSLayoutConstraint!
    
    var artistQuery:String = ""
    var artistInfo:GZLFObject = GZLFObject()
    var artistAlbums:Array<GZLFObject> = Array<GZLFObject>()
    var artistTracks:Array<GZLFObject> = Array<GZLFObject>()
    var selectedRow:Int?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // setting the table view
        self.tableView.dataSource = self
        self.tableView.delegate = self
        // cell for tracks and albums
        let nibTrackAdvanced = UINib (nibName: "trackAdvancedCell", bundle: nil)
        self.tableView.registerNib(nibTrackAdvanced, forCellReuseIdentifier: "trackAdvancedCell")
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(true)
        
        GZLastFmSearchManager.getArtistInfoLF(artistQuery) { (infoPack) -> Void in
            self.artistInfo = infoPack
            if ( self.artistInfo.id != nil ) {
                if (self.artistInfo.avatarMedium != nil) {
                    self.bgImage.sd_setImageWithURL(self.artistInfo.avatarMedium)
                }
                GZLastFmSearchManager.getArtistTopAlbumsLF(self.artistQuery, perPage: 3, pageNumber: 1) { (albums) -> Void in
                    GZLastFmSearchManager.getArtistTopTracksLF(self.artistQuery, perPage: 6, pageNumber: 1) { (tracks) -> Void in
                        GZYoutubeSearchManager.getYTMediaItem(tracks, success: { (tracks) -> Void in
                            self.artistAlbums = albums
                            self.artistTracks = tracks
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.artistName.text = self.artistInfo.name
                                self.artistBio.text = self.artistInfo.summary
                                self.title = self.artistInfo.name
                                self.tableView.reloadData()
                            })
                        })
                    }
                }
            }
        }
        
    }
    
    convenience init(horizontalAlignment: FSQCollectionViewHorizontalAlignment, verticalAlignment: FSQCollectionViewVerticalAlignment, itemSpacing: CGFloat, lineSpacing: CGFloat, insets: UIEdgeInsets) {
        self.init()
    }
    
    // MARK: Table View functions
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if (section == 0)
        {
            return "Top Albums"
        }
        else
        {
            return "Top Tracks"
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (section == 0)
        {
            return self.artistAlbums.count
        }
        else
        {
            return self.artistTracks.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("trackAdvancedCell", forIndexPath: indexPath) as! GZtrackAdvancedCellTableViewCell
        cell.trackArtist.text = ""
        if ( artistAlbums.count != 0 && artistTracks.count != 0 )
        {
            if ( indexPath.section == 0)
            {
                cell.trackName.text = artistAlbums[indexPath.row].name
                cell.trackAvatar.sd_setImageWithURL(artistAlbums[indexPath.row].avatarMedium)
            }
            else
            {
                cell.trackName.text = artistTracks[indexPath.row].name
                cell.trackAvatar.sd_setImageWithURL(artistTracks[indexPath.row].avatarMedium)
            }
            tableViewHeight.constant = tableView.contentSize.height
        }
        // set transparent cell selection style
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.selectedBackgroundView?.backgroundColor = UIColor.clearColor()
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 70.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if ( indexPath.section == 0)
        {
            selectedRow = indexPath.row
            self.performSegueWithIdentifier("toAlbumFromArtist", sender: self)
        }
        else {
            selectedRow = indexPath.row
            for viewController:UIViewController in self.tabBarController!.viewControllers! {
                if (viewController.isKindOfClass(GZTrackViewController)) {
                    let trackController = viewController as! GZTrackViewController
                    self.tabBarController?.selectedViewController = trackController
                    trackController.loadTrack(artistTracks[selectedRow!].sourceID!, indexPath: indexPath, tracksCount: self.tableView.numberOfRowsInSection(1) )
                }
            }
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "toAlbumFromArtist") {
            let viewController:GZAlbumUIViewController = segue.destinationViewController as! GZAlbumUIViewController
            viewController.currentAlbum = artistAlbums[selectedRow!]
        }
        else if (segue.identifier == "toTrackFromArtist") {
            let viewController:GZTrackViewController = segue.destinationViewController as! GZTrackViewController
            viewController.loadTrack(artistTracks[selectedRow!].sourceID!, indexPath: NSIndexPath(), tracksCount: self.tableView.numberOfRowsInSection(1) )
        }
        
    }
    //
}
