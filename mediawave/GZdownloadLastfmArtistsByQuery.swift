//
//  GZdownloadLastfmArtistsByQuery.swift
//  mediawave
//
//  Created by George Zinyakov on 3/14/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import Foundation

class GZdownloadLastfmArtistsByQuery: NSOperation {
    
    var internetTask:NSURLSessionDataTask?
    var searchQuery:String?
    var perPage: Int?
    var pageNumber: Int?
    var successBlock: (resultArtists : Array<GZArtist>) -> Void
    
    init( withSearchQuery searchQuery: String, perPage: Int, pageNumber: Int, success: (resultArtists : Array<GZArtist>) -> Void ) {
        self.searchQuery = searchQuery
        self.perPage = perPage
        self.pageNumber = pageNumber
        self.successBlock = success
        super.init()
    }
    
    override func cancel() {
        print("cancelled operation of downloading artists by query")
        print("queue items: \(GZQueueManager.searchQueue.operations)")
        internetTask?.cancel()
    }
    
    override func main() {
        let semaphore = dispatch_semaphore_create(0)
        print("GZdownloadLastfmArtistsByQuery launched")
        internetTask = GZAPI_WRAPPER.getAllLastfmArtistsByQuery(searchQuery!, perPage: perPage!, pageNumber: pageNumber!, success: { (jsonResponse) -> Void in
            
            var resultArtists:Array<GZArtist> = Array<GZArtist>()
            let downloadedArtists:Array<JSON> = jsonResponse["results"]["artistmatches"]["artist"].arrayValue
            
            for ( var i = 0 ; i < downloadedArtists.count ; i++ )
            {
                if ( self.cancelled ) {
                    break
                }
                
                let downloadedArtist = downloadedArtists[Int(i)]
                let newName = downloadedArtist["name"].stringValue
                let newMbID = downloadedArtist["mbid"].stringValue
                let jsonImages = downloadedArtist["image"].arrayValue
                let newImageMedium = jsonImages[1]["#text"].stringValue
                guard (newMbID != "") else {
                    continue
                }
                
                let newArtist = GZArtist(withMbID: newMbID, name: newName, summary: "", imageMedium: newImageMedium)
                resultArtists.append(newArtist)
            }
            
            if ( self.cancelled ) {
                return
            }
            print("GZdownloadLastfmArtistsByQuery finished")
            self.successBlock(resultArtists: resultArtists)
            dispatch_semaphore_signal(semaphore)
            
            }) { () -> Void in
                
            dispatch_semaphore_signal(semaphore)
        }
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    }
    
}
