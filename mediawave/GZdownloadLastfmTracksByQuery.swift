//
//  GZdownloadLastfmTracksByQuery.swift
//  mediawave
//
//  Created by George Zinyakov on 3/15/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import Foundation

class GZdownloadLastfmTracksByQuery: NSOperation {
    
    var internetTask:NSURLSessionDataTask?
    var searchQuery:String?
    
    var perPage: Int?
    var pageNumber: Int?
    var successBlock: (resultTracks : Array<GZTrack>) -> Void
    
    init(
        withSearchQuery searchQuery: String,
        perPage: Int,
        pageNumber: Int,
        success: (resultTracks : Array<GZTrack>) -> Void
        ) {
            self.searchQuery = searchQuery
            self.perPage = perPage
            self.pageNumber = pageNumber
            self.successBlock = success
            super.init()
    }
    
    override func cancel() {
        print("cancelled operation of downloading albums by query")
        print("queue items: \(GZQueueManager.searchQueue.operations)")
        internetTask?.cancel()
    }

    override func main() {
        let semaphore = dispatch_semaphore_create(0)
        print("GZdownloadLastfmTracksByQuery launched")
        internetTask = GZAPI_WRAPPER.getAllLastfmTracksByQuery(searchQuery!, perPage: perPage!, pageNumber: pageNumber!, success: { (jsonResponse) -> Void in
            
            var resultTracks:Array<GZTrack> = Array<GZTrack>()
            let tracks:Array<JSON> = jsonResponse["results"]["trackmatches"]["track"].arrayValue
            
            for ( var i:Int64 = 0 ; i < Int64(tracks.count) ; i++ )
            {
                if ( self.cancelled ) {
                    break
                }
                
                let downloadedTrack = tracks[Int(i)]
                let newartistName = downloadedTrack["artist"].stringValue
                let newtitle = downloadedTrack["name"].stringValue
                let newmbID  = downloadedTrack["mbid"].stringValue
                let jsonImages = downloadedTrack["image"].arrayValue
                let newImageMedium = jsonImages[1]["#text"].stringValue
                
                let newTrack = GZTrack(withMbID: newmbID, sourceID: "", youtubeID: "", title: newtitle, imageMedium: newImageMedium, artistName: newartistName, playlistID: "", artistMbID: "", albumMbID: "")
                resultTracks.append(newTrack)
                
            }
            
            if ( self.cancelled ) {
                return
            }
            print("GZdownloadLastfmTracksByQuery finished")
            self.successBlock(resultTracks: resultTracks)
            dispatch_semaphore_signal(semaphore)
            
            }) { () -> Void in
                dispatch_semaphore_signal(semaphore)
        }
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    }
    
}
