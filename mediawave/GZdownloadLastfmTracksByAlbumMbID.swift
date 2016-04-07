//
//  GZdownloadLastfmTracksByAlbumMbID.swift
//  mediawave
//
//  Created by George Zinyakov on 3/23/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import Foundation

class GZdownloadLastfmTracksByAlbumMbID: NSOperation {
    
    var internetTask:NSURLSessionDataTask?
    var mbID:String?
    var successBlock: (resultTracks : Array<GZTrack>) -> Void
    
    init(
        withMbID mbID: String,
        success: (resultTracks : Array<GZTrack>) -> Void
        ) {
            self.mbID = mbID
            self.successBlock = success
            super.init()
    }
    
    override func cancel() {
        print("cancelled operation of downloading tracks by album mbid")
        internetTask?.cancel()
    }
    
    override func main() {
        let semaphore = dispatch_semaphore_create(0)
        print("GZdownloadLastfmTracksByAlbumMbID launched")
        internetTask = GZAPI_WRAPPER.getTopLastfmTracksByAlbum(mbID!, success: { (jsonResponse) -> Void in
            
            var resultTracks:Array<GZTrack> = Array<GZTrack>()
            let tracks:Array<JSON> = jsonResponse["album"]["tracks"]["track"].arrayValue
            let jsonImages = jsonResponse["album"]["image"].arrayValue
            
            for ( var i:Int64 = 0 ; i < Int64(tracks.count) ; i++ )
            {
                if ( self.cancelled ) {
                    break
                }
                let downloadedTrack = tracks[Int(i)]
                let newArtistName = downloadedTrack["artist"]["name"].stringValue
                let newArtistMbID = downloadedTrack["artist"]["mbid"].stringValue
                let newTitle = downloadedTrack["name"].stringValue
                let newImageMedium = jsonImages[1]["#text"].stringValue
                
                let newTrack = GZTrack(withMbID: "", sourceID: "", youtubeID: "", title: newTitle, imageMedium: newImageMedium, artistName: newArtistName, playlistID: "", artistMbID: newArtistMbID, albumMbID: "")
                resultTracks.append(newTrack)
            }
            if ( self.cancelled ) {
                return
            }
            
            print("GZdownloadLastfmTracksByAlbumMbID finished")
            self.successBlock(resultTracks: resultTracks)
            dispatch_semaphore_signal(semaphore)
            
            }) { () -> Void in
                dispatch_semaphore_signal(semaphore)
        }
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    }
    
}
