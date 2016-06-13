//
//  GZdownloadTracksYTMediaByQuery.swift
//  mediawave
//
//  Created by George Zinyakov on 3/20/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import Foundation

class GZdownloadTracksYTMediaByQuery: NSOperation {
    
    var internetTask:NSURLSessionDataTask?
    var track:GZTrack?
    
    var perPage: Int?
    var pageNumber: Int?
    var successBlock: (resultTrack : GZTrack) -> Void
    var failureBlock: (resultTrack : GZTrack) -> Void
    
    init(
        withTrack track: GZTrack,
        success: (resultTrack : GZTrack) -> Void,
        failure: (resultTrack : GZTrack) -> Void
        ) {
            self.track = track
            self.successBlock = success
            self.failureBlock = failure
            super.init()
    }
    
    override func cancel() {
        print("cancelled operation of downloading track media item by query")
        internetTask?.cancel()
    }
    
    override func main() {
        let semaphore = dispatch_semaphore_create(0)
        print("GZdownloadTracksYTMediaByQuery launched")
        // get source id of the track via youtube search
        let sourceQuery:String = self.track!.artistName + " " + self.track!.title
        internetTask = GZAPI_WRAPPER.getAllYoutubeMediaByQuery(sourceQuery, perPage: 1, pageNumber: 1, success: { (YTjsonResponse) -> Void in
            
            if ( self.cancelled ) {
                return
            }
            
            let YTtracks:Array<JSON> = YTjsonResponse["items"].arrayValue
            
            if (YTtracks.count == 0) {
                
                if ( self.cancelled ) {
                    return
                }
                
                print("GZdownloadTracksYTMediaByQuery finished with no media item")
                self.failureBlock(resultTrack: self.track!)
                dispatch_semaphore_signal(semaphore)
            }
            else {
                let YTtrack = YTtracks[0]
                let YTtitle = YTtrack["snippet"]["title"].stringValue
                var newSourceID = ""
                
                // check if the title of first found video on youtube really contains the name of the artist and the name of the tack
                if ((YTtitle.lowercaseString.rangeOfString(self.track!.artistName.lowercaseString) != nil) && (YTtitle.lowercaseString.rangeOfString(self.track!.title.lowercaseString) != nil)) {
                    newSourceID = YTtrack["id"]["videoId"].stringValue
                }
                let newTrack = GZTrack(withMbID: self.track!.mbID, sourceID: newSourceID, youtubeID: "", title: self.track!.title, imageMedium: self.track!.imageMedium, artistName: self.track!.artistName, playlistID: "", artistMbID: "", albumMbID: "")
                
                if ( self.cancelled ) {
                    return
                }
                
                print("GZdownloadTracksYTMediaByQuery finished")
                self.successBlock(resultTrack: newTrack)
                dispatch_semaphore_signal(semaphore)
            }
            
            }) { () -> Void in
                dispatch_semaphore_signal(semaphore)
        }
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    }
    
}
