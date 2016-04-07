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
import AVKit

class GZTrackViewController: UIViewController, YTPlayerViewDelegate {
    
    var currentIndex:Int?
    var currentTracks:Array<GZTrack>?
    var isPlaying:Bool = false
    var isRepeat:Bool = false
    var playlistID:String?
    
    @IBOutlet weak var youtubePlayer: YTPlayerView!
    @IBOutlet weak var volumeView: MPVolumeView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var firstTimeLabel: UILabel!
    @IBOutlet weak var secondTimeLabel: UILabel!
    @IBOutlet weak var trackName: UILabel!
    @IBOutlet weak var trackArtist: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var playButtonOutlet: UIButton!
    @IBOutlet weak var repeatButton: UIButton!
    @IBAction func previousButton(sender: AnyObject) {
        guard ( currentIndex != nil || currentTracks != nil) else {
            return
        }
        if ( currentIndex > 0 ) {
            let newIndex = currentIndex! - 1
            self.loadTracksToPlayer(atIndex: newIndex, playlist: currentTracks!)
        }
    }
    @IBAction func playButton(sender: AnyObject) {
        guard ( currentIndex != nil || currentTracks != nil) else {
            return
        }
        self.playButtonOutlet.selected = !(self.playButtonOutlet.selected)
        if (isPlaying) {
            self.youtubePlayer.pauseVideo()
            isPlaying = false
        }
        else {
            self.youtubePlayer.playVideo()
            isPlaying = true
        }
    }
    @IBAction func nextButton(sender: AnyObject) {
        guard ( currentIndex != nil || currentTracks != nil) else {
            return
        }
        if ( currentIndex < currentTracks!.count ) {
            let newIndex = currentIndex! + 1
            self.loadTracksToPlayer(atIndex: newIndex, playlist: currentTracks!)
        }
    }
    @IBAction func repeatButtonPressed(sender: AnyObject) {
        guard ( currentIndex != nil || currentTracks != nil) else {
            return
        }
        self.repeatButton.selected = !(self.repeatButton.selected)
        isRepeat = !(isRepeat)
    }
    @IBAction func shareButtonPressed(sender: AnyObject) {
        guard ( currentIndex != nil || currentTracks != nil) else {
            return
        }
        self.youtubePlayer.pauseVideo()
        // load specified track from context
        let track = self.currentTracks![currentIndex!]
        
        let message:String = kGZConstants.foundAlert
        let messageURL:NSURL = NSURL(string: kGZConstants.youtubeBaseURL + track.sourceID)!
        
        let activityViewController = UIActivityViewController(activityItems: [message, messageURL], applicationActivities: nil)
        self.navigationController?.presentViewController(activityViewController, animated: true) {
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.youtubePlayer.delegate = self
        self.title = kGZConstants.playerTitle
        
        // time slider settings
        self.timeSlider.value = 0
        self.timeSlider.setThumbImage(UIImage(named: "Control Slider"), forState: UIControlState.Normal)
        let testCGrect = CGRect(x: 40, y: 40, width: 50, height: 10)
        self.timeSlider.thumbRectForBounds(testCGrect, trackRect: testCGrect, value: 10)
        
        // play button settings
        self.playButtonOutlet.setImage(UIImage(named: "Play Filled-50"), forState: UIControlState.Normal)
        self.playButtonOutlet.setImage(UIImage(named: "Pause Filled-50"), forState: UIControlState.Selected)
        
        // repeat button settings
        self.repeatButton.setImage(UIImage(named: "Repeat-50"), forState: UIControlState.Normal)
        self.repeatButton.setImage(UIImage(named: "Repeat-50")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Selected)
        self.repeatButton.tintColor = kGZConstants.mediawaveColor
        
        // shuffle button settings
        self.shareButton.setImage(UIImage(named: "Upload-50"), forState: UIControlState.Normal)
        self.shareButton.setImage(UIImage(named: "Upload-50")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Selected)
        self.shareButton.tintColor = kGZConstants.mediawaveColor
        
        // volume view settings
        volumeView.backgroundColor = UIColor.clearColor()
        volumeView.showsVolumeSlider = true
        volumeView.showsRouteButton = true
        volumeView.tintColor = kGZConstants.mediawaveColor
        
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
            isPlaying = false
            if (isRepeat) {
                self.youtubePlayer.stopVideo()
                self.youtubePlayer.playVideo()
                return
            }
            if ( currentIndex < currentTracks?.count ) {
                let newIndex = currentIndex! + 1
                self.loadTracksToPlayer(atIndex: newIndex, playlist: currentTracks!)
            }
        }
        else if ( state == YTPlayerState.Playing ) {
            self.playButtonOutlet.selected = true
            isPlaying = true
        }
        else if ( state == YTPlayerState.Paused ) {
            self.playButtonOutlet.selected = false
            isPlaying = false
        }
    }
    
    @IBAction func onTimeSliderChange(sender: AnyObject) {
        let seekTime:Float = Float(self.youtubePlayer.duration()) * self.timeSlider.value
        self.youtubePlayer.seekToSeconds(seekTime, allowSeekAhead: true)
    }
    
}

extension GZTrackViewController {
    func loadTracksToPlayer( atIndex index: Int, playlist: Array<GZTrack> ) {
        
        guard ( playlist.count != 0 ) else {
            return
        }
        
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
        
        currentIndex = index
        currentTracks = playlist
        
        guard ( currentIndex < currentTracks?.count ) else {
            return
        }
        
        // load specified track from context
        let track = currentTracks![currentIndex!]
        
        // if track's source is empty, then scope to next track if it's available
        guard ( !(track.sourceID.isEmpty) ) else {
            if ( currentIndex < currentTracks?.count ) {
                print("failed to load track")
                let newIndex = currentIndex! + 1
                self.loadTracksToPlayer(atIndex: newIndex, playlist: currentTracks!)
            }
            return
        }
        
        let audioSession:AVAudioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory("AVAudioSessionCategoryPlayback")
        
        // load tracks and update view
        self.youtubePlayer.loadWithVideoId(track.sourceID, playerVars: playerVars as [NSObject : AnyObject])
        let duration = self.youtubePlayer.duration()
        let durationMinutes = Int(duration/60)
        let durationSeconds = Int(duration%60)
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.trackName.text = track.title
            self.trackArtist.text = ""
            self.timeSlider.value = 0
            self.firstTimeLabel.text = "00:00"
            self.secondTimeLabel.text = "\(durationMinutes.format("02")):\(durationSeconds.format("02"))"
        })
        print("track \(track.sourceID) loaded")
        
    }
}

extension Int {
    // function for min:sec output format
    func format(f: String) -> String {
        return NSString(format: "%\(f)d", self) as String
    }
}