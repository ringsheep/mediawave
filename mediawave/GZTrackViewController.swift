//
//  GZTrackViewController.swift
//  mediawave
//
//  Created by George Zinyakov on 1/16/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import UIKit
import MediaPlayer
import AudioToolbox

class GZTrackViewController: UIViewController, YTPlayerViewDelegate {
    @IBOutlet weak var shuffleButton: UIButton!
    @IBOutlet weak var youtubePlayer: YTPlayerView!
    @IBOutlet weak var firstTimeLabel: UILabel!
    @IBOutlet weak var secondTimeLabel: UILabel!
    @IBOutlet weak var trackName: UILabel!
    @IBOutlet weak var trackArtist: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var playButtonOutlet: UIButton!
    @IBOutlet weak var repeatButton: UIButton!
    @IBAction func previousButton(sender: AnyObject) {
        if (self.currentIndexPath?.row > 0) {
            let newIndex:NSInteger = (self.currentIndexPath?.indexAtPosition(self.currentIndexPath!.row - 1))!
            self.currentIndexPath?.indexPathByRemovingLastIndex().indexPathByAddingIndex(newIndex)
            self.loadTrack(self.currentSourceID!, indexPath: self.currentIndexPath!, tracksCount: self.tracksCount!)
        }
    }
    @IBAction func playButton(sender: AnyObject) {
        self.playButtonOutlet.selected = !(self.playButtonOutlet.selected)
        if (self.playButtonOutlet.selected) {
            self.youtubePlayer.playVideo()
        }
        else {
            self.youtubePlayer.pauseVideo()
        }
    }
    @IBAction func nextButton(sender: AnyObject) {
        if ( self.currentIndexPath?.row < (self.tracksCount! - 1) ) {
            let newIndex:NSInteger = (self.currentIndexPath?.indexAtPosition(self.currentIndexPath!.row + 1))!
            self.currentIndexPath?.indexPathByRemovingLastIndex().indexPathByAddingIndex(newIndex)
            self.loadTrack(self.currentSourceID!, indexPath: self.currentIndexPath!, tracksCount: self.tracksCount!)
        }
    }
    @IBAction func shuffleButtonPressed(sender: AnyObject) {
        
    }
    @IBAction func repeatButtonPressed(sender: AnyObject) {
        self.repeatButton.selected = !(self.repeatButton.selected)
    }
    @IBAction func shareButtonPressed(sender: AnyObject) {
        let message:String = "Найдено в mediawave:"
        let messageURL:NSURL = NSURL(string: "http://www.youtube.com/watch?v=" + currentSourceID!)!
        
        let activityViewController = UIActivityViewController(activityItems: [message, messageURL], applicationActivities: nil)
        self.navigationController?.presentViewController(activityViewController, animated: true) {
            
        }
    }

    var currentSourceID:String?
    var currentIndexPath:NSIndexPath?
    var tracksCount:Int?
    var sendedID:String?
    let mediawaveColor = UIColor(red: 255/255, green: 96/255, blue: 152/255, alpha: 1)
    let volumeView:MPVolumeView = MPVolumeView()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.youtubePlayer.delegate = self
        
        // time slider settings
        self.timeSlider.value = 0
        self.timeSlider.setThumbImage(UIImage(named: "Control Slider"), forState: UIControlState.Normal)
        
        // play button settings
        self.playButtonOutlet.setImage(UIImage(named: "Play Filled-50"), forState: UIControlState.Normal)
        self.playButtonOutlet.setImage(UIImage(named: "Pause Filled-50"), forState: UIControlState.Selected)

        // repeat button settings
        self.repeatButton.setImage(UIImage(named: "Repeat-50"), forState: UIControlState.Normal)
        self.repeatButton.setImage(UIImage(named: "Repeat-50")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Selected)
        self.repeatButton.tintColor = mediawaveColor
        
        // shuffle button settings
        self.shuffleButton.setImage(UIImage(named: "Shuffle-50"), forState: UIControlState.Normal)
        self.shuffleButton.setImage(UIImage(named: "Shuffle-50")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Selected)
        self.shuffleButton.tintColor = mediawaveColor
        
//        for view:UIView in volumeView.subviews {
//            if ( view.classForCoder.description() == "MPVolumeSlider" ) {
//                volumeSlider = view as! UISlider
//            }
//        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func playerView(playerView: YTPlayerView!, didPlayTime playTime: Float) {
        // set value for progress and update time slider
        let duration = Float(self.youtubePlayer.duration())
        let progress:Float = playTime / duration
        let left:Float = duration - playTime
        self.timeSlider.setValue(progress, animated: true)
        
        // set elapsed and left time on labels
        let elapsedMinutes = Int(playTime/60)
        let elapsedSeconds = Int(playTime%60)
        let leftMinutes = Int(left/60)
        let leftSeconds = Int(left%60)
        self.firstTimeLabel.text = "\(elapsedMinutes.format("02")):\(elapsedSeconds.format("02"))"
        self.secondTimeLabel.text = "\(leftMinutes.format("02")):\(leftSeconds.format("02"))"
    }
    
    func playerViewDidBecomeReady(playerView: YTPlayerView!) {
        // launch video as soon as it became ready
        self.youtubePlayer.playVideo()
    }
    
    func playerViewPreferredWebViewBackgroundColor(playerView: YTPlayerView!) -> UIColor! {
        // cool black background
        return UIColor.blackColor()
    }
    
    func playerView(playerView: YTPlayerView!, didChangeToState state: YTPlayerState) {
        // if ended, repeat if repeat button is selected
        if ( state == YTPlayerState.Ended) {
            self.playButtonOutlet.selected = false
            if (self.repeatButton.selected) {
                self.youtubePlayer.stopVideo()
                self.youtubePlayer.playVideo()
            }
            if ( self.currentIndexPath?.row < (self.tracksCount! - 1) ) {
                let newIndex:NSInteger = (self.currentIndexPath?.indexAtPosition(self.currentIndexPath!.row + 1))!
                self.currentIndexPath?.indexPathByRemovingLastIndex().indexPathByAddingIndex(newIndex)
                self.loadTrack( self.currentSourceID!, indexPath: self.currentIndexPath! , tracksCount: self.tracksCount! )
            }
        }
        else if ( state == YTPlayerState.Playing ) {
            self.playButtonOutlet.selected = true
        }
        else if ( state == YTPlayerState.Paused ) {
            self.playButtonOutlet.selected = false
        }
    }
    
    @IBAction func onTimeSliderChange(sender: AnyObject) {
        let seekTime:Float = Float(self.youtubePlayer.duration()) * self.timeSlider.value
        self.youtubePlayer.seekToSeconds(seekTime, allowSeekAhead: true)
    }

}

extension GZTrackViewController {
    func loadTrack( sourceID: String, indexPath: NSIndexPath, tracksCount: Int ) {
        
        self.currentSourceID = sourceID
        self.currentIndexPath = indexPath
        self.tracksCount = tracksCount
        
        // player javascript variables
        let playerVars:NSDictionary = [
            "playsinline" : 1,
            "autoplay" : 1,
            "autohide" : 1,
            "showinfo" : 0,
            "modestbranding" : 1,
            "controls" : 0,
            "origin" : "http://localhost"
        ]
        
        // load tracks and update view
        if ( sourceID != "" ) {
            self.youtubePlayer.loadWithVideoId(sourceID, playerVars: playerVars as [NSObject : AnyObject])
            let duration = self.youtubePlayer.duration()
            let durationMinutes = Int(duration/60)
            let durationSeconds = Int(duration%60)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                self.trackName.text = self.currentTracks[self.currentIndex].name
//                self.trackArtist.text = self.currentTracks[self.currentIndex].artist
                self.timeSlider.value = 0
                self.firstTimeLabel.text = "00:00"
                self.secondTimeLabel.text = "\(durationMinutes.format("02")):\(durationSeconds.format("02"))"
            })
            print("track \(sourceID) loaded")
        }
        else if ( self.currentIndexPath?.row < (self.tracksCount! - 1) ) {
            print("failed to load track")
            let newIndex:NSInteger = (self.currentIndexPath?.indexAtPosition(self.currentIndexPath!.row + 1))!
            self.currentIndexPath?.indexPathByRemovingLastIndex().indexPathByAddingIndex(newIndex)
            self.loadTrack( sourceID, indexPath: self.currentIndexPath! , tracksCount: self.tracksCount! )
        }
    }
}

extension Int {
    // function for min:sec output format
    func format(f: String) -> String {
        return NSString(format: "%\(f)d", self) as String
    }
}