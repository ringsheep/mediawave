//
//  GZdownloadLastfmAlbumsByQuery.swift
//  mediawave
//
//  Created by George Zinyakov on 3/15/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import Foundation

class GZdownloadLastfmAlbumsByQuery: NSOperation {
    
    var internetTask:NSURLSessionDataTask?
    var searchQuery:String?

    var perPage: Int?
    var pageNumber: Int?
    var successBlock: (resultAlbums : Array<GZAlbum>) -> Void
    
    init(
        withSearchQuery searchQuery: String,
        perPage: Int,
        pageNumber: Int,
        success: (resultAlbums : Array<GZAlbum>) -> Void
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
        print("GZdownloadLastfmAlbumsByQuery launched")
        internetTask = GZAPI_WRAPPER.getAllLastfmAlbumsByQuery(searchQuery!, perPage: perPage!, pageNumber: pageNumber!, success: { (jsonResponse) -> Void in
            
            var resultAlbums:Array<GZAlbum> = Array<GZAlbum>()
            let albums:Array<JSON> = jsonResponse["results"]["albummatches"]["album"].arrayValue
            
            for ( var i:Int64 = 0 ; i < Int64(albums.count) ; i++ )
            {
                if ( self.cancelled ) {
                    break
                }
                let downloadedAlbum = albums[Int(i)]
                let newArtistName = downloadedAlbum["artist"].stringValue
                let newTitle = downloadedAlbum["name"].stringValue
                let newMbID = downloadedAlbum["mbid"].stringValue
                let jsonImages = downloadedAlbum["image"].arrayValue
                let newImageMedium = jsonImages[1]["#text"].stringValue
                
                guard (newMbID != "") else {
                    continue
                }
                let newAlbum = GZAlbum(withMbID: newMbID, title: newTitle, imageMedium: newImageMedium, artistName: newArtistName)
                resultAlbums.append(newAlbum)
            }
            if ( self.cancelled ) {
                return
            }
            print("GZdownloadLastfmAlbumsByQuery finished")
            self.successBlock(resultAlbums: resultAlbums)
            dispatch_semaphore_signal(semaphore)
            
                }) { () -> Void in
                    dispatch_semaphore_signal(semaphore)
            }
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    }
    
}
