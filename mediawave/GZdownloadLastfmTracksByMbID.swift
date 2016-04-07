//
//  GZdownloadLastfmTracksByMbID.swift
//  mediawave
//
//  Created by George Zinyakov on 3/15/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import Foundation

class GZdownloadLastfmTracksByMbID: NSOperation {
    
    var internetTask:NSURLSessionDataTask?
    var mbID:String?
    
    var perPage: Int?
    var pageNumber: Int?
    var successBlock: (resultTracks : Array<GZTrack>) -> Void
    
    init(
        withMbID mbID: String,
        perPage: Int,
        pageNumber: Int,
        success: (resultTracks : Array<GZTrack>) -> Void
        ) {
            self.mbID = mbID
            self.perPage = perPage
            self.pageNumber = pageNumber
            self.successBlock = success
            super.init()
    }
    
    override func cancel() {
        print("cancelled operation of downloading albums by query")
        internetTask?.cancel()
    }
    
    override func main() {
        let semaphore = dispatch_semaphore_create(0)
        print("GZdownloadLastfmTracksByMbID launched")
        internetTask = GZAPI_WRAPPER.getTopLastfmTracksByArtist(mbID!, perPage: perPage!, pageNumber: pageNumber!, success: { (jsonResponse) -> Void in
            
            var resultTracks:Array<GZTrack> = Array<GZTrack>()
            let tracks:Array<JSON> = jsonResponse["toptracks"]["track"].arrayValue
            
            for ( var i:Int64 = 0 ; i < Int64(tracks.count) ; i++ )
            {
                if ( self.cancelled ) {
                    break
                }
                let downloadedTrack = tracks[Int(i)]
                let newArtistName = downloadedTrack["artist"]["name"].stringValue
                let newTitle = downloadedTrack["name"].stringValue
                let newMbID = downloadedTrack["mbid"].stringValue
                let jsonImages = downloadedTrack["image"].arrayValue
                let newImageMedium = jsonImages[1]["#text"].stringValue
                
                let newTrack = GZTrack(withMbID: newMbID, sourceID: "", youtubeID: "", title: newTitle, imageMedium: newImageMedium, artistName: newArtistName, playlistID: "", artistMbID: "", albumMbID: "")
                resultTracks.append(newTrack)
            }
            if ( self.cancelled ) {
                return
            }
            
            print("GZdownloadLastfmTracksByMbID finished")
            self.successBlock(resultTracks: resultTracks)
            dispatch_semaphore_signal(semaphore)
            
            }) { () -> Void in
                dispatch_semaphore_signal(semaphore)
        }
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    }
    
}
