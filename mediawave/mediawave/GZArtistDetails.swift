//
//  GZArtistDetails.swift
//  mediawave
//
//  Created by George Zinyakov on 1/10/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import UIKit

class GZArtistDetails: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var artistBio: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var bgImageHeight: NSLayoutConstraint!
    
    var artistQuery:String = ""
    var artistInfo:GZLFObject = GZLFObject()
    var artistTags:Array<GZLFObject> = Array<GZLFObject>()
    var artistAlbums:Array<GZLFObject> = Array<GZLFObject>()
    var artistTracks:Array<GZLFObject> = Array<GZLFObject>()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // setting the table view
        self.tableView.dataSource = self
        self.tableView.delegate = self
        // cell for tracks and albums
        let nibTrackAdvanced = UINib (nibName: "trackAdvancedCell", bundle: nil)
        self.tableView.registerNib(nibTrackAdvanced, forCellReuseIdentifier: "trackAdvancedCell")
        let nibTagCell = UINib (nibName: "GZTagCollectionViewCell", bundle: nil)
        self.collectionView.registerNib(nibTagCell, forCellWithReuseIdentifier: "GZTagCollectionViewCell")
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(true)
        
        GZPostManager.getArtistInfoLF(artistQuery) { (infoPack) -> Void in
            self.artistInfo = infoPack
            if ( self.artistInfo.mbid != nil ) {
                if (self.artistInfo.avatarMedium != nil) {
                    self.bgImage.sd_setImageWithURL(self.artistInfo.avatarMedium)
                }
                GZPostManager.getArtistTopTagsLF(self.artistQuery, perPage: 6, pageNumber: 1) { (tags) -> Void in
                    self.artistTags = tags
                    GZPostManager.getArtistTopAlbumsLF(self.artistQuery, perPage: 3, pageNumber: 1) { (albums) -> Void in
                        self.artistAlbums = albums
                        GZPostManager.getArtistTopTracksLF(self.artistQuery, perPage: 6, pageNumber: 1) { (tracks) -> Void in
                            self.artistTracks = tracks
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.artistName.text = self.artistInfo.name
                                self.artistBio.text = self.artistInfo.summary
                                self.title = self.artistInfo.name
                                self.tableView.reloadData()
                            })
                        }
                    }
                }
            }
        }
        
    }
    
    // MARK: Table View functions
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return "Top Albums"
        }
        else {
            return "Top Tracks"
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return self.artistAlbums.count
        }
        else {
            return self.artistTracks.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("trackAdvancedCell", forIndexPath: indexPath) as! GZtrackAdvancedCellTableViewCell
        if ( artistAlbums.count != 0 && artistTags.count != 0 && artistTracks.count != 0 ) {
            if ( indexPath.section == 0) {
                cell.trackName.text = artistAlbums[indexPath.row].name
                cell.trackAvatar.sd_setImageWithURL(artistAlbums[indexPath.row].avatarMedium)
            }
            else {
                cell.trackName.text = artistTracks[indexPath.row].name
                cell.trackAvatar.sd_setImageWithURL(artistTracks[indexPath.row].avatarMedium)
            }
            tableViewHeight.constant = tableView.contentSize.height
            self.bgImageHeight.constant = self.collectionView.frame.origin.y + self.collectionViewHeight.constant + self.tableViewHeight.constant
        }
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    // MARK: Collection View functions
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return artistTags.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(70.0, 20.0)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("GZTagCollectionViewCell", forIndexPath: indexPath) as! GZTagCollectionViewCell
        cell.configureSelfWithDataModel(self.artistTags[indexPath.row].name!)
        collectionViewHeight.constant = collectionView.contentSize.height
        return cell

    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }

}
