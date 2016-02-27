//
//  GZAlbumUIViewController.swift
//  mediawave
//
//  Created by George Zinyakov on 1/19/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import UIKit

class GZAlbumUIViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var albumName: UILabel!
    @IBOutlet weak var albumDescription: UILabel!
    @IBOutlet weak var albumTracks: UITableView!
    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var albumTracksHeight: NSLayoutConstraint!
    
    var currentAlbum:GZLFObject = GZLFObject()
    var currentAlbumTracks:Array<GZLFObject> = Array<GZLFObject>()
    var selectedRow:Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        // setting the table view
        self.albumTracks.dataSource = self
        self.albumTracks.delegate = self
        // Do any additional setup after loading the view.
        
        let nibTrackSimple = UINib (nibName: "GZtrackSimpleCell", bundle: nil)
        self.albumTracks.registerNib(nibTrackSimple, forCellReuseIdentifier: "GZtrackSimpleCell")

        if (currentAlbum.id != nil) {
            GZLastFmSearchManager.getAlbumTracksLF(self.currentAlbum.id!) { (tracks) -> Void in
                GZYoutubeSearchManager.getYTMediaItem(tracks, success: { (tracks) -> Void in
                    self.currentAlbumTracks = tracks
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.albumName.text = self.currentAlbum.name
                        self.albumDescription.text = self.currentAlbum.summary
                        self.albumImage.sd_setImageWithURL(self.currentAlbum.avatarMedium)
                        self.albumTracks.reloadData()
                    })
                })
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    convenience init(horizontalAlignment: FSQCollectionViewHorizontalAlignment, verticalAlignment: FSQCollectionViewVerticalAlignment, itemSpacing: CGFloat, lineSpacing: CGFloat, insets: UIEdgeInsets) {
        self.init()
    }
    
    // MARK: Table view functions
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentAlbumTracks.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedRow = indexPath.row
        for viewController:UIViewController in self.tabBarController!.viewControllers! {
            if (viewController.isKindOfClass(GZTrackViewController)) {
                let trackController = viewController as! GZTrackViewController
                self.tabBarController?.selectedViewController = trackController
                trackController.loadTrack(currentAlbumTracks[selectedRow!].sourceID!, indexPath: indexPath, tracksCount: self.albumTracks.numberOfRowsInSection(1) )
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("GZtrackSimpleCell", forIndexPath: indexPath) as! GZTrackSimpleTableViewCell
        currentAlbumTracks[indexPath.row].avatarMedium = currentAlbum.avatarMedium
        //cell.configureSelfWithDataModel(currentAlbumTracks[indexPath.row])
        self.albumTracksHeight.constant = self.albumTracks.contentSize.height
        // set transparent cell selection style
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.selectedBackgroundView?.backgroundColor = UIColor.clearColor()
        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "toTrackFromAlbum") {
            let viewController:GZTrackViewController = segue.destinationViewController as! GZTrackViewController
            viewController.loadTrack(currentAlbumTracks[selectedRow!].sourceID!, indexPath: NSIndexPath(), tracksCount: self.albumTracks.numberOfRowsInSection(1) )
        }
    }

}
