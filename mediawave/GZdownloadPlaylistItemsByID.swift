//
//  GZdownloadPlaylistItemsByID.swift
//  mediawave
//
//  Created by George Zinyakov on 3/15/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import Foundation

class GZdownloadPlaylistItemsByID: NSOperation {

    var internetTask:NSURLSessionDataTask?
    var playlistID:String?
    
    var perPage: Int?
    var nextPageToken: String?
    var successBlock: (resultTracks : Array<GZTrack>, nextPageToken : String) -> Void
    
    init(
        withPlaylistID playlistID: String,
        perPage: Int,
        nextPageToken: String,
        success: (resultTracks : Array<GZTrack>, nextPageToken : String) -> Void
        ) {
            self.playlistID = playlistID
            self.perPage = perPage
            self.nextPageToken = nextPageToken
            self.successBlock = success
            super.init()
    }
    
    override func cancel() {
        print("cancelled operation of downloading albums by playlistID")
        internetTask?.cancel()
    }
    
    override func main() {
        let semaphore = dispatch_semaphore_create(0)
        print("GZdownloadPlaylistItemsByID launched")
        internetTask = GZAPI_WRAPPER.getYoutubePlaylistItemsByID(playlistID!, perPage: perPage!, pageToken: nextPageToken!, success: { (jsonResponse) -> Void in
            
            var resultTracks:Array<GZTrack> = Array<GZTrack>()
            let tracks:Array<JSON> = jsonResponse["items"].arrayValue
            let nextPageToken:String = jsonResponse["nextPageToken"].stringValue
            
            for ( var i:Int64 = 0 ; i < Int64(tracks.count) ; i++ )
            {
                if ( self.cancelled ) {
                    break
                }
                let downloadedTrack = tracks[Int(i)]
                let newTitle = downloadedTrack["snippet"]["title"].stringValue
                let newYoutubeID = downloadedTrack["id"].stringValue
                let newSourceID = downloadedTrack["snippet"]["resourceId"]["videoId"].stringValue
                let newImageMedium = downloadedTrack["snippet"]["thumbnails"]["medium"]["url"].stringValue
                guard !(newImageMedium.isEmpty) else {
                    break
                }
                
                guard ( newTitle != "Deleted video" && newTitle != "Private video" ) else {
                    break
                }
                // add to results array
                let newTrack = GZTrack(withMbID: "", sourceID: newSourceID, youtubeID: newYoutubeID, title: newTitle, imageMedium: newImageMedium, artistName: "", playlistID: "", artistMbID: "", albumMbID: "")
                resultTracks.append(newTrack)
            }
            
            if ( self.cancelled ) {
                return
            }
            
            print("GZdownloadPlaylistItemsByID finished")
            self.successBlock(resultTracks: resultTracks, nextPageToken: nextPageToken)
            dispatch_semaphore_signal(semaphore)
            
            }) { () -> Void in
                dispatch_semaphore_signal(semaphore)
        }
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    }
}
