//
//  GZArtistManager.swift
//  mediawave
//
//  Created by George Zinyakov on 2/16/16.
//  Copyright © 2016 George Zinyakov. All rights reserved.
//

import UIKit

class GZArtistManager: GZQueueManager {
    static var artistManagerQueue:OperationQueue = NSOperationQueue()
    
    static var downloadLastfmArtistsByQuery:GZdownloadLastfmArtistsByQuery?
    static var downloadLastfmArtistsInfoByMbID:GZdownloadLastfmArtistsInfoByMbID?
}

// MARK: Search artists by query
extension GZArtistManager {
    class func getArtistsLF(searchQuery: String, perPage: Int, pageNumber: Int, success: ( _ resultArtists : Array<GZArtist> ) -> Void)
    {
        print("GZdownloadLastfmArtistsByQuery init")
        super.searchQueue.maxConcurrentOperationCount = 1
        
        self.downloadLastfmArtistsByQuery = GZdownloadLastfmArtistsByQuery(withSearchQuery: searchQuery, perPage: perPage, pageNumber: pageNumber) { (resultArtists) -> Void in
            success(resultArtists)
        }
        
        super.searchQueue.addOperation(downloadLastfmArtistsByQuery!)
        print("GZdownloadLastfmArtistsByQuery queued")
    }
}

// MARK: download summary to the requested artist
extension GZArtistManager {
    class func getArtistsInfoLF(artist: GZArtist, success: ( _ resultArtist : GZArtist ) -> Void)
    {
        print("GZdownloadLastfmArtistsInfoByMbID init")
        super.searchQueue.maxConcurrentOperationCount = 1
        
        self.downloadLastfmArtistsInfoByMbID = GZdownloadLastfmArtistsInfoByMbID(withArtist: artist) { (resultArtist) -> Void in
            success(resultArtist)
        }
        
        super.searchQueue.addOperation(downloadLastfmArtistsInfoByMbID!)
        print("GZdownloadLastfmArtistsInfoByMbID queued")
    }
}
